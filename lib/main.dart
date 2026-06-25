import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'humannode_app.dart';
import 'core/di/service_locator.dart';
import 'core/logger/humannode_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  HumanNodeLogger.init();
  await ServiceLocator.init();
  runApp(const ProviderScope(child: HumanNodeApp()));
}
