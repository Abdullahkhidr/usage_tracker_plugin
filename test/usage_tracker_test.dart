import 'package:flutter_test/flutter_test.dart';
import 'package:usage_tracker/app_usage_data.dart';
import 'package:usage_tracker/usage_tracker.dart';
import 'package:usage_tracker/usage_tracker_platform_interface.dart';
import 'package:usage_tracker/usage_tracker_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUsageTrackerPlatform
    with MockPlatformInterfaceMixin
    implements UsageTrackerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<AppUsageData>> getAppUsageDataInRange(
      DateTime startTime, DateTime endTime) async {
    // Mock data to simulate app usage events
    return [
      AppUsageData(
        packageName: "com.example.app1",
        totalTimeInForeground: const Duration(hours: 1),
      ),
      AppUsageData(
        packageName: "com.example.app2",
        totalTimeInForeground: const Duration(hours: 2),
      ),
      AppUsageData(
        packageName: "com.example.app3",
        totalTimeInForeground: const Duration(hours: 3),
      ),
    ];
  }

  @override
  Future<bool> hasPermission() async {
    // Mock the permission check; return true to simulate granted permission
    return true;
  }

  @override
  Future<void> requestPermission() async {
    // Simulate the request permission action
    // In a real app, this might open a permissions dialog, but here it does nothing
  }
}

void main() {
  final UsageTrackerPlatform initialPlatform = UsageTrackerPlatform.instance;

  setUp(() {
    // Set the mock platform before each test
    MockUsageTrackerPlatform fakePlatform = MockUsageTrackerPlatform();
    UsageTrackerPlatform.instance = fakePlatform;
  });

  test('$MethodChannelUsageTracker is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUsageTracker>());
  });

  test('getPlatformVersion returns mocked version', () async {
    expect(await UsageTracker.getPlatformVersion(), '42');
  });

  test('hasPermission returns true', () async {
    // Check that hasPermission returns true in the mock implementation
    bool hasPermission = await UsageTracker.hasPermission();
    expect(hasPermission, isTrue);
  });

  test('requestPermission does not throw error', () async {
    // Call requestPermission and verify it completes without throwing an error
    expect(() => UsageTracker.requestPermission(), returnsNormally);
  });

  test('getAppUsageDataInRange returns mock usage data', () async {
    // Define a start and end time for the range
    DateTime startTime = DateTime.now().subtract(const Duration(hours: 24));
    DateTime endTime = DateTime.now();

    // Fetch app usage data and verify the returned data matches the mock data
    List<AppUsageData> usageData =
        await UsageTracker.getAppUsageDataInRange(startTime, endTime);

    // Check the length and content of the usage data
    expect(usageData, isNotEmpty);
    expect(usageData.length, 3); // Assuming 3 events as in the mock

    // Verify details of the first mock event
    expect(usageData[0].packageName, "com.example.app1");
    expect(usageData[0].totalTimeInForeground,
        const Duration(hours: 1)); // Check total time
  });
}
