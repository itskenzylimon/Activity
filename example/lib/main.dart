import 'package:flutter/material.dart';
import 'gallery/app.dart';
export 'gallery/app.dart' show MyApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
