import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:activity/core/helpers/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'memory_functions.dart';

/// Memory is a class that is used to store data in a file.
class Memory {
  String? _filename;
  String? _filePath;
  ///to instantiate call await Memory.instance(filename:"filename.extension").initMemory(); in main() main.dart
  ///in other parts of the app, get instaance by calling Memory memory = Memory.instance();
  /// [instance] is a [Memory] factory method. This will instantiate a singleton of the [Memory] class appwide
  /// [filename] is the name of the file you want to store the data in. this can have an extension e.g appdata.txt
  ///You cannot override [filename] once it is set

  static Memory? _instance;
  static Memory instance({String? filename}) {
    _instance ??= Memory(filename: filename );
    return _instance!;
  }
  /// [Memory] constructor.
  /// filename is the name of the file you want to store the data in.
  Memory({String? filename}) {
    ///You cannot override [filename] once it is set
    _filename = _filename ?? filename;
    if(_filename==null){
      throw PlatformException(code: "404",message: "[filename] is null");
    }
  }


   Future<bool> initMemory() async{
    Directory? appDir;
    try {
       appDir = await getApplicationDocumentsDirectory();
    }catch(xx){
      throw PlatformException(code: "415",message: "Platform not supported: "+xx.toString());
    }
    if (appDir == null || appDir.path == null || appDir.path.isEmpty) {
      throw PlatformException(code: "415",message: "Platform not supported");
    }
    _filePath = appDir.path + "/" + ((_filename ?? "memory.txt"));
    File file = File(_filePath!);
    if (await file.exists()) {
      return true;
    } else {
      try {
        FileStorage fileStorage = FileStorage(_filePath!);
        bool isSaved = fileStorage.save({});

        return isSaved;
      } catch (error) {
        throw PlatformException(code: "415",message: "Platform not supported: "+error.toString());
      }
    }
  }

  // initMemory() async {
  //   bool isCreated = false;
  //   final appDir = await getApplicationDocumentsDirectory();
  //   printError("initMemory appDir==");
  //   printError(appDir);
  //   if(appDir==null||appDir.path==null||appDir.path.isEmpty){
  //     return;
  //   }
  //   _filePath= appDir.path+"/"+((_filename ?? "memory.txt"));
  //   //_filePath = join(appDir.path, _filename ?? "memory.txt");
  //   File file = File(_filePath!);
  //   if (await file.exists()) {
  //     return true;
  //   } else {
  //     try {
  //       FileStorage fileStorage = FileStorage(_filePath!);
  //       bool isSaved = fileStorage.save({});
  //       printError("isSaved ==${isSaved.toString()}");
  //       //file.writeAsBytesSync(utf8.encode(""));
  //       return isSaved;
  //     } catch (error) {
  //       printError("writeAsBytesSync error==");
  //       printError(error.toString());
  //       return false;
  //     }
  //   }
  // }

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
    if (_filePath != null) {
      FileStorage fileStorage = FileStorage(_filePath!);
      return await fileStorage.read();
    }else{
      throw PlatformException(code: "404",message: "initMemory method not called");
    }
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
  Future readMemory(String key, {bool value = true}) async {
    Map<String, dynamic> data = await stageMemory();
    if (value) {
      if (data.containsKey(key)) {
        return data[key]['value'];
      } else {
        return null;
      }
    } else {
      if (data.containsKey(key)) {
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
  Future<Map> insertMemory<T>(String key, T mem,
      {Duration? duration, bool persist = true}) async {
    Map<String, dynamic> data = await stageMemory();
    if (persist) {
      FileStorage fileStorage = FileStorage(_filePath!);
      var entry = {
        'value': mem,
        'createdAt': DateTime.now().toIso8601String(),
      };

      /// If duration is not null, set the expiry time
      if (duration != null && duration.inSeconds > 0) {
        entry.addAll({'expiresAt': _setMemoryExpiry(duration)});
      }
      data.addAll({key: entry});
      bool isSaved = fileStorage.save(data);
      return data[key];
    } else {
      /// Set the value of the key to mem
      /// Set the createdAt time
      var entry = {
        'value': mem,
        'createdAt': DateTime.now().toIso8601String(),
      };

      /// If duration is not null, set the expiry time
      if (duration != null && duration.inSeconds > 0) {
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
  Future upsertMemory<T>(String key, T mem, {Duration? duration}) async {
    Map<String, dynamic> data = await stageMemory();
    if (data.containsKey(key)) {
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
    /// Set the value of the key to mem
    /// Set the createdAt time
    Map entry = {};
    entry.addAll(data[key]);
    entry['value'] = mem;
    entry['updatedAt'] = DateTime.now().toIso8601String();

    if (persist) {
      FileStorage fileStorage = FileStorage(_filePath!);
      data.addAll({key: entry});
      bool isSaved = fileStorage.save(data);
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
    if (data.containsKey(key)) {
      data.remove(key);
      FileStorage fileStorage = FileStorage(_filePath!);
      bool isSaved = fileStorage.save(data);
    }
  }

  /// Removes all values stored on [Memory]
  ///
  /// Clears every entry
  Future<void> resetMemory() async {
    if(_filePath==Null){
      throw PlatformException(code: "404",message: "initMemory method not called");
    }
    FileStorage fileStorage = FileStorage(_filePath!);
    bool isSaved = fileStorage.save({});
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

  /// Saves data to a file.
  /// {}
  bool save(Map<String, dynamic> data) {
    String stringEncrypted = encrypt(jsonEncode(data), 134523452346);
    var encodedData = utf8.encode(stringEncrypted);
    var byteData = Uint8List.fromList(encodedData);
    try {
      _file.writeAsBytesSync(byteData);
      return true;
    } catch (error) {
      return false;
    }
  }

  /// Reads data from a file.
  Future<Map<String, dynamic>> read() async {
    if (await _file.exists()) {
      var encodedData = _file.readAsBytesSync();
      var decodedData = utf8.decode(encodedData);
      String stringDecrypt = decrypt(decodedData, 134523452346);
      return jsonDecode(stringDecrypt) as Map<String, dynamic>;
    } else {
      bool isSaved = save({});
      return {};
    }
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
