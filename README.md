# Usage Tracker Plugin

A Flutter plugin that enables apps to access and track app usage data on Android. This plugin provides methods to check and request permissions, as well as to retrieve app usage statistics within a specified time range.

## Features

*   Check if the app has permission to access usage stats
*   Request usage stats permission
*   Retrieve app usage data within a specific time range

## Installation

Add `usage_tracker` to your `pubspec.yaml` file:
```
dependencies:
  usage_tracker: ^1.0.0
```

Then, run:
```
flutter pub get
```
## Permissions

This plugin requires permission to access app usage data. On Android, the permission must be granted manually by navigating to **Settings > Security > Usage Access** and enabling the app.

## Usage

Import `usage_tracker` into your Dart code:
```
import 'package:usage_tracker/usage_tracker.dart';
```
### Check Permission

Use `hasPermission` to check if the app has the necessary usage stats permission:
```
bool hasPermission = await UsageTracker.hasPermission();
```
### Request Permission

Use `requestPermission` to navigate the user to the settings page to grant usage stats permission:
```
await UsageTracker.requestPermission();
```
### Get App Usage Data

Use `getAppUsageDataInRange` to retrieve app usage data within a specified time range:
```
DateTime startTime = DateTime.now().subtract(Duration(days: 1));
DateTime endTime = DateTime.now();
List usageData = await UsageTracker.getAppUsageDataInRange(startTime, endTime);
```

### Example

Here's a complete example of how to use the plugin:
```
import 'package:flutter/material.dart';
import 'package:usage_tracker/usage_tracker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UsageStatsScreen(),
    );
  }
}

class UsageStatsScreen extends StatefulWidget {
  @override
  _UsageStatsScreenState createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State {
  List _usageData = [];

  @override
  void initState() {
    super.initState();
    fetchUsageData();
  }

  Future fetchUsageData() async {
    bool hasPermission = await UsageTracker.hasPermission();
    if (!hasPermission) {
      await UsageTracker.requestPermission();
    }

    DateTime startTime = DateTime.now().subtract(Duration(days: 1));
    DateTime endTime = DateTime.now();

    List usageData = await UsageTracker.getAppUsageDataInRange(startTime, endTime);
    setState(() {
      _usageData = usageData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usage Stats'),
      ),
      body: ListView.builder(
        itemCount: _usageData.length,
        itemBuilder: (context, index) {
          final app = _usageData[index];
          return ListTile(
            title: Text(app.appName),
            subtitle: Text('Time in foreground: ${app.totalTimeInForeground}'),
          );
        },
      ),
    );
  }
}
```

## API Reference

### `Future<String?> getPlatformVersion()`

Returns the platform version as a string.

### `Future<bool> hasPermission()`

Checks if the app has permission to access app usage stats. Returns `true` if permission is granted, otherwise `false`.

### `Future<void> requestPermission()`

Requests usage stats permission by navigating to the usage access settings page.

### `Future<List<AppUsageData>> getAppUsageDataInRange(DateTime startTime, DateTime endTime)`

Fetches app usage data between `startTime` and `endTime`. Returns a list of `AppUsageData`.

#### AppUsageData Class

Represents usage data for an app.

*   **packageName**: `String` - The package name of the app
*   **appName**: `String` - The display name of the app
*   **totalTimeInForeground**: `Duration` - Time spent in the foreground
*   **versionName**: `String?` - Version name of the app
*   **versionCode**: `int` - Version code of the app

## Platform-Specific Implementation

This plugin currently supports only Android, as iOS does not provide equivalent APIs for app usage data access.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.