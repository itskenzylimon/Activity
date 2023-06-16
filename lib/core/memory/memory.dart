import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:activity/core/helpers/logger.dart';

import '../helpers/isplatforms.dart';

/// Memory is a class that is used to store data in a file.
class Memory {

  /// [Memory] constructor.
  /// filename is the name of the file you want to store the data in.
  Memory({String? filename}) :
        _filename = filename;
  final String? _filename;

  static final Memory memory = Memory();

  /// Check if [Memory] is empty.
  Future<bool> get isDataEmpty async {
    Map<String, dynamic> data = await stageMemory();
    return data.isEmpty;
  }

  Future<bool> get isMemoryEmpty => isDataEmpty;

  /// Get all data from [Memory].
  ///
  /// Will return empty list if entries are not found
  Future<Map<String, dynamic>> stageMemory() async {
    if (_filename != null) {
      FileStorage fileStorage = FileStorage(_filename!);

      return await fileStorage.read();
    }
    return {};
  }

  /// Get all data from [Memory].
  ///
  /// Will return empty list if entries are not found
  Future<List> readMemories() async {
    Map<String, dynamic> data = await stageMemory();
    return data.entries.toList();
  }


  /// Get data from [Memory].
  ///
  /// [key] is the key of the entry you want to get, this is required and is
  /// used to represent the entry as the unique identifier.
  ///
  /// [value] is set to true by default. If you want to get the entire entry you
  /// can set this to false. This will return the entire entry as a Map. containing
  /// the [key], [value], [createdAt], [updatedAt] and [expiresAt].
  ///
  /// Will return [null] if entry is not found or Map if [value] is set to false.
  /// and the value if [value] is set to true.
  Future readMemory(String key, { bool value = true }) async {
    Map<String, dynamic> data = await stageMemory();
    if(value){
      if(data.containsKey(key)){
        return data[key]['value'];
      } else {
        return null;
      }
    } else {
      if(data.containsKey(key)){
        return data[key];
      } else {
        return null;
      }
    }
  }

  /// It creates an entry in [Memory] if the value does not exist.
  ///
  /// If the [key] is not found it returns [true].
  ///
  /// If the [key] is found it returns [false].
  ///
  /// [persist] is set to true by default to save the data to the file
  ///
  /// If [persist] is set to false, it will not save the data to the file.
  ///
  /// [duration] is set to null by default. If you want to set the expiry time
  /// pass a valid [Duration] object.
  ///
  /// Use this in situations where you are uncertain if a [key] exists and
  /// your not planning to update the current value.
  Future<Map> insertMemory<T>(String key,
      T mem, {Duration? duration, bool persist = true}) async {
    Map<String, dynamic> data = await stageMemory();
    if(persist){
        FileStorage fileStorage = FileStorage(_filename ?? 'active_t');
        var entry = {
          'value': mem,
          'createdAt': DateTime.now().toIso8601String(),
        };
        /// If duration is not null, set the expiry time
        if(duration != null && duration.inSeconds > 0){
          entry.addAll({'expiresAt': _setMemoryExpiry(duration)});
        }
        data.addAll({key: entry});
        await fileStorage.save(data);
        return data[key];
      } else {
        /// Set the value of the key to mem
        /// Set the createdAt time
        var entry = {
          'value': mem,
          'createdAt': DateTime.now().toIso8601String(),
        };
        /// If duration is not null, set the expiry time
        if(duration != null && duration.inSeconds > 0){
          entry.addAll({'expiresAt': _setMemoryExpiry(duration)});
        }
        data.addAll({key: entry});
        return data[key];
      }
  }

  /// Performs a create when a [key] does not exist and an update when it does.
  ///
  /// This is a safer method to use when you are uncertain if a [key] exists.
  ///
  /// Out of the hood, this function performs a createMemory if the [key] does
  /// and updateMemory if it does.
  ///
  /// If a value exist it does an update in initialize.
  Future upsertMemory<T>(String key,
      T mem, {Duration? duration}) async {
    Map<String, dynamic> data = await stageMemory();
    if(data.containsKey(key)){
      return await _updateMemory(key, mem);
    } else {
      return await insertMemory(key, mem, duration: duration);
    }
  }

