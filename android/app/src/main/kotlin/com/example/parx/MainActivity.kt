package com.example.parx

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val DOWNLOAD_CHANNEL = "com.example.parx/download"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val downloadChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOAD_CHANNEL)
        downloadChannel.setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                try {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any>
                    val sourcePath = args?.get("sourcePath") as? String
                    val fileName = args?.get("fileName") as? String
                    if (sourcePath.isNullOrEmpty() || fileName.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "sourcePath and fileName required", null)
                        return@setMethodCallHandler
                    }
                    val sourceFile = File(sourcePath)
                    if (!sourceFile.exists()) {
                        result.error("FILE_NOT_FOUND", "Source file not found", null)
                        return@setMethodCallHandler
                    }
                    val savedPath = saveFileToDownloads(sourceFile, fileName)
                    if (savedPath != null) {
                        result.success(mapOf("success" to true, "path" to savedPath))
                    } else {
                        result.error("SAVE_FAILED", "Could not save to Downloads", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveFileToDownloads(sourceFile: File, fileName: String): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveViaMediaStore(sourceFile, fileName)
        } else {
            saveViaLegacy(sourceFile, fileName)
        }
    }

    @Suppress("DEPRECATION")
    private fun saveViaLegacy(sourceFile: File, fileName: String): String? {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        if (!downloadsDir.exists()) downloadsDir.mkdirs()
        val destFile = File(downloadsDir, fileName)
        return try {
            sourceFile.copyTo(destFile, overwrite = true)
            destFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun saveViaMediaStore(sourceFile: File, fileName: String): String? {
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            }
        }
        val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues) ?: return null
        return try {
            contentResolver.openOutputStream(uri)?.use { out: OutputStream ->
                FileInputStream(sourceFile).use { it.copyTo(out) }
            }
            Environment.getExternalStorageDirectory().absolutePath + "/Download/" + fileName
        } catch (e: Exception) {
            e.printStackTrace()
            contentResolver.delete(uri, null, null)
            null
        }
    }
}
