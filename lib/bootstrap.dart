import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('guest_transactions');
  // Initialize SharedPreferences early to avoid lazy loading issues
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    // Known issue with SharedPreferences during hot restart on some platforms.
    // We catch it here so it doesn't crash. Use Full Restart if persistence fails.
    // debugPrint('SharedPreferences init error (safe to ignore on Hot Restart): $e');
  }
}
