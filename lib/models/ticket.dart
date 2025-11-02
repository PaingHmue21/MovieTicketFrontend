class Ticket {
  final int ticketid;
  final int movieid;
  final String moviename;
  final String movieshowdate;
  final String movieshowtime;
  final double ticketprice;
  final String paymenttype;
  final String? qrCode;
  final List<dynamic> soldSeats;

  Ticket({
    required this.ticketid,
    required this.movieid,
    required this.moviename,
    required this.movieshowdate,
    required this.movieshowtime,
    required this.ticketprice,
    required this.paymenttype,
    this.qrCode,
    required this.soldSeats,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketid: json['ticketid'],
      movieid: json['movieid'],
      moviename: json['moviename'] ?? '',
      movieshowdate: json['movieshowdate'] ?? '',
      movieshowtime: json['movieshowtime'] ?? '',
      ticketprice: (json['ticketprice'] ?? 0).toDouble(),
      paymenttype: json['paymenttype'] ?? '',
      qrCode: json['qrCode'],
      soldSeats: json['soldSeats'] ?? [],
    );
  }
}
