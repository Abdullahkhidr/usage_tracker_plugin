package com.example.usage_tracker

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.app.AppOpsManager
import android.os.Build
import androidx.annotation.RequiresApi
import android.app.usage.UsageStatsManager
import android.content.Context
import android.app.usage.UsageEvents


class UsageTrackerPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "usage_tracker")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "hasPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    result.success(hasUsageStatsPermission())
                } else {
                    result.error("UNSUPPORTED", "Unsupported Android version", null)
                }
            }
            "requestPermission" -> {
                requestUsageStatsPermission()
                result.success(null)
            }
            "getAppUsageDataInRange" -> {
                val startTime = call.argument<Long>("startTime") ?: return result.error("INVALID_ARGUMENT", "Missing startTime", null)
                val endTime = call.argument<Long>("endTime") ?: return result.error("INVALID_ARGUMENT", "Missing endTime", null)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    result.success(getAppUsageDurationInRange(startTime, endTime))
                } else {
                    result.error("UNSUPPORTED", "Unsupported Android version", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
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

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getAppUsageDurationInRange(startTime: Long, endTime: Long): List<Map<String, Any?>> {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        
        val packageManager = context.packageManager
        val appUsageData = mutableListOf<Map<String, Any?>>()
        
        if (usageStatsList.isNullOrEmpty()) {
            return appUsageData
        }

        for (usageStats in usageStatsList) {
            try {
                val appInfo = packageManager.getApplicationInfo(usageStats.packageName, 0)
                
                val appData = mapOf(
                    "packageName" to usageStats.packageName,
                    "appName" to packageManager.getApplicationLabel(appInfo).toString(),
                    "totalTimeInForeground" to usageStats.totalTimeInForeground,
                    "versionName" to packageManager.getPackageInfo(usageStats.packageName, 0).versionName, 
                    "versionCode" to packageManager.getPackageInfo(usageStats.packageName, 0).versionCode
                )
                appUsageData.add(appData)
            } catch (e: Exception) {
                
            }
        }

        return appUsageData

    }

}
