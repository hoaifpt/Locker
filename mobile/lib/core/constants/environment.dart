
class Environment {
  Environment._();

  static const String _api = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.hoaitran.online/api',
  );

  static String get apiBaseUrl => _api;
}