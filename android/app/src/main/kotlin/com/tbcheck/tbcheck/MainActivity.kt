package com.tbcheck.tbcheck

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tbcheck.tbcheck/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "extractMfcc") {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("INVALID_ARGUMENT", "Audio file path is required", null)
                    return@setMethodCallHandler
                }
                
                // Run MFCC extraction on a background thread to prevent UI lag
                Thread {
                    try {
                        val extractor = MfccExtractor()
                        val mfccData = extractor.extractMfcc(path)
                        runOnUiThread {
                            result.success(mfccData)
                        }
                    } catch (e: Exception) {
                        runOnUiThread {
                            result.error("MFCC_EXTRACTION_ERROR", e.localizedMessage, null)
                        }
                    }
                }.start()
            } else {
                result.notImplemented()
            }
        }
    }
}
