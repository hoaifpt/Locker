
class Environment {
  Environment._();

  static const String _api = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.hoaitran.online/api',
  );
  //https://api.hoaitran.online/api
  //http://10.0.2.2:5000/api
  static String get apiBaseUrl => _api;
}