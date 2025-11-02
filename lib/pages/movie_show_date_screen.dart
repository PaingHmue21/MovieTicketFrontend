import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_service.dart';
import '../models/moviedetail.dart';
import '../models/user.dart';
import '../pages/movie_seat_screen.dart';
import '../utils/constants.dart';
class MovieShowDateScreen extends StatefulWidget {
  final int id;
  final User? user;
  const MovieShowDateScreen({super.key, required this.id, this.user});
  @override
  State<MovieShowDateScreen> createState() => MovieShowDateScreenState();
}

class MovieShowDateScreenState extends State<MovieShowDateScreen> {
  late Future<MovieDetail> movieDetail;
  int? expandedIndex;
  int _currentImageIndex = 0;
  @override
  void initState() {
    super.initState();
    movieDetail = ApiService().fetchMovieShowDate(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 4, 4),
      appBar: AppBar(
        // title: const Text("🎬 Movie Details"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 246, 245, 247),
      ),
      body: FutureBuilder<MovieDetail>(
        future: movieDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "⚠️ Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Movie not found"));
          }

          final movie = snapshot.data!;
          final imageList = movie.movieimage.split(","); // multiple images

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎞️ Movie Image Slider
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 500,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayAnimationDuration: const Duration(
                          milliseconds: 800,
                        ),
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                      items: imageList.map((image) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "${AppConstants.imageBaseUrl}/images/${image.trim()}",
                            height: 500,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 100),
                          ),
                        );
                      }).toList(),
                    ),
                    // 🟣 Dots indicator
                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: imageList.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _currentImageIndex = entry.key),
                            child: Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == entry.key
                                    ? Colors.deepPurple
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                // 🎬 Movie Info Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber, // gold color for title
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Actor: ${movie.actor} - ${movie.actress}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.amber, // gold color for labels
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Director: ${movie.director}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Type: ${movie.movietypename}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Playtime: ${movie.playtime}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "About Movie",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        movie.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  "Available Show Dates",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 10),

                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: movie.showDates.length,
                  itemBuilder: (context, index) {
                    final showDate = movie.showDates[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E), // dark card color
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade700,
                          width: 1.5,
                        ),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 1,
                        ),
                        title: Text(
                          "Show Date: ${showDate.showDate}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.amber, // gold text
                          ),
                        ),
                        initiallyExpanded: expandedIndex == index,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            expandedIndex = expanded ? index : null;
                          });
                        },
                        childrenPadding: const EdgeInsets.all(12),
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: showDate.showTimes.map((showTime) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 11, 4, 4), // button black
                                  foregroundColor: Colors.amber, // gold text
                                  side: const BorderSide(
                                    color: Colors.amber,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieSeatScreen(
                                        id: movie.movieId,
                                        user: widget.user,
                                        showdate: showDate,
                                        showtime: showTime,
                                      ),
                                    ),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "🎟️ Selected ${showDate.showDate} at ${showTime.showTime}",
                                        style: const TextStyle(
                                          color: Colors.amber,
                                        ),
                                      ),
                                      backgroundColor: Colors.black87,
                                    ),
                                  );
                                },
                                child: Text(showTime.showTime),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
