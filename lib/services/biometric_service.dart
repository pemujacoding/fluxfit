import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Check if the hardware is actually capable of biometrics
  static Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  // The actual "Show Popup" function
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Silakan verifikasi identitas Anda untuk masuk',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keeps auth alive if app goes to background
          biometricOnly: true, // Prevents using PIN/Pattern as fallback
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }
}
