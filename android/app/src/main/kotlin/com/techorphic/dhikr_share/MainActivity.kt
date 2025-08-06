package com.techorphic.dhikr_share

import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "speech_recognition"
    private var speechRecognizer: SpeechRecognizer? = null
    private var isListening = false
    private var processedPhrases = mutableSetOf<String>()
    private var lastFullText = ""
    private var totalWordsProcessed = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger ?: return

        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    startListening()
                    result.success(null)
                }
                "stopListening" -> {
                    stopListening()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startListening() {
        println("DEBUG: startListening() called, isListening = $isListening")
        if (isListening) {
            println("DEBUG: Already listening, returning")
            return
        }
        
        // Reset tracking variables when starting fresh
        processedPhrases.clear()
        lastFullText = ""
        totalWordsProcessed = 0
        println("DEBUG: Reset tracking variables")
        
        if (speechRecognizer == null) {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
            println("DEBUG: Created new SpeechRecognizer")
        }

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
            // Remove strict silence settings that might be causing issues
            // putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 1000)
            // putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 1000)
        }
        println("DEBUG: Created recognition intent")

        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                isListening = true
                println("DEBUG: onReadyForSpeech - Ready to listen")
            }
            
            override fun onBeginningOfSpeech() {
                println("DEBUG: onBeginningOfSpeech - User started speaking")
            }
            
            override fun onRmsChanged(rmsdB: Float) {
                // Uncomment for very verbose audio level debugging
                // println("DEBUG: onRmsChanged - Audio level: $rmsdB")
            }
            
            override fun onBufferReceived(buffer: ByteArray?) {
                println("DEBUG: onBufferReceived - Audio buffer received")
            }
            
            override fun onEndOfSpeech() {
                isListening = false
                println("DEBUG: onEndOfSpeech - User stopped speaking")
            }
            
            override fun onError(error: Int) {
                isListening = false
                val errorMessage = when (error) {
                    SpeechRecognizer.ERROR_AUDIO -> "Audio recording error"
                    SpeechRecognizer.ERROR_CLIENT -> "Client side error"
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Insufficient permissions"
                    SpeechRecognizer.ERROR_NETWORK -> "Network error"
                    SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "Network timeout"
                    SpeechRecognizer.ERROR_NO_MATCH -> "No match found"
                    SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "RecognitionService busy"
                    SpeechRecognizer.ERROR_SERVER -> "Server error"
                    SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "No speech input"
                    else -> "Unknown error: $error"
                }
                println("DEBUG: onError - $errorMessage")
                
                // Don't restart on "No match found" errors too frequently
                if (error == SpeechRecognizer.ERROR_NO_MATCH) {
                    println("DEBUG: No match found - will restart after longer delay")
                    android.os.Handler().postDelayed({
                        if (speechRecognizer != null) {
                            println("DEBUG: Restarting recognition after no match error")
                            startListening()
                        }
                    }, 500)
                } else {
                    // Only restart if not manually stopped
                    if (speechRecognizer != null) {
                        android.os.Handler().postDelayed({
                            if (speechRecognizer != null) {
                                println("DEBUG: Restarting recognition after error")
                                startListening()
                            }
                        }, 100)
                    }
                }
            }

            override fun onResults(results: Bundle) {
                val matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                println("DEBUG: onResults - Got ${matches?.size} results")
                matches?.forEachIndexed { index, match ->
                    println("DEBUG: Result $index: '$match'")
                }
                
                matches?.firstOrNull()?.let { text ->
                    println("DEBUG: Processing final result: '$text'")
                    processFinalResult(text)
                }
                isListening = false
                // Restart listening after a short delay
                android.os.Handler().postDelayed({
                    if (speechRecognizer != null) {
                        println("DEBUG: Restarting recognition after results")
                        startListening()
                    }
                }, 100)
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                println("DEBUG: onPartialResults - Got ${matches?.size} partial results")
                matches?.forEachIndexed { index, match ->
                    println("DEBUG: Partial result $index: '$match'")
                }
                
                // Process the first non-empty result
                matches?.firstOrNull { it.isNotEmpty() }?.let { text ->
                    println("DEBUG: Processing partial result: '$text'")
                    processPartialResult(text)
                }
                
                // If no matches, try to process any available text
                if (matches.isNullOrEmpty()) {
                    println("DEBUG: No partial results available")
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) {
                println("DEBUG: onEvent - Event type: $eventType")
            }
        })

        println("DEBUG: Starting speech recognition...")
        speechRecognizer?.startListening(intent)
    }

    private fun processPartialResult(text: String) {
        println("DEBUG: processPartialResult called with: '$text'")
        val cleanText = text.trim().lowercase()
        println("DEBUG: Cleaned text: '$cleanText'")
        println("DEBUG: Last full text: '$lastFullText'")
        
        if (cleanText == lastFullText) {
            println("DEBUG: Text unchanged, skipping processing")
            return
        }
        
        // Try multiple patterns for better recognition
        val patterns = listOf(
            "\\bsubhanallah\\b",
            "\\bsubhan allah\\b",
            "\\bsub han allah\\b",
            "\\bsubhanalah\\b",
            "\\bsobhan allah\\b",
            "\\bsobhanallah\\b",
            // Test patterns for debugging
            "\\bhello\\b",
            "\\bworld\\b",
            "\\bhello world\\b",
            "\\btest\\b"
        )
        
        var currentCount = 0
        patterns.forEach { pattern ->
            val matches = Regex(pattern).findAll(cleanText).count()
            if (matches > 0) {
                println("DEBUG: Pattern '$pattern' found $matches matches")
                currentCount = maxOf(currentCount, matches)
            }
        }
        
        println("DEBUG: Found $currentCount matches in current text")
        println("DEBUG: Previously processed: $totalWordsProcessed")
        
        // Only process if we have new instances
        if (currentCount > totalWordsProcessed) {
            val newCount = currentCount - totalWordsProcessed
            println("DEBUG: New count to add: $newCount")
            totalWordsProcessed = currentCount
            lastFullText = cleanText
            
            // Send the new count immediately
            sendCountToFlutter(newCount)
        } else {
            println("DEBUG: No new instances found")
        }
    }

    private fun processFinalResult(text: String) {
        println("DEBUG: processFinalResult called with: '$text'")
        val cleanText = text.trim().lowercase()
        println("DEBUG: Final cleaned text: '$cleanText'")
        
        // Try multiple patterns for better recognition
        val patterns = listOf(
            "\\bsubhanallah\\b",
            "\\bsubhan allah\\b",
            "\\bsub han allah\\b",
            "\\bsubhanalah\\b",
             "\\bsubhan\\b",
              "\\ballah\\b",
            "\\bsobhan allah\\b",
            "\\bsobhanallah\\b",
            // Test patterns for debugging
            "\\bhello\\b",
            "\\bworld\\b",
            "\\bhello world\\b",
            "\\btest\\b"
        )
        
        var finalCount = 0
        patterns.forEach { pattern ->
            val matches = Regex(pattern).findAll(cleanText).count()
            if (matches > 0) {
                println("DEBUG: Final pattern '$pattern' found $matches matches")
                finalCount = maxOf(finalCount, matches)
            }
        }
        
        println("DEBUG: Final count: $finalCount, Previously processed: $totalWordsProcessed")
        
        // If final count is different from what we processed in partials, send the difference
        if (finalCount != totalWordsProcessed) {
            val difference = finalCount - totalWordsProcessed
            println("DEBUG: Final difference to add: $difference")
            if (difference > 0) {
                sendCountToFlutter(difference)
            }
        } else {
            println("DEBUG: Final count matches processed count, no additional increment needed")
        }
        
        // Reset for next recognition session
        processedPhrases.clear()
        totalWordsProcessed = 0
        lastFullText = ""
        println("DEBUG: Reset tracking variables for next session")
    }

    private fun sendCountToFlutter(count: Int) {
        println("DEBUG: sendCountToFlutter called with count: $count")
        if (count > 0) {
            val messenger = flutterEngine?.dartExecutor?.binaryMessenger
            if (messenger != null) {
                println("DEBUG: Sending count $count to Flutter")
                MethodChannel(messenger, CHANNEL).invokeMethod("onSpeechResult", count)
            } else {
                println("DEBUG: ERROR - Messenger is null, cannot send to Flutter")
            }
        } else {
            println("DEBUG: Count is 0 or negative, not sending to Flutter")
        }
    }

    private fun stopListening() {
        println("DEBUG: stopListening() called")
        isListening = false
        speechRecognizer?.stopListening()
        speechRecognizer?.cancel()
        speechRecognizer?.destroy()
        speechRecognizer = null
        
        // Reset tracking variables
        processedPhrases.clear()
        lastFullText = ""
        totalWordsProcessed = 0
        println("DEBUG: Speech recognition stopped and cleaned up")
    }
}