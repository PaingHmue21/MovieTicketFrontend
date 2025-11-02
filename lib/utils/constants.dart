class AppConstants {
  // 🌐 Change this single line for your backend base URL
  static const String backendBaseUrl = "http://10.0.2.2:8080";

  // 🧭 Optional convenience getters
  static String get apiBaseUrl => "$backendBaseUrl/api";
  static String get imageBaseUrl => "$backendBaseUrl";
  static String get wsUrl => "$backendBaseUrl/ws";
}
