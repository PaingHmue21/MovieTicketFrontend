import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  final User? user;
  const BookingHistoryScreen({super.key, this.user});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Ticket> tickets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      final ticketList = await ApiService().fetchTickets(widget.user!.userid);
      setState(() {
        tickets = ticketList;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint("⚠️ Failed to fetch tickets: $e");
    }
  }

  String formatDate(String date, String time) {
    try {
      final cleanTime = time.replaceAll(RegExp(r'[^0-9:]'), '');
      final safeTime = cleanTime.length > 8
          ? cleanTime.substring(0, 8)
          : cleanTime;
      final dateTime = DateTime.parse("${date}T${safeTime}");
      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year} • "
          "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      debugPrint("⚠️ Date parse failed: $date $time ($e)");
      return "$date $time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 23, 13, 13),
      appBar: AppBar(
        title: const Text(
          "Booking History",
          style: TextStyle(color: Color.fromARGB(255, 9, 8, 6), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 247, 244, 244),
        centerTitle: true,
        elevation: 6,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : tickets.isEmpty
          ? const Center(
              child: Text(
                "No tickets found.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              color: Colors.amber,
              onRefresh: _fetchTickets,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return Card(
                    color: const Color(0xFF1A1A1A),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: Colors.amber.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ticket.moviename,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              Text(
                                "Ticket #${ticket.ticketid}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Price: ${ticket.ticketprice} MMK",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.amber,
                                ),
                              ),
                              Text(
                                // formatDate(ticket.movieshowtime),
                                formatDate(
                                  ticket.movieshowdate,
                                  ticket.movieshowtime,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child:
                                ticket.qrCode != null &&
                                    ticket.qrCode!.isNotEmpty
                                ? Image.memory(
                                    base64Decode(ticket.qrCode!),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.contain,
                                  )
                                : const Text("No QR Code available"),
                          ),
                          const SizedBox(height: 4),
                          if (ticket.soldSeats.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: ticket.soldSeats
                                  .map(
                                    (seat) => Chip(
                                      label: Text(
                                        seat['soldseatno'].toString(),
                                      ),
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        244,
                                        246,
                                        245,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
