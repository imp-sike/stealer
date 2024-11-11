import 'package:flutter/material.dart';
import 'package:news_app/app.dart';
import 'package:news_app/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitializeApp();
  runApp(const BaseApp());
}
