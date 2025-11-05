import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

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
    _fetchHistoryTickets();
  }

  Future<void> _fetchHistoryTickets() async {
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

  Future<void> deleteSingleTicket(int ticketId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Ticket"),
        content: const Text("Are you sure you want to delete this ticket?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}/deleteticket/$ticketId',
      );
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          tickets.removeWhere((t) => t.ticketid == ticketId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🗑️ Ticket deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("⚠️ Failed to delete ticket: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error while deleting ticket")),
      );
    }
  }

  // ✅ Delete all booking history with confirmation
  Future<void> deleteAllHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete All History"),
        content: const Text(
          "Are you sure you want to delete all booking history? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Delete All",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}/deletealltickets/${widget.user!.userid}',
      );
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() => tickets.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ All booking history deleted")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("⚠️ Failed to delete booking history: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error while deleting history")),
      );
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
      backgroundColor: const Color(0xFF171313),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 247, 247),
        elevation: 6,
        title: Row(
          children: [
            const Text(
              "Booking History",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            if (tickets.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${tickets.length}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(width: 50),
            TextButton.icon(
              onPressed: tickets.isEmpty ? null : deleteAllHistory,
              label: const Text(
                "Delete All",
                style: TextStyle(
                  color: Color.fromARGB(255, 8, 7, 7),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : tickets.isEmpty
          ? const Center(
              child: Text(
                "No booking history found.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              color: Colors.amber,
              onRefresh: _fetchHistoryTickets,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return GestureDetector(
                    onLongPress: () {
                      Future.delayed(const Duration(seconds: 1), () {
                        deleteSingleTicket(ticket.ticketid);
                      });
                    },
                    child: Card(
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
                                Flexible(
                                  child: Text(
                                    ticket.moviename,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "#${ticket.ticketid}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
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
                                  formatDate(
                                    ticket.movieshowdate,
                                    ticket.movieshowtime,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (ticket.qrCode != null &&
                                ticket.qrCode!.isNotEmpty)
                              Center(
                                child: Image.memory(
                                  base64Decode(ticket.qrCode!),
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                            if (ticket.soldSeats.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: ticket.soldSeats
                                    .map(
                                      (seat) => Chip(
                                        label: Text(
                                          seat['soldseatno'].toString(),
                                        ),
                                        backgroundColor: Colors.amberAccent,
                                      ),
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
