class AppUsageData {
  final String packageName;
  final Duration totalTimeInForeground;

  AppUsageData({
    required this.packageName,
    required this.totalTimeInForeground,
  });

  factory AppUsageData.fromMap(Map<String, dynamic> map) {
    return AppUsageData(
      packageName: map['packageName'] ?? "Unknown",
      totalTimeInForeground:
          Duration(milliseconds: map['totalTimeInForeground'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'AppUsageData(packageName: $packageName, totalTimeInForeground: $totalTimeInForeground)';
  }
}
