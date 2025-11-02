class MovieShowTime {
  final int id;
  final String showTime;

  MovieShowTime({required this.id, required this.showTime});

  factory MovieShowTime.fromJson(Map<String, dynamic> json) {
    return MovieShowTime(
      id: json['id'],
      showTime: json['showTime'],
    );
  }
}
