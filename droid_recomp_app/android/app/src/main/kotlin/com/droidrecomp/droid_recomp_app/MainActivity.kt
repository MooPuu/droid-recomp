package com.droidrecomp.droid_recomp_app

import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.droidrecomp/launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAppInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        try {
                            packageManager.getPackageInfo(packageName, 0)
                            result.success(true)
                        } catch (e: PackageManager.NameNotFoundException) {
                            result.success(false)
                        }
                    } else {
                        result.error("INVALID_ARG", "Package name is null", null)
                    }
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        try {
                            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                            if (launchIntent != null) {
                                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(launchIntent)
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            result.error("LAUNCH_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARG", "Package name is null", null)
                    }
                }
                "getInstalledPackages" -> {
                    try {
                        val packages = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
                        val packageNames = packages.map { it.packageName }
                        result.success(packageNames)
                    } catch (e: Exception) {
                        result.success(emptyList<String>())
                    }
                }
                "getInstalledApps" -> {
                    try {
                        val intent = Intent(Intent.ACTION_MAIN, null).apply {
                            addCategory(Intent.CATEGORY_LAUNCHER)
                        }
                        val resolveInfos = packageManager.queryIntentActivities(intent, 0)
                        val appList = mutableListOf<Map<String, String>>()
                        val myPackage = applicationContext.packageName
                        for (info in resolveInfos) {
                            val pkg = info.activityInfo.packageName
                            if (pkg != myPackage) {
                                val label = info.loadLabel(packageManager).toString()
                                appList.add(mapOf("packageName" to pkg, "label" to label))
                            }
                        }
                        appList.sortBy { it["label"]?.lowercase() ?: "" }
                        result.success(appList)
                    } catch (e: Exception) {
                        result.success(emptyList<Map<String, String>>())
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
