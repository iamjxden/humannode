enum Environment { dev, staging, prod }

class Env {
  static const Environment current = Environment.dev;

  static bool get isDev => current == Environment.dev;
  static bool get isStaging => current == Environment.staging;
  static bool get isProd => current == Environment.prod;
  static bool get enableDebugScreen => isDev;
  static bool get enableBenchmarks => !isProd;
  static bool get verboseLogging => isDev;
  static bool get showPerformanceOverlay => false;
  static bool get enableMockInference => isDev;
  static String get apiBaseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://localhost:7000';
      case Environment.staging:
        return 'https://staging.humannode.local';
      case Environment.prod:
        return 'https://api.humannode.local';
    }
  }
}
