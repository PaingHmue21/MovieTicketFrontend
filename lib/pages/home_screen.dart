import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test_app/pages/movie_search_screen.dart';
import '../models/user.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import 'movie_show_date_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.user});
  final User? user;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  User? _currentUser; // mutable user variable
  late Future<List<Movie>> movies;
  final Map<String, PageController> _controllers = {};
  final Map<String, Timer> _timers = {};

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user; // store initial user
    movies = ApiService().fetchMovies();
  }

  /// 🔁 Allow parent widget (HomePage) to update user dynamically
  void updateUser(User? user) {
    setState(() {
      _currentUser = user;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> reloadMovies() async {
    setState(() {
      movies = ApiService().fetchMovies();
    });
  }

  List<String> getCategories(List<Movie> movies) {
    final categorySet = <String>{};
    for (var movie in movies) {
      categorySet.add(movie.movietypename);
    }
    return categorySet.toList();
  }

  List<Movie> filterByCategory(List<Movie> movieList, String category) {
    return movieList
        .where(
          (movie) => movie.movietypename.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  Widget buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieShowDateScreen(id: movie.id, user: _currentUser),
          ),
        );
      },
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "${AppConstants.imageBaseUrl}/images/${movie.movieimage.split(',').first.trim()}",
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[850],
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategorySection(String title, List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();
    final pages = <List<Movie>>[];
    for (var i = 0; i < movies.length; i += 2) {
      pages.add(movies.sublist(i, i + 2 > movies.length ? movies.length : i + 2));
    }

    _controllers.putIfAbsent(title, () => PageController(viewportFraction: 0.95));
    _timers.putIfAbsent(
      title,
      () => Timer.periodic(const Duration(seconds: 5), (timer) {
        final controller = _controllers[title]!;
        if (controller.hasClients) {
          int nextPage = controller.page!.round() + 1;
          if (nextPage >= pages.length) nextPage = 0;
          controller.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieSearchScreen(
                        category: title,
                        movies: movies,
                        user: _currentUser,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Show All",
                  style: TextStyle(
                    color: Color.fromARGB(255, 128, 228, 40),
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _controllers[title],
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final pageMovies = pages[pageIndex];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: pageMovies.map((movie) => buildMovieCard(movie)).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: FutureBuilder<List<Movie>>(
        future: movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Connection Error"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No movies available", style: TextStyle(color: Colors.white70)),
            );
          }

          final movieList = snapshot.data!;
          final categories = getCategories(movieList);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCategorySection("Popular Movies", movieList),
                for (var category in categories)
                  buildCategorySection(category, filterByCategory(movieList, category)),
              ],
            ),
          );
        },
      ),
    );
  }
}


// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key, this.user});
//   final User? user;
//   @override
//   HomeScreenState createState() => HomeScreenState();
// }

// class HomeScreenState extends State<HomeScreen> {
//   late Future<List<Movie>> movies;
//   final Map<String, PageController> _controllers = {};
//   final Map<String, Timer> _timers = {};

//   @override
//   void initState() {
//     super.initState();
//     movies = ApiService().fetchMovies();
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     for (var timer in _timers.values) {
//       timer.cancel();
//     }
//     super.dispose();
//   }



//   Future<void> reloadMovies() async {
//     setState(() {
//       movies = ApiService().fetchMovies();
//     });
//   }

//   List<String> getCategories(List<Movie> movies) {
//     final categorySet = <String>{};
//     for (var movie in movies) {
//       categorySet.add(movie.movietypename);
//     }
//     return categorySet.toList();
//   }

//   List<Movie> filterByCategory(List<Movie> movieList, String category) {
//     return movieList
//         .where(
//           (movie) =>
//               movie.movietypename.toLowerCase() == category.toLowerCase(),
//         )
//         .toList();
//   }

//   Widget buildMovieCard(Movie movie) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//                 MovieShowDateScreen(id: movie.id, user: widget.user),
//           ),
//         );
//       },
//       child: SizedBox(
//         width: 180, // each movie takes fixed width
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🎞 Movie Poster
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 "${AppConstants.imageBaseUrl}/images/${movie.movieimage.split(',').first.trim()}",
//                 height: 250,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   height: 250,
//                   color: Colors.grey[850],
//                   child: const Icon(
//                     Icons.broken_image,
//                     color: Colors.grey,
//                     size: 40,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCategorySection(String title, List<Movie> movies) {
//     if (movies.isEmpty) return const SizedBox.shrink();
//     final pages = <List<Movie>>[];
//     for (var i = 0; i < movies.length; i += 2) {
//       pages.add(
//         movies.sublist(i, i + 2 > movies.length ? movies.length : i + 2),
//       );
//     }
//     _controllers.putIfAbsent(
//       title,
//       () => PageController(viewportFraction: 0.95),
//     );
//     _timers.putIfAbsent(
//       title,
//       () => Timer.periodic(const Duration(seconds: 5), (timer) {
//         final controller = _controllers[title]!;
//         if (controller.hasClients) {
//           int nextPage = controller.page!.round() + 1;
//           if (nextPage >= pages.length) nextPage = 0;
//           controller.animateToPage(
//             nextPage,
//             duration: const Duration(milliseconds: 600),
//             curve: Curves.easeInOut,
//           );
//         }
//       }),
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.amber,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => MovieSearchScreen(
//                         category: title,
//                         movies: movies,
//                         user: widget.user,
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   "Show All",
//                   style: TextStyle(
//                     color: Color.fromARGB(255, 128, 228, 40),
//                     fontSize: 17,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 260,
//           child: PageView.builder(
//             controller: _controllers[title],
//             itemCount: pages.length,
//             itemBuilder: (context, pageIndex) {
//               final pageMovies = pages[pageIndex];
//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: pageMovies
//                     .map((movie) => buildMovieCard(movie))
//                     .toList(),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF141414),
//       body: FutureBuilder<List<Movie>>(
//         future: movies,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Colors.redAccent),
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Connection Error"));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No movies available",
//                 style: TextStyle(color: Colors.white70),
//               ),
//             );
//           }
//           // }
//           final movieList = snapshot.data!;
//           final categories = getCategories(movieList);
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 buildCategorySection("Popular Movies", movieList),
//                 for (var category in categories)
//                   buildCategorySection(
//                     category,
//                     filterByCategory(movieList, category),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
