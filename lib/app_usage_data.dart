class AppUsageData {
  final String packageName;
  final String appName;
  final Duration totalTimeInForeground;
  final String? versionName;
  final int versionCode;

  AppUsageData({
    required this.packageName,
    required this.appName,
    required this.totalTimeInForeground,
    required this.versionName,
    required this.versionCode,
  });

  factory AppUsageData.fromMap(Map<String, dynamic> map) {
    return AppUsageData(
      packageName: map['packageName'],
      appName: map['appName'],
      totalTimeInForeground:
          Duration(milliseconds: map['totalTimeInForeground']),
      versionName: map['versionName'],
      versionCode: map['versionCode'],
    );
  }

  @override
  String toString() {
    return 'AppUsageData(packageName: $packageName, appName: $appName, totalTimeInForeground: $totalTimeInForeground, versionName: $versionName, versionCode: $versionCode)';
  }
}
