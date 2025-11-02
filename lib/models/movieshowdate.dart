import 'movieshowtime.dart';

class MovieShowDate {
  final int id;
  final String showDate;
  final List<MovieShowTime> showTimes;

  MovieShowDate({
    required this.id,
    required this.showDate,
    required this.showTimes,
  });

  factory MovieShowDate.fromJson(Map<String, dynamic> json) {
    var list = json['showTimes'] as List;
    List<MovieShowTime> showTimeList =
        list.map((i) => MovieShowTime.fromJson(i)).toList();

    return MovieShowDate(
      id: json['id'],
      showDate: json['showDate'],
      showTimes: showTimeList,
    );
  }
}
