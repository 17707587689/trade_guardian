package com.example.trade_guardian

import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.trade_guardian/app_launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchApp") {
                val packageName = call.argument<String>("package")
                if (packageName == null) {
                    result.error("INVALID_ARG", "Package name is required", null)
                    return@setMethodCallHandler
                }
                try {
                    val pm: PackageManager = packageManager
                    val launchIntent = pm.getLaunchIntentForPackage(packageName)
                    if (launchIntent != null) {
                        startActivity(launchIntent)
                        result.success(true)
                    } else {
                        result.error("APP_NOT_FOUND", "App not installed: $packageName", null)
                    }
                } catch (e: Exception) {
                    result.error("LAUNCH_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}