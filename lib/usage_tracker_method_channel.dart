import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:usage_tracker/app_usage_data.dart';

import 'usage_tracker_platform_interface.dart';

/// An implementation of [UsageTrackerPlatform] that uses method channels.
class MethodChannelUsageTracker extends UsageTrackerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('usage_tracker');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> hasPermission() async {
    final bool hasPermission =
        await methodChannel.invokeMethod('hasPermission');
    return hasPermission;
  }

  @override
  Future<void> requestPermission() async {
    await methodChannel.invokeMethod('requestPermission');
  }

  @override
  Future<List<AppUsageData>> getAppUsageDataInRange(
      DateTime startTime, DateTime endTime) async {
    final int startTimeMillis = startTime.millisecondsSinceEpoch;
    final int endTimeMillis = endTime.millisecondsSinceEpoch;

    final List<dynamic> result = await methodChannel.invokeMethod(
      'getAppUsageDataInRange',
      {
        'startTime': startTimeMillis,
        'endTime': endTimeMillis,
      },
    );

    return result
        .map((data) => AppUsageData.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }
}
