package com.thrivexcode.flutter_home_widget

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "flutter_thrivexcode/widget"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Gunakan satu instance global
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "openNoteDetail") {
                val noteId = call.arguments as? String
                Log.d("WidgetClick", "Flutter received noteId: $noteId")
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Tangani intent pertama kali (app baru dibuka dari widget)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    // Fungsi gabungan untuk menangani intent awal & baru
    private fun handleIntent(intent: Intent) {
        val noteId = intent.getStringExtra("noteId")  // ✅ gunakan key yang sama
        if (noteId != null) {
            Log.d("WidgetClick", "Intent noteId: $noteId")
            methodChannel?.invokeMethod("openNoteDetail", noteId)
        }
    }
}
