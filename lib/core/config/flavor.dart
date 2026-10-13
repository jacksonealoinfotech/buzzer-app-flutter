/// Supported application deployment environments (flavors).
enum Flavor {
  /// Development environment: mock/local APIs, verbose logging, bypass security where appropriate.
  dev,

  /// Staging/UAT environment: QA testing, pre-production backend, security enabled.
  staging,

  /// Production environment: live backend, release security, telemetry enabled.
  prod;

  /// Whether current flavor is development.
  bool get isDev => this == Flavor.dev;

  /// Whether current flavor is staging.
  bool get isStaging => this == Flavor.staging;

  /// Whether current flavor is production.
  bool get isProd => this == Flavor.prod;

  /// String identifier matching build configurations.
  String get name => switch (this) {
        Flavor.dev => 'dev',
        Flavor.staging => 'staging',
        Flavor.prod => 'prod',
      };

  /// Default API base URL for this environment.
  String get defaultBaseUrl => switch (this) {
        Flavor.dev => 'https://api-dev.example.com',
        Flavor.staging => 'https://api-staging.example.com',
        Flavor.prod => 'https://api.example.com',
      };
}
