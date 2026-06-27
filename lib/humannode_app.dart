import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humannode/providers/settings_provider.dart';
import 'config/theme.dart';
import 'ui/app_router.dart';

class HumanNodeApp extends ConsumerWidget {
  const HumanNodeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = settings.darkMode ? ThemeMode.dark : ThemeMode.light;

    return MaterialApp.router(
      title: 'HumanNode',
      debugShowCheckedModeBanner: false,
      theme: HumanNodeTheme.light,
      darkTheme: HumanNodeTheme.dark,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
        Locale('ko'),
        Locale('zh'),
        Locale('es'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale?.languageCode) return supported;
        }
        return supportedLocales.first;
      },
    );
  }
}
