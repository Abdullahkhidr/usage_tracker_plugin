# Usage Tracker Plugin

A Flutter plugin for tracking app usage statistics on Android. This plugin provides methods to check for permissions, request permissions, and retrieve the usage data of apps within a specified time range.

## Features

*   **Check Permission**: Check if the app has permission to access usage statistics.
*   **Request Permission**: Request usage statistics permission from the user.
*   **Get App Usage Data**: Retrieve app usage data (foreground time) for apps within a specific time range.
*   **Platform Version**: Get the platform version of the Android device.

## Installation

To use this plugin in your Flutter project, add the following dependency to your `pubspec.yaml` file:

```
dependencies:
  usage_tracker: ^0.1.0
```

Then, run the following command to install the plugin:

```
flutter pub get
```

## How It Works

1.  **Permission Request Handling**: The plugin automatically checks if the app has permission to access usage statistics and can prompt the user to enable it if necessary. When `requestPermission()` is called, it opens the device’s "Usage Access" settings so the user can grant the permission manually.
2.  **No Need for Permission Handling in App Code**: You **do not need to request or handle the permission yourself**. The plugin takes care of checking and requesting the necessary permission for you. The only thing you need to do is ensure the plugin is installed and correctly initialized in your project.

## Example

Here's an example of how to use the plugin in your app. The plugin will handle permission requests automatically, so you can focus on accessing the app usage data:

```
import 'package:flutter/material.dart';
import 'package:usage_tracker/usage_tracker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  String _platformVersion = '';
  bool _hasPermission = false;
  Map _appUsageData = {};

  @override
  void initState() {
    super.initState();
    _initializeUsageData();
  }

  Future _initializeUsageData() async {
    final platformVersion = await UsageTracker.getPlatformVersion();
    final hasPermission = await UsageTracker.hasPermission();

    if (hasPermission) {
      final startTime = DateTime.now().subtract(Duration(days: 1));  // 1 day ago
      final endTime = DateTime.now();
      final appUsageData = await UsageTracker.getAppUsageDataInRange(startTime, endTime);

      setState(() {
        _platformVersion = platformVersion ?? 'Unknown';
        _hasPermission = hasPermission;
        _appUsageData = appUsageData;
      });
    } else {
      // Request permission if not granted
      await UsageTracker.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Usage Tracker Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Platform Version: $_platformVersion'),
              SizedBox(height: 8),
              Text('Has Permission: $_hasPermission'),
              SizedBox(height: 16),
              Text('App Usage Data (last 24 hours):'),
              Expanded(
                child: ListView.builder(
                  itemCount: _appUsageData.length,
                  itemBuilder: (context, index) {
                    String packageName = _appUsageData.keys.elementAt(index);
                    int timeInForeground = _appUsageData[packageName] ?? 0;
                    return ListTile(
                      title: Text(packageName),
                      subtitle: Text('Time in foreground: $timeInForeground ms'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Methods

### getPlatformVersion()

Returns the platform version of the Android device.

```
Future getPlatformVersion();
```

### hasPermission()

Checks whether the app has permission to access usage statistics.

```
Future hasPermission();
```

### requestPermission()

Requests the user to grant permission to access usage statistics. This opens the device's "Usage Access" settings.

```
Future requestPermission();
```

### getAppUsageDataInRange(DateTime startTime, DateTime endTime)

Retrieves the app usage data (foreground time) for all apps within the specified time range.

```
Future> getAppUsageDataInRange(
    DateTime startTime, DateTime endTime);
```

*   **startTime**: The start of the time range (e.g., `DateTime.now().subtract(Duration(days: 1))`).
*   **endTime**: The end of the time range (e.g., `DateTime.now()`).
*   **Returns**: A map where the key is the package name, and the value is the total time the app was in the foreground (in milliseconds).

## Troubleshooting

*   **Permission Issues**: If the app does not have the `PACKAGE_USAGE_STATS` permission, it will not be able to track app usage. Make sure the user grants permission via the "Usage Access" settings.
*   **No Data Returned**: If no usage data is returned, ensure that the time range is valid and that usage statistics are available for the requested period.

## Contribution

Feel free to fork the repo and submit pull requests for bug fixes or new features.
