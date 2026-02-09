import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionHelper {
  // Simple obfuscation for local storage - NOT military grade encryption
  // In a real app, use secure storage (flutter_secure_storage)
  // But for this web-focused tool, simple encoding handles the requirement
  // to not store plain text passwords in local storage directly.

  static String encrypt(String text) {
    // Determine a simple key or salt mechanism if needed
    // For now, simple base64 to prevent casual reading
    return base64Encode(utf8.encode(text));
  }

  static String decrypt(String encrypted) {
    return utf8.decode(base64Decode(encrypted));
  }

  // Hashing for validation (one-way)
  static String hash(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
