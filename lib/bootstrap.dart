// ─── Bootstrap ──────────────────────────────────────────────────────
// Application initialization: Firebase, env, DI, logging.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'firebase_options.dart';

/// Initialize all app dependencies before runApp()
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load environment config ──
  try {
    await AppConfig.init(env: Environment.development);
    AppLogger.info('Environment loaded: ${AppConfig.environment.name}');
  } catch (e) {
    AppLogger.warning('Failed to load .env file, using defaults: $e');
  }

  // ── Initialize Firebase ──
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: _firebaseOptionsForCurrentPlatform(),
      );
      AppLogger.info('Firebase initialized');
    } else {
      AppLogger.info('Firebase already initialized (hot restart)');
    }
  } catch (e) {
    AppLogger.warning('Firebase initialization failed: $e');
  }

  // ── Initialize Hive (local storage) ──
  await Hive.initFlutter();
  await Hive.openBox('app_prefs');
  AppLogger.info('Hive initialized');

  // ── System UI ──
  SystemChrome.setSystemUIOverlayStyle(AppTheme.darkSystemUI);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Production logging ──
  if (AppConfig.isProd) {
    AppLogger.setProductionMode();
  }

  AppLogger.info(
      'Bootstrap complete — Smart Travel AI v${AppConfig.appVersion}');
}

FirebaseOptions _firebaseOptionsForCurrentPlatform() {
  if (kIsWeb) {
    const base = DefaultFirebaseOptions.web;
    final webAppId = AppConfig.firebaseWebAppId;
    final webApiKey = AppConfig.firebaseWebApiKey;

    return FirebaseOptions(
      apiKey: webApiKey.isNotEmpty ? webApiKey : base.apiKey,
      appId: webAppId.isNotEmpty ? webAppId : base.appId,
      messagingSenderId: base.messagingSenderId,
      projectId: base.projectId,
      authDomain: base.authDomain,
      storageBucket: base.storageBucket,
      measurementId: base.measurementId,
    );
  }
  return DefaultFirebaseOptions.currentPlatform;
}
