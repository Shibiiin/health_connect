package com.example.health_connect

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.time.Instant

class MainActivity : FlutterActivity() {

    companion object {
        private const val HEALTH_EVENT_CHANNEL = "com.example.health_connect/health_data"
        private const val HEALTH_METHOD_CHANNEL = "com.example.health_connect/method_channel"
        private val PERMISSIONS = arrayOf(
            "android.permission.health.READ_STEPS",
            "android.permission.health.READ_HEART_RATE"
        )
        private const val REQUEST_CODE_PERMISSIONS = 1001
    }

    private lateinit var healthConnectClient: HealthConnectClient
    private val coroutineScope = CoroutineScope(Dispatchers.Main)
    private var pollingJob: Job? = null
    private var permissionResult: MethodChannel.Result? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        healthConnectClient = HealthConnectClient.getOrCreate(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, HEALTH_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    eventSink = events
                    startPollingHealthData()
                }

                override fun onCancel(arguments: Any?) {
                    stopPollingHealthData()
                    eventSink = null
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEALTH_METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> coroutineScope.launch {
                    result.success(hasPermissions())
                }
                "requestPermissions" -> {
                    permissionResult = result
                    ActivityCompat.requestPermissions(this, PERMISSIONS, REQUEST_CODE_PERMISSIONS)
                }
                "promptHealthConnectUpdate" -> {
                    promptHealthConnectUpdate()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startPollingHealthData() {
        pollingJob?.cancel()
        pollingJob = coroutineScope.launch {
            while (isActive) {
                if (hasPermissions()) {
                    eventSink?.let { readHealthData(it) }
                }
                delay(5000)
            }
        }
    }

    private fun stopPollingHealthData() {
        pollingJob?.cancel()
        pollingJob = null
    }

    private suspend fun hasPermissions(): Boolean {
        return PERMISSIONS.all {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    private suspend fun readHealthData(events: EventChannel.EventSink) {
        val startTime = Instant.now().minusSeconds(3600)
        val endTime = Instant.now()
        try {
            val stepsResponse = healthConnectClient.readRecords(
                ReadRecordsRequest(
                    StepsRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
                )
            )
            for (stepRecord in stepsResponse.records) {
                val dataMap = mapOf(
                    "type" to "steps",
                    "value" to stepRecord.count,
                    "timestamp" to stepRecord.startTime.toEpochMilli()
                )
                runOnUiThread { events.success(dataMap) }
            }
            val heartRateResponse = healthConnectClient.readRecords(
                ReadRecordsRequest(
                    HeartRateRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
                )
            )
            for (hrRecord in heartRateResponse.records) {
                for (sample in hrRecord.samples) {
                    val dataMap = mapOf(
                        "type" to "heartRate",
                        "value" to sample.beatsPerMinute,
                        "timestamp" to sample.time.toEpochMilli()
                    )
                    runOnUiThread { events.success(dataMap) }
                }
            }
        } catch (e: Exception) {
            runOnUiThread { events.error("ERROR", "Failed to read health data", e.message) }
        }
    }

    private fun promptHealthConnectUpdate() {
        val providerPackageName = "com.google.android.apps.healthdata"
        val uriString = "market://details?id=$providerPackageName&url=healthconnect%3A%2F%2Fonboarding"
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setPackage("com.android.vending")
            data = Uri.parse(uriString)
            putExtra("overlay", true)
            putExtra("callerId", packageName)
        }
        startActivity(intent)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_PERMISSIONS && permissionResult != null) {
            val granted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            permissionResult?.success(granted)
            permissionResult = null
            if (granted) {
                eventSink?.let {
                    coroutineScope.launch {
                        readHealthData(it)
                    }
                }
            }
        }
    }
}
