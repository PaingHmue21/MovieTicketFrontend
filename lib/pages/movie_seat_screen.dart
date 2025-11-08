import 'package:flutter/material.dart';
import 'package:test_app/pages/login_screen.dart';
import '../models/movieseat.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/movieshowdate.dart';
import '../models/movieshowtime.dart';

class MovieSeatScreen extends StatefulWidget {
  final int id;
  final User? user;
  final MovieShowDate showdate; // ✅ specify type
  final MovieShowTime showtime;
  const MovieSeatScreen({
    super.key,
    required this.id,
    this.user,
    required this.showtime,
    required this.showdate,
  });
  @override
  State<MovieSeatScreen> createState() => _MovieSeatScreenState();
}

class _MovieSeatScreenState extends State<MovieSeatScreen> {
  User? loggedInUser;
  late Future<MovieSeat> movieSeat;
  List<int> selectedSeats = [];
  String paymentType = '';
  double totalPrice = 0;
  Map<int, String> selectedSeatStandards = {};

  @override
  void initState() {
    super.initState();
    movieSeat = ApiService().fetchMovieSeat(
      widget.id,
      widget.showtime,
      widget.showdate,
    );
    loggedInUser = widget.user;
  }

  void toggleSeat(
    int seatNumber,
    double price,
    bool isOccupied, {
    String? standard,
  }) {
    if (isOccupied) return;
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
        totalPrice -= price;
        selectedSeatStandards.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
        totalPrice += price;
        if (standard != null) {
          selectedSeatStandards[seatNumber] = standard;
        }
      }
    });
  }

  void selectPayment(String type) {
    setState(() {
      paymentType = type;
    });
  }

  Future<void> placeOrder(MovieSeat movie) async {
    final payload = {
      "movieid": movie.movieid,
      "userid": loggedInUser?.userid,
      "selectedSeats": selectedSeats,
      "paymentType": paymentType,
      "showdate": widget.showdate.showDate,
      "showtime": widget.showtime.showTime,
    };

    try {
      final response = await ApiService().submitOrder(payload);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ ${response['message']}")));
      setState(() {
        selectedSeats.clear();
        totalPrice = 0;
        paymentType = '';
        selectedSeatStandards.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $e")));
    }
  }

  Widget _buildLegendBox(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.event_seat, color: color, size: 35),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buy Ticket")),
      body: FutureBuilder<MovieSeat>(
        future: movieSeat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Movie not found"));
          }
          final movie = snapshot.data!;
          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "✨ Luxe Seating & Ticket Rates",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber, // gold color
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildLegendBox(
                        const Color.fromARGB(255, 254, 253, 253),
                        "Available",
                      ),
                      const SizedBox(width: 12),
                      _buildLegendBox(
                        const Color.fromARGB(255, 7, 226, 14),
                        "Selected",
                      ),
                      const SizedBox(width: 12),
                      _buildLegendBox(
                        const Color.fromARGB(255, 245, 2, 2),
                        "Occupied",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (movie.seatPricings != null &&
                      movie.seatPricings!.isNotEmpty) ...[
                    ...movie.seatPricings!.map((pricing) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${pricing.standard.toUpperCase()} — ${pricing.price} MMK",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              shadows: [
                                Shadow(
                                  blurRadius: 6,
                                  color: Colors.black54,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 10,
                                  mainAxisSpacing: 6,
                                  crossAxisSpacing: 6,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount:
                                pricing.endSeatNumber -
                                pricing.startSeatNumber +
                                1,
                            itemBuilder: (context, index) {
                              final seatNumber =
                                  pricing.startSeatNumber + index;
                              final soldSeatsList = List<int>.from(
                                movie.soldSeats ?? [],
                              );
                              final isOccupied = soldSeatsList.contains(
                                seatNumber,
                              );
                              final isSelected = selectedSeats.contains(
                                seatNumber,
                              );
                              return GestureDetector(
                                onTap: isOccupied
                                    ? null
                                    : () => toggleSeat(
                                        seatNumber,
                                        pricing.price,
                                        isOccupied,
                                        standard: pricing.standard,
                                      ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.event_seat,
                                      size: 35,
                                      color: isOccupied
                                          ? const Color.fromARGB(
                                              255,
                                              238,
                                              28,
                                              28,
                                            )
                                          : isSelected
                                          ? const Color.fromARGB(
                                              255,
                                              7,
                                              226,
                                              14,
                                            )
                                          : const Color.fromARGB(
                                              255,
                                              248,
                                              247,
                                              247,
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ]
                  // --- Theatre Section ---
                  else if (movie.theatres != null &&
                      movie.theatres!.numofSeat > 0) ...[
                    Text(
                      "All Seats (${movie.theatres!.numofSeat})",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 10,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: movie.theatres!.numofSeat,
                      itemBuilder: (context, index) {
                        final seatNumber = index + 1;
                        final isOccupied = (movie.soldSeats ?? []).contains(
                          seatNumber,
                        );
                        final isSelected = selectedSeats.contains(seatNumber);

                        return GestureDetector(
                          onTap: isOccupied
                              ? null
                              : () => toggleSeat(seatNumber, 0, isOccupied),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_seat,
                                size: 28,
                                color: isOccupied
                                    ? const Color.fromARGB(255, 249, 11, 11)
                                    : isSelected
                                    ? const Color.fromARGB(255, 2, 250, 10)
                                    : const Color.fromARGB(255, 252, 251, 251),
                              ),
                              Text(
                                seatNumber.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    const Text("No seat information available"),
                  ],
                  const SizedBox(height: 16),
                  if (selectedSeats.isNotEmpty) ...[
                    const Text(
                      "Selected Seats:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 3,
                      children: selectedSeats.map((seat) {
                        final standard =
                            selectedSeatStandards[seat] ?? "Standard";
                        return Chip(
                          label: Text("Seat $seat ($standard)"),
                          backgroundColor: Colors.amber,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    "Total Price: ${totalPrice.toStringAsFixed(2)} MMK",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "💳 Payment Options:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['PayPal', 'kpay', 'cbpay', 'wavepay'].map((
                        type,
                      ) {
                        final isSelected = paymentType == type;
                        return GestureDetector(
                          onTap: () => selectPayment(type),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Image.network(
                              "http://10.0.2.2:8080/images/${type.toLowerCase()}.png",
                              width: 50,
                              height: 50,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedSeats.isEmpty || paymentType.isEmpty
                        ? null
                        : () async {
                            if (loggedInUser == null) {
                              final user = await Navigator.push<User?>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AuthScreen(onLogin: (user) {}),
                                ),
                              );
                              if (user != null) {
                                setState(() => loggedInUser = user);
                                await placeOrder(movie); // continue buying
                              }
                            } else {
                              await placeOrder(movie);
                            }
                          },
                    child: const Text("Buy"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
