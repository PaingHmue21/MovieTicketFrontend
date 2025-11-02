import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';

class TicketsScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  const TicketsScreen({super.key, required this.user, required this.onLogout});
  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  List<Ticket> tickets = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      final ticketlist = await ApiService().fetchTickets(widget.user.userid);
      setState(() {
        tickets = ticketlist;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // String formatDate(String date, String time) {
  //   try {
  //     final dateTime = DateTime.parse("${date}T${time}");
  //     return "${dateTime.day}/${dateTime.month}/${dateTime.year} "
  //         "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  //   } catch (e) {
  //     return "$date $time"; // fallback if parsing fails
  //   }
  // }

  String formatDate(String date, String time) {
    try {
      // Fix invalid time formats like "22:000:00"
      final cleanTime = time.replaceAll(RegExp(r'[^0-9:]'), '');
      // If too long, cut to "HH:mm:ss"
      final safeTime = cleanTime.length > 8
          ? cleanTime.substring(0, 8)
          : cleanTime;

      final dateTime = DateTime.parse("${date}T${safeTime}");
      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year} "
          "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      debugPrint("⚠️ Date parse failed: $date $time ($e)");
      return "$date $time"; // fallback to raw display
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (tickets.isEmpty) return const Center(child: Text("No tickets found."));
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Card(
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.symmetric(vertical: 10),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.amber.withOpacity(0.4), width: 1),
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
                      style: const TextStyle(fontSize: 16, color: Colors.amber),
                    ),
                  ],
                ),

                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Price: ${ticket.ticketprice} MMK",
                      style: const TextStyle(fontSize: 16, color: Colors.amber),
                    ),
                    Text(
                      // formatDate(ticket.movieshowtime),
                      formatDate(ticket.movieshowdate, ticket.movieshowtime),
                      style: const TextStyle(fontSize: 14, color: Colors.amber),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: ticket.qrCode != null && ticket.qrCode!.isNotEmpty
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
                            label: Text(seat['soldseatno'].toString()),
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
    );
  }
}
