// lib/config/config.dart

class Config {
  // Base URL for API
  static const String baseUrl = 'http://192.168.73.48:5000';
  
  // Other configuration values
  static const int apiTimeout = 30; // seconds
  static const bool enableLogging = true;
  
  // You can add environment-specific configurations too
  static String getEnvironment() {
    return 'development'; // or 'production', 'staging', etc.
  }
}