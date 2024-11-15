import 'usage_tracker_platform_interface.dart';

import 'dart:async';

abstract class UsageTracker {
  static Future<String?> getPlatformVersion() {
    return UsageTrackerPlatform.instance.getPlatformVersion();
  }

  // Check if the app has usage stats permission
  static Future<bool> hasPermission() async {
    return await UsageTrackerPlatform.instance.hasPermission();
  }

  // Request usage stats permission
  static Future<void> requestPermission() async {
    await UsageTrackerPlatform.instance.requestPermission();
  }

  // Get app usage data within a specific time range
  static Future<Map<String, int>> getAppUsageDataInRange(
      DateTime startTime, DateTime endTime) async {
    return await UsageTrackerPlatform.instance
        .getAppUsageDataInRange(startTime, endTime);
  }
}
