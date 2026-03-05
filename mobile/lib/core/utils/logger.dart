import 'package:flutter/foundation.dart';

void logInfo(String message) {
  debugPrint('[INFO] $message');
}

void logWarn(String message) {
  debugPrint('[WARN] $message');
}

void logError(String message) {
  debugPrint('[ERROR] $message');
}
