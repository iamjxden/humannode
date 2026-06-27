import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humannode/config/theme.dart';
import 'package:humannode/ui/app_router.dart';

class HumanNodeApp extends ConsumerWidget {
  const HumanNodeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: HumanNodeTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp.router(
      title: 'HumanNode',
      debugShowCheckedModeBanner: false,
      theme: HumanNodeTheme.dark,
      darkTheme: HumanNodeTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );
  }
}
