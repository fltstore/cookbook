import 'package:cookbook/pages/detail.dart';
import 'package:cookbook/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(CookBookApp());
}

class CookBookApp extends StatelessWidget {
  CookBookApp({super.key});

  final title = 'CookBook';

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: 'detail',
        path: '/detail',
        builder: (context, state) {
          String link = state.queryParams['link'] ?? "";
          return DetailPage(
            link: link,
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      title: title,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
      ],
    );
  }
}
