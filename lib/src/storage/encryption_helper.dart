import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// A helper class for encrypting and decrypting data using simple XOR cipher
/// Note: This is a basic implementation for backward compatibility with encrypted data.
/// For production use, consider using a more secure encryption method.
class EncryptionHelper {
  /// The encryption key derived from a fixed seed
  static final Uint8List _key = _generateKey();

  /// Generate a consistent key for encryption/decryption
  static Uint8List _generateKey() {
    final bytes = utf8.encode('GetXStorage_Default_Key_32Bytes');
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  /// Encrypts a map to a base64 string using XOR cipher
  static String encryptMap(Map<String, dynamic> data) {
    final jsonString = json.encode(data);
    final bytes = utf8.encode(jsonString);
    final encrypted = _xorCipher(bytes);
    return base64.encode(encrypted);
  }

  /// Decrypts a base64 string to a map using XOR cipher
  static Map<String, dynamic> decryptMap(String encryptedString) {
    final encrypted = base64.decode(encryptedString);
    final decrypted = _xorCipher(encrypted);
    final decryptedString = utf8.decode(decrypted);
    return json.decode(decryptedString) as Map<String, dynamic>;
  }

  /// Simple XOR cipher for encryption/decryption
  static Uint8List _xorCipher(List<int> data) {
    final result = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      result[i] = data[i] ^ _key[i % _key.length];
    }
    return result;
  }
}
