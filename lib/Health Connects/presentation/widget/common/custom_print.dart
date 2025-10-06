import 'package:flutter/foundation.dart';

customPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[37m$message\x1B[0m"); //white
  }
}

void successPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[32m$message\x1B[0m"); //Green
  }
}

void errorPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[31m$message\x1B[0m"); //red
  }
}

void warningPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[33m$message\x1B[0m"); //yellow
  }
}

void alertPrint(String message) {
  if (!kReleaseMode) {
    return debugPrint("\x1B[38;5;214m$message\x1B[0m"); // Orange
  }
}
