import 'movieshowdate.dart';

class MovieDetail {
  final int movieId;
  final String title;
  final String actor;
  final String actress;
  final String director;
  final String movietypename;
  final String playtime;
  final String description;
  final String movieimage;
  final List<MovieShowDate> showDates;

  MovieDetail({
    required this.movieId,
    required this.title,
    required this.actor,
    required this.actress,
    required this.director,
    required this.movietypename,
    required this.playtime,
    required this.description,
    required this.movieimage,
    required this.showDates,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    var list = json['showDates'] as List;
    List<MovieShowDate> showDateList =
        list.map((i) => MovieShowDate.fromJson(i)).toList();

    return MovieDetail(
      movieId: json['movieid'],
      title: json['title'],
      actor: json['actor'],
      actress: json['actress'],
      director: json['director'],
      movietypename: json['movietypename'],
      playtime: json['playtime'],
      description: json['description'],
      movieimage: json['movieimage'],
      showDates: showDateList,
    );
  }
}

