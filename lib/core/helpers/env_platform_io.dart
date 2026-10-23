import 'dart:io';

Future<String> readFile(String path) => File(path).readAsString();
Map<String, String> get environment => Platform.environment;
