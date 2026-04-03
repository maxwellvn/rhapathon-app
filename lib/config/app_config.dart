/// Values come from `--dart-define=KEY=value` or `--dart-define-from-file=...`.
/// Never commit real production values; use CI secrets for release builds.
class AppConfig {
  AppConfig._();

  static const String apiKey =
      String.fromEnvironment('RHAP_API_KEY', defaultValue: '');

  static const String accessPassword =
      String.fromEnvironment('RHAP_ACCESS_PASSWORD', defaultValue: '');

  /// KingsChat OAuth client id (optional).
  static const String kcClientId =
      String.fromEnvironment('RHAP_KC_CLIENT_ID', defaultValue: '');
}
