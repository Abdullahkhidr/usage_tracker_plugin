package akm.usage_tracker.plugin

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class UsageTrackerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "usage_tracker")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "hasPermission" -> {
                result.success(hasUsageStatsPermission())
            }

            "requestPermission" -> {
                requestUsageStatsPermission()
                result.success(null)
            }

            "getAppUsageDataInRange" -> {
                val startTime = call.argument<Long>("startTime") ?: return result.error(
                    "INVALID_ARGUMENT",
                    "Missing startTime",
                    null
                )
                val endTime = call.argument<Long>("endTime") ?: return result.error(
                    "INVALID_ARGUMENT",
                    "Missing endTime",
                    null
                )
                result.success(getAppUsageDurationInRange(startTime, endTime))
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP_MR1)
    private fun getAppUsageDurationInRange(
        startTime: Long,
        endTime: Long
    ): List<Map<String, Any?>> {
        val usageStatsManager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val appUsageData = mutableMapOf<String, Long>()

        for (usageStats in usageStatsList) {
            try {
                appUsageData[usageStats.packageName] =
                    (appUsageData[usageStats.packageName] ?: 0L) + usageStats.totalTimeInForeground
            } catch (e: Exception) {
                Log.e("UsageTracker", "Error getting app usage data: ${e.message}")
            }
        }

        return appUsageData.map { (packageName, totalTime) ->
            mapOf(
                "packageName" to packageName,
                "totalTimeInForeground" to totalTime
            )
        }
    }
}
