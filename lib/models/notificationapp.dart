class NotificationApp {
  final int id;
  final int userId;
  final String title;
  final String message;
  bool readStatus;
  final DateTime createdAt;

  NotificationApp({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.readStatus,
    required this.createdAt,
  });

  factory NotificationApp.fromJson(Map<String, dynamic> json) {
    return NotificationApp(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      readStatus: json['readStatus'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
