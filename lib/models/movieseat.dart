class MovieSeat {
  final int movieid;
  final Theatre? theatres;
  final List<SeatPricing>? seatPricings;
  final List<int>? soldSeats;

  MovieSeat({
    required this.movieid,
    this.theatres,
    this.seatPricings,
    this.soldSeats,
  });

 factory MovieSeat.fromJson(Map<String, dynamic> json) {
  var seatList = (json['seatPricings'] as List?)
      ?.map((e) => SeatPricing.fromJson(e))
      .toList();

  var soldList = (json['soldSeats'] as List?)
    ?.map((e) => e as int) // list of integers
    .toList();


  return MovieSeat(
    movieid: (json['movieid'] ?? 0) as int,
    theatres: json['theatres'] != null
        ? Theatre.fromJson(json['theatres'])
        : null,
    seatPricings: seatList,
    soldSeats: soldList,
  );
}

}

class Theatre {
  final String theatrename;
  final String address;
  final int numofSeat; // 👈 added

  Theatre({
    required this.theatrename,
    required this.address,
    required this.numofSeat,
  });

  factory Theatre.fromJson(Map<String, dynamic> json) {
    return Theatre(
      theatrename: json['theatrename'] ?? '',
      address: json['address'] ?? '',
      numofSeat: (json['numofSeat'] ?? 0) as int,
    );
  }
}


class SeatPricing {
  final int startSeatNumber;
  final int endSeatNumber;
  final double price;
  final String standard;

  SeatPricing({
    required this.startSeatNumber,
    required this.endSeatNumber,
    required this.price,
    required this.standard,
  });

  factory SeatPricing.fromJson(Map<String, dynamic> json) {
    return SeatPricing(
      startSeatNumber: (json['startSeatNumber'] ?? 0) as int,
      endSeatNumber: (json['endSeatNumber'] ?? 0) as int,
      price: (json['price'] ?? 0).toDouble(),
      standard: json['standard'] ?? '',
    );
  }
}
