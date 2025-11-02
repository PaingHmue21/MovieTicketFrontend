class AppConstants {
  // 🌐 Change this single line for your backend base URL
  static const String backendBaseUrl = "https://movieticket-production-6023.up.railway.app";

  // 🧭 Optional convenience getters
  static String get apiBaseUrl => "$backendBaseUrl/api";
  static String get imageBaseUrl => "$backendBaseUrl";
  static String get wsUrl => "$backendBaseUrl/ws";
}
