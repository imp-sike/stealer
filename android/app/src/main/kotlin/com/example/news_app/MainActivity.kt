package com.example.news_app

import io.flutter.embedding.android.FlutterActivity
import android.provider.CallLog
import android.content.ContentResolver
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import android.os.Bundle


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.news_app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getCallLogs") {
                val callLogs = getCallLogs()
                result.success(callLogs)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getCallLogs(): List<Map<String, String>> {
        val callLogs = mutableListOf<Map<String, String>>()
        val resolver: ContentResolver = contentResolver
        val cursor = resolver.query(
            CallLog.Calls.CONTENT_URI, null, null, null, CallLog.Calls.DATE + " DESC"
        )

        cursor?.use {
            while (it.moveToNext()) {
                val number = it.getString(it.getColumnIndexOrThrow(CallLog.Calls.NUMBER))
                val duration = it.getString(it.getColumnIndexOrThrow(CallLog.Calls.DURATION))
                val type = it.getString(it.getColumnIndexOrThrow(CallLog.Calls.TYPE))
                val date = it.getString(it.getColumnIndexOrThrow(CallLog.Calls.DATE))

                val callLog = mapOf(
                    "number" to number,
                    "duration" to duration,
                    "type" to type,
                    "date" to date
                )
                callLogs.add(callLog)
            }
        }
        return callLogs
    }
}