  /// Updates a [key] value in [Memory] with the new value.
  ///
  /// If the [key] is not found it returns [false].
  ///
  /// If the [key] is found it returns [true].
  Future<T> _updateMemory<T>(String key, T mem, {bool persist = true}) async {
    Map<String, dynamic> data = await stageMemory();

    printError(data);

    /// Set the value of the key to mem
    /// Set the createdAt time
    Map entry = {};
    entry.addAll(data[key]);
    entry['value'] = mem;
    entry['updatedAt'] = DateTime.now().toIso8601String();

      if(persist){
        FileStorage fileStorage = FileStorage(_filename!);
        data.addAll({key: entry});
        await fileStorage.save(data);
        return data[key]['value'];
      } else {
        return data[key]['value'];
      }
  }

  /// Removes entry from [Memory].
  ///
  /// Checks if a key exists in [Memory] before removing entry
  Future deleteMemory(String key) async {
    Map<String, dynamic> data = await stageMemory();
    if(data.containsKey(key)){
      data.remove(key);
      FileStorage fileStorage = FileStorage(_filename!);
      await fileStorage.save(data);
    }
  }

  /// Removes all values stored on [Memory]
  ///
  /// Clears every entry
  Future<void> resetMemory() async {
    FileStorage fileStorage = FileStorage(_filename!);
    await fileStorage.save({});
  }



  /// Checks if a key exists in Active Memory
  ///
  /// returns [true] if key is found.
  ///
  /// returns [false] if value does not exist.
  Future hasMemory(String key) async {
    Map<String, dynamic> data = await stageMemory();
    return data.isEmpty;
  }

  /// Sets Active Memory entry expiry date
  DateTime? _setMemoryExpiry(Duration? expiry) =>
      expiry != null ? DateTime.now().add(expiry) : null;

}

/// File Storage Class for storing data to a file, it uses a custom [encrypt]
/// and [decrypt] when saving and reading data.
class FileStorage {
  final File _file;
  FileStorage(String filename) : _file = File(filename);

  bool isAndroid = isAndroidPlatform();
  static const MethodChannel memoryChannel = MethodChannel('activity_mobile_platform_channel');

  /// Saves data to a file.
  Future<void> save(Map<String, dynamic> data) async {
    if(isAndroid == true){
      return await saveMobile(data);
    }
    String stringEncrypted = encrypt(jsonEncode(data), 134523452346);
    var encodedData = utf8.encode(stringEncrypted);
    var byteData = Uint8List.fromList(encodedData);
    await _file.writeAsBytes(byteData);
  }

  /// Reads data from a file.
  Future<Map<String, dynamic>> read() async {
    if(isAndroid == true){
      return await readMobile();
    }
    if (await _file.exists()) {
      var encodedData = await _file.readAsBytes();
      var decodedData = utf8.decode(encodedData);
      String stringDecrypt = decrypt(decodedData, 134523452346);
      return jsonDecode(stringDecrypt) as Map<String, dynamic>;
    } else {
      await save({});
      return {};
    }

  }

  /// Saves data to mobile file.
  Future<void> saveMobile(Map<String, dynamic> data) async {
    String stringEncrypted = encrypt(jsonEncode(data), 134523452346);
    var encodedData = utf8.encode(stringEncrypted);
    var byteData = Uint8List.fromList(encodedData);
    await memoryChannel.invokeMethod('create', byteData);
  }

  /// Reads data from mobile file.
  Future<Map<String, dynamic>> readMobile() async {
    var encodedData = await memoryChannel.invokeMethod('read', {'memoryPath': File});
    var decodedData = utf8.decode(encodedData);
    String stringDecrypt = decrypt(decodedData, 134523452346);

    return jsonDecode(stringDecrypt) as Map<String, dynamic>;
  }

  /// Deletes a file.
  Future<FileSystemEntity> delete() async {
    return _file.delete();
  }

  /// Encrypts a string.
  /// [plaintext] is the string to be encrypted.
  /// [key] is the key to be used for encryption.
  String encrypt(String plaintext, int key) {
    StringBuffer ciphertext = StringBuffer();
    for (int i = 0; i < plaintext.length; i++) {
      int c = plaintext.codeUnitAt(i);
      c = (c + key) % 65536; // Add key and wrap around
      ciphertext.write(String.fromCharCode(c));
    }
    return ciphertext.toString();
  }

  /// Decrypts a string.
  /// [ciphertext] is the string to be decrypted.
  /// [key] is the key to be used for decryption.
  String decrypt(String ciphertext, int key) {
    StringBuffer plaintext = StringBuffer();
    for (int i = 0; i < ciphertext.length; i++) {
      int c = ciphertext.codeUnitAt(i);
      c = (c - key) % 65536; // Subtract key and wrap around
      plaintext.write(String.fromCharCode(c));
    }
    return plaintext.toString();
  }


}