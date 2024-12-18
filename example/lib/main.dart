import 'package:flutter/material.dart';
import 'package:usage_tracker/usage_tracker.dart';

void main() {
  runApp(const UsageTrackerExample());
}

class UsageTrackerExample extends StatelessWidget {
  const UsageTrackerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppUsageScreen(),
    );
  }
}

class AppUsageScreen extends StatefulWidget {
  const AppUsageScreen({super.key});

  @override
  State<AppUsageScreen> createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends State<AppUsageScreen> {
  Map<String, int> _appUsageData = {};

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetchData();
  }

  Future<void> _checkPermissionsAndFetchData() async {
    bool hasPermission = await UsageTracker.hasPermission();

    if (!hasPermission) {
      await UsageTracker.requestPermission();
      hasPermission = await UsageTracker.hasPermission();
    }

    if (hasPermission) {
      final now = DateTime.now();
      final data = await UsageTracker.getAppUsageDataInRange(
          DateTime(now.year, now.month, now.day), now);

      setState(() {
        _appUsageData = data;
      });
    } else {
      debugPrint("Permission not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Usage Data")),
      body: ListView.builder(
        itemCount: _appUsageData.length,
        itemBuilder: (context, index) {
          final appInfo = _appUsageData.entries.toList()[index];
          return Padding(
            padding: const EdgeInsets.all(8.0).copyWith(bottom: 2),
            child: ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black45),
                  borderRadius: BorderRadius.circular(10)),
              title: Text(appInfo.key,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "Usage: ${(appInfo.value / 1000 / 60).toStringAsFixed(2)} minutes"),
            ),
          );
        },
      ),
    );
  }
}
