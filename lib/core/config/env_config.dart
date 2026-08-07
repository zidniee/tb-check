class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.solusikode.my.id',
  );

  static bool get isConfigured => apiBaseUrl.isNotEmpty;
}
