class Theatre {
  final int theatreid;
  final String theatreemail;
  final String theatrename;
  final String address;
  final int numofSeat;

  Theatre({
    required this.theatreid,
    required this.theatreemail,
    required this.theatrename,
    required this.address,
    required this.numofSeat,
  });

  factory Theatre.fromJson(Map<String, dynamic> json) {
    return Theatre(
      theatreid: (json['theatreid'] ?? 0) as int,
      theatreemail: json['theatreemail'] ?? '',
      theatrename: json['theatrename'] ?? '',
      address: json['address'] ?? '',
      numofSeat: (json['numofSeat'] ?? 0) as int,
    );
  }
}
