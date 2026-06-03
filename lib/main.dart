// ─── Main Entry Point ───────────────────────────────────────────────
// Smart Travel AI — Enterprise AI Travel Platform
// Version 2.0.0

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap.dart';

void main() async {
  await bootstrap();

  runApp(
    const ProviderScope(
      child: SmartTravelApp(),
    ),
  );
}
