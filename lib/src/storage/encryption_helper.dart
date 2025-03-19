import 'dart:convert';

import 'package:encrypt/encrypt.dart';

/// A helper class for encrypting and decrypting data
class EncryptionHelper {
  /// The encryption key used for all operations
  static final Key _key = Key.fromLength(32);

  /// The initialization vector for AES encryption
  static final IV _iv = IV.fromLength(16);

  /// The encrypter instance
  static final _encrypter = Encrypter(AES(_key));

  /// Encrypts a map to a string
  static String encryptMap(Map<String, dynamic> data) {
    final jsonString = json.encode(data);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypts a string to a map
  static Map<String, dynamic> decryptMap(String encryptedString) {
    final encrypted = Encrypted.fromBase64(encryptedString);
    final decryptedString = _encrypter.decrypt(encrypted, iv: _iv);
    return json.decode(decryptedString) as Map<String, dynamic>;
  }
}
