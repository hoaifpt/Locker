
class Environment {
  Environment._();

  static const String _api = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );
  //https://api.hoaitran.online/api
  static String get apiBaseUrl => _api;
}