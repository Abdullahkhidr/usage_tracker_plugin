import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_usage_data.dart';
import 'usage_tracker_method_channel.dart';

abstract class UsageTrackerPlatform extends PlatformInterface {
  /// Constructs a UsageTrackerPlatform.
  UsageTrackerPlatform() : super(token: _token);

  static final Object _token = Object();

  static UsageTrackerPlatform _instance = MethodChannelUsageTracker();

  /// The default instance of [UsageTrackerPlatform] to use.
  ///
  /// Defaults to [MethodChannelUsageTracker].
  static UsageTrackerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UsageTrackerPlatform] when
  /// they register themselves.
  static set instance(UsageTrackerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> hasPermission() async {
    throw UnimplementedError('hasPermission() has not been implemented.');
  }

  Future<void> requestPermission() async {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  Future<List<AppUsageData>> getAppUsageDataInRange(
      DateTime startTime, DateTime endTime) async {
    throw UnimplementedError(
        'getAppUsageDataInRange() has not been implemented.');
  }
}
