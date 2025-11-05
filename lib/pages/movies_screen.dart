import 'package:flutter/material.dart';
import 'package:test_app/pages/movie_search_screen.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../pages/movie_show_date_screen.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key, this.user});
  final User? user;

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late Future<List<Movie>> movies;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    movies = ApiService().fetchMovies();
  }

  // ✅ Helper to check if a movie date is this week
  bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // ✅ Helper to check if a movie date is this month
  bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // ✅ Helper to check if a movie date is next month
  bool isNextMonth(DateTime date) {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return date.year == nextMonth.year && date.month == nextMonth.month;
  }

  // ✅ Parse movie show date safely
  DateTime? parseMovieDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return null;
      return DateFormat("yyyy-MM-dd").parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  // ✅ Search movies by title, actor, or type
  List<Movie> searchMovies(List<Movie> allMovies, String query) {
    final lowerQuery = query.toLowerCase();
    return allMovies.where((movie) {
      return movie.title.toLowerCase().contains(lowerQuery) ||
          movie.movietypename.toLowerCase().contains(lowerQuery) ||
          movie.director.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ✅ Build movie grid section
  Widget buildMovieGrid(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 2,
            childAspectRatio: 0.63,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MovieShowDateScreen(id: movie.id, user: widget.user),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFF1E1E1E),
                    elevation: 6,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "${AppConstants.imageBaseUrl}/images/${movie.movieimage.split(',').first.trim()}",
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 240,
                          color: Colors.grey[850],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 155, 242, 16),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: FutureBuilder<List<Movie>>(
          future: movies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No movies available",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final movieList = snapshot.data!;
            final thisWeekMovies = <Movie>[];
            final thisMonthMovies = <Movie>[];
            final nextMonthMovies = <Movie>[];

            for (var movie in movieList) {
              final date = parseMovieDate(movie.movieshowdate);
              if (date != null) {
                if (isThisWeek(date)) {
                  thisWeekMovies.add(movie);
                } else if (isThisMonth(date)) {
                  thisMonthMovies.add(movie);
                } else if (isNextMonth(date)) {
                  nextMonthMovies.add(movie);
                }
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (query) {
                        if (query.trim().isEmpty) return;
                        final results = searchMovies(movieList, query);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieSearchScreen(
                              category: "Search Results",
                              movies: results,
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search movies...',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 40, 242, 14),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color.fromARGB(255, 107, 246, 48),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 130, 243, 18),
                            width: 1.5,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),

                  // 🎬 Movie Sections
                  buildMovieGrid("🔥 Hot Releases This Week", thisWeekMovies),
                  buildMovieGrid("⭐ Must-Watch Movies This Month", thisMonthMovies),
                  buildMovieGrid("📅 Upcoming Movies Next Month", nextMonthMovies),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
