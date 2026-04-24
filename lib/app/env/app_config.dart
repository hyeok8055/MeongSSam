class AppConfig {
  const AppConfig({
    required this.appName,
    required this.applicationId,
    required this.apiBaseUrl,
  });

  final String appName;
  final String applicationId;
  final String apiBaseUrl;

  const AppConfig.fromEnvironment()
    : appName = const String.fromEnvironment('APP_NAME', defaultValue: '멍쌤'),
      applicationId = const String.fromEnvironment(
        'APPLICATION_ID',
        defaultValue: 'com.hyeok8055.meongssam',
      ),
      apiBaseUrl = const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      );
}
