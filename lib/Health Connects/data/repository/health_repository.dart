import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:health_connect/Health%20Connects/presentation/widget/common/custom_print.dart';

import '../../domain/entities/data_point.dart';

class HealthRepository {
  static const _eventChannel = EventChannel(
    'com.example.health_connect/health_data',
  );

  static const _methodChannel = MethodChannel(
    'com.example.health_connect/method_channel',
  );

  Stream<DataPoint> get healthDataStream {
    alertPrint("Health Data stream");
    return _eventChannel.receiveBroadcastStream().map((dynamic event) {
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(event);
      final String type = dataMap['type'];
      final num value = dataMap['value'];
      final int timestamp = dataMap['timestamp'];

      successPrint("DATA POINT TYPE: $type - Value$value");
      return DataPoint(
        type: type,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        value: value.toDouble(),
      );
    });
  }

  Future<bool> requestPermissions() async {
    try {
      final bool? granted = await _methodChannel.invokeMethod(
        'requestPermissions',
      );
      successPrint("Permission Granted on the Repository");
      return granted ?? false;
    } on PlatformException catch (e) {
      debugPrint("Failed to request permissions: '${e.message}'.");
      return false;
    }
  }

  Future<bool> checkPermissions() async {
    try {
      alertPrint("Checking Permission");
      final bool? granted = await _methodChannel.invokeMethod(
        'checkPermissions',
      );
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }
}
