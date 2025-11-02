class User {
  final int userid;
  final String username;
  final String useremail;
  final String? profile;
  final String? phoneno;

  User({
    required this.userid,
    required this.username,
    required this.useremail,
    this.profile,
    this.phoneno,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userid: json['userid'] ?? json['id'],
      username: json['username'] ?? json['name'] ?? "Unknown User",
      useremail: json['useremail'] ?? json['email'] ?? "No Email",
      profile: json['profile'],
      phoneno: json['phoneno'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'username': username,
      'useremail': useremail,
      'profile': profile,
      'phoneno': phoneno,
    };
  }
}
