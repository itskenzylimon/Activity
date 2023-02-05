import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../helpers/logger.dart';

class Memory {
  Memory({String? filename}) :
        _filename = filename;
  final String? _filename;

  static final Memory memory = Memory();

  Map<String, dynamic> _data = {};

  bool get isDataEmpty {
    _data.removeWhere((key, value) => _isMemoryActive(value));
    return _data.isEmpty;
  }

  bool get isMemoryEmpty => !isDataEmpty;

  // /// Get all data from [Memory].
  // ///
  // /// Will return empty list if entries are not found
  // stageMemory() async {
  //   if (_filename != null) {
  //     FileStorage fileStorage = FileStorage(_filename!);
  //     _data = await fileStorage.read();
  //   }
  // }
  //
  //
  // /// Get all data from [Memory].
  // ///
  // /// Will return empty list if entries are not found
  // syncMemory() async {
  //   if (_filename == null) {
  //     throw Exception('Add filePath where you\'ve init Memory(filename: Directory.current.path)');
  //   } else {
  //     printInfo('{{{{{text}}}}}');
  //     printInfo(_data);
  //     printInfo('{{{{{text}}}}}');
  //     FileStorage fileStorage = FileStorage(_filename!);
  //     _data = await fileStorage.read();
  //     printInfo('{{{{{text}}}}}');
  //     printInfo(_data);
  //     printInfo('{{{{{text}}}}}');
  //
  //   }
  // }


  /// Get all data from [Memory].
  ///
  /// Will return empty list if entries are not found
  List readMemories() {
    return _data.entries.toList();
  }


  /// Get data from [Memory].
  ///
  /// Will return null if entry is not found
  readMemory(String key) {
    if (_validateMemory(key)) {
      final item = _data[key]!;
      return item.mem;
    }
    return null;
  }

  /// It creates an entry in [Memory] if the value does not exist.
  ///
  /// If the [key] is not found it returns [true].
  ///
  /// If the [key] is found it returns [false].
  ///
  /// Use this in situations where you are uncertain if a [key] exists and
  /// your not planning to update the current value.
  bool createMemory<T>(String key,
      T mem, {Duration? duration}) {
    if (!_validateMemory(key)) {
      createMemory(key, mem, duration: duration);
      return true;
    }
    return false;
  }

  /// Creates new entry in [Memory].
  ///
  /// If a value exist it does an update in initialize.
  void upsertMemory<T>(String key,
      T mem, {Duration? duration}) {
    _data[key] = mem;
  }

  /// Updates a [key] value in [Memory] with the new value.
  ///
  /// If the [key] is not found it returns [false].
  ///
  /// If the [key] is found it returns [true].
  bool updateMemory<T>(String key,
      T mem, {Duration? duration}) {
    if (_validateMemory(key)) {
      _data[key] = _data[key]!.copyWith(
        mem: mem,
        expiresAt: _setMemoryExpiry(duration),
      );
      return true;
    }
    return false;
  }

  /// Removes entry from [Memory].
  ///
  /// Checks if a key exists in [Memory] before removing entry
  void deleteMemory(String key) {
    if(_validateMemory(key) == true){
      _data.remove(key);
    }
  }

  /// Removes all values stored on [Memory]
  ///
  /// Clears every entry
  void resetMemory() {
    _data.clear();
  }



  /// Checks if a key exists in Active Memory
  ///
  /// returns [true] if key is found.
  ///
  /// returns [false] if value does not exist.
  bool hasMemory(String key) {
    return _validateMemory(key);
  }

  /// Sets Active Memory entry expiry date
  DateTime? _setMemoryExpiry(Duration? expiry) =>
      expiry != null ? DateTime.now().add(expiry) : null;

  /// Checks Active Memory entry expiry date
  /// returns [false] if entry has not expired and [true] if its before expiry
  bool _isMemoryActive(dynamic activeMemory) {
    if (activeMemory.expiresAt != null && activeMemory.expiresAt!.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  /// This func validates if Memory key is expired, if so it removes the
  /// data and returns [false], if not it returns true
  bool _validateMemory(String key) {
    final entry = _data[key];
    if (entry == null) {
      return false;
    }
    // else if (_isMemoryActive(entry)) {
    //   deleteMemory(key);
    //   return false;
    // }
    return true;
  }
}
//
// class FileStorage {
//   final File _file;
//   FileStorage(String filename) : _file = File(filename);
//
//   Future<void> save(Map<String, dynamic> data) async {
//     printError('{created_at}');
//     printError(data);
//     printError('{created_at}');
//     var encodedData = utf8.encode(jsonEncode(data));
//     var byteData = Uint8List.fromList(encodedData);
//     await _file.writeAsBytes(byteData);
//   }
//
//   Future<Map<String, dynamic>> read() async {
//     if (!_file.existsSync()) {
//       save({'created_at': DateTime.now().toIso8601String()});
//     }
//     var encodedData = await _file.readAsBytes();
//     var decodedData = utf8.decode(encodedData);
//     return jsonDecode(decodedData) as Map<String, dynamic>;
//   }
//
//   Future<FileSystemEntity> delete() async {
//     return _file.delete();
//   }
// }