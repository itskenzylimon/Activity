import 'dart:io';
import 'dart:convert';
import 'dart:async';

class ENVSetup {

  Future<Map<String, String>> readENVFile(String filePath) async {
    var file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    var contents = await file.readAsString();
    var lines = LineSplitter.split(contents);

    var env = <String, String>{};
    var keyValueRegex = RegExp(r'^(.*?)=(.*)$');
    for (var line in lines) {
      if (line.startsWith('#') || line.isEmpty) {
        continue;
      }
      var match = keyValueRegex.firstMatch(line);
      if (match != null) {
        var key = match.group(1);
        var value = match.group(2);
        env[key!] = value!;
      }
    }
    return env;
  }

}
