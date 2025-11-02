class ChangePassword {
  final int userid;
  final String useremail;
  final String? oldpassword;
  final String? newpassword;

  ChangePassword({
    required this.userid,
    required this.useremail,
    required this.oldpassword,
    required this.newpassword,
  });

  factory ChangePassword.fromJson(Map<String, dynamic> json) {
    return ChangePassword(
      userid: json['userid'] ?? json['id'],
      useremail: json['useremail'],
      oldpassword: json['oldpassword'],
      newpassword: json['newpassword'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userid,
      'useremail':useremail,
      'oldpassword': oldpassword,
      'newpassword': newpassword,
    };
  }
}
