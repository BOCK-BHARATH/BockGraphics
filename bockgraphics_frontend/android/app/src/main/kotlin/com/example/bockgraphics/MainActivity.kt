package com.example.bockgraphics

import android.content.ContentValues
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "file_downloader"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "saveToDownloads") {
                    val bytes = call.argument<ByteArray>("bytes")
                    val filename = call.argument<String>("filename")

                    if (bytes == null || filename == null) {
                        result.error("INVALID", "Missing data", null)
                        return@setMethodCallHandler
                    }

                    val resolver = contentResolver
                    val contentValues = ContentValues().apply {
                        put(MediaStore.MediaColumns.DISPLAY_NAME, filename)
                        put(
                            MediaStore.MediaColumns.MIME_TYPE,
                            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                        )
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/")
                        }
                    }

                    val uri = resolver.insert(
                        MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                        contentValues
                    )

                    uri?.let {
                        resolver.openOutputStream(it)?.use { stream ->
                            stream.write(bytes)
                        }
                        result.success(true)
                    } ?: result.error("FAILED", "Insert failed", null)
                }
            }
    }
}
