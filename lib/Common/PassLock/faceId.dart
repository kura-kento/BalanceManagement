import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class FaceId {
  static LocalAuthentication localAuth = LocalAuthentication();

  static Future<List<BiometricType?>> _getAvailableBiometricTypes() async {
    List<BiometricType?> availableBiometricTypes;
    try {
      availableBiometricTypes = await localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      // TODO
      availableBiometricTypes = [];
    }
    return availableBiometricTypes;
  }

  static Future<bool> authenticate() async {
    bool result = false;

    List<BiometricType?> availableBiometricTypes = await _getAvailableBiometricTypes();

    try {
      if (availableBiometricTypes.contains(BiometricType.face)
          || availableBiometricTypes.contains(BiometricType.fingerprint)) {
        result = await localAuth.authenticate(localizedReason: "認証してください");
      }
    } on PlatformException catch (e) {
      // TODO
    }
    return result;
  }
}