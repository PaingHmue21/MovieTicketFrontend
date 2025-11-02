class Movie {
  final int id;
  final String moviecode;
  final String title;
  final String actor;
  final String actress;
  final String director;
  final String movietypename;
  final String movieimage;
  final String playtime;
  final String description;
  final String theatreEmail;
  final String movieshowdate;
  final String movieshowtime;

  Movie({
    required this.id,
    required this.moviecode,
    required this.title,
    required this.actor,
    required this.actress,
    required this.director,
    required this.movietypename,
    required this.movieimage,
    required this.playtime,
    required this.description,
    required this.theatreEmail,
    required this.movieshowdate,
    required this.movieshowtime,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['movieid'] ?? 0,
      moviecode: json['moviecode'] ?? '',
      title: json['title'] ?? '',
      actor: json['actor'] ?? '',
      actress: json['actress'] ?? '',
      director: json['director'] ?? '',
      movietypename: json['movietypename'] ?? '',
      movieimage: json['movieimage'] ?? '',
      playtime: json['playtime'] ?? '',
      description: json['description'] ?? '',
      movieshowdate: json['movieshowdate'] ?? '',
      movieshowtime: json['movieshowtime'] ?? '',
      theatreEmail: json['theatres'] != null
          ? json['theatres']['theatreemail'] ?? ''
          : '',
    );
  }
}
