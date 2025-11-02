import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_show_date_screen.dart';
import '../utils/constants.dart';
class MovieSearchScreen extends StatelessWidget {
  final String category;
  final List<Movie> movies;
  final dynamic user;

  const MovieSearchScreen({
    super.key,
    required this.category,
    required this.movies,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text(
          category,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 251, 250, 248),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // two movies per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieShowDateScreen(id: movie.id, user: user),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "${AppConstants.imageBaseUrl}/images/${movie.movieimage.split(',').first.trim()}",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[850],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
