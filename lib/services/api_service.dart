import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_app/models/moviedetail.dart';
import 'package:test_app/utils/user_storage.dart';
import '../models/movieshowdate.dart';
import '../models/movieshowtime.dart';
import '../models/movieseat.dart';
import '../models/movie.dart';
import '../models/ticket.dart';
import '../models/user.dart';
import 'dart:io';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl = "${AppConstants.apiBaseUrl}"; // For Android emulator

  Future<List<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse("$baseUrl/allmovielists"));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List moviesJson = data['movielist'];
      return moviesJson.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<MovieDetail> fetchMovieShowDate(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/movieshowdate/$id"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final movieJson = data['movie'];
      return MovieDetail.fromJson(movieJson);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<MovieDetail> fetchMovieDetail(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/detailmovie/$id"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final movieJson = Map<String, dynamic>.from(data['movie']);
      movieJson['seatPricings'] = data['seatPricings'];
      movieJson['soldSeats'] = data['soldSeats'];
      return MovieDetail.fromJson(movieJson);
    } else {
      throw Exception('Failed to load movie detail');
    }
  }

  Future<List<Ticket>> fetchTickets(int userid) async {
    final response = await http.get(Uri.parse("$baseUrl/ticket/$userid"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["tickets"] as List).map((t) => Ticket.fromJson(t)).toList();
    } else {
      throw Exception("Failed to fetch tickets");
    }
  }

  Future<List<Ticket>> fetchHistoryTickets(int userid) async {
    final response = await http.get(Uri.parse("$baseUrl/history/$userid"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data["tickets"] as List).map((t) => Ticket.fromJson(t)).toList();
    } else {
      throw Exception("Failed to fetch tickets");
    }
  }

  Future<User> updateUserProfile(User user, File? imageFile) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/updateuserprofile/${user.userid}'),
    );
    request.fields['username'] = user.username;
    request.fields['phoneno'] = user.phoneno ?? '';
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile', imageFile.path),
      );
    }
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data['status'] == 'success') {
        final updatedUser = User.fromJson(data['user']);
        await UserStorage.saveUser(updatedUser);
        return updatedUser;
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } else {
      throw Exception("Failed to update profile (HTTP ${response.statusCode})");
    }
  }

  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse("$baseUrl/submitOrder"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Failed to place order: ${response.body}");
    }
  }

  Future<MovieSeat> fetchMovieSeat(
    int id,
    MovieShowTime showtime,
    MovieShowDate showdate,
  ) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/movieseat/$id?showdate=${showdate.showDate}&showtime=${showtime.showTime}",
      ),
    );
    if (response.statusCode == 200) {
      return MovieSeat.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load movie seat data');
    }
  }
}
