class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'https://immature-basin-rework.ngrok-free.dev',
  );

  static bool get isConfigured => apiBaseUrl.isNotEmpty;
}
