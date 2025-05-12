import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:varlik_eventos/provider/usuario.dart';
import 'package:varlik_eventos/screens/login.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
      ],
      child: EventsApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class EventsApp extends StatelessWidget {
  const EventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos',
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.grey,
        ),
        scaffoldBackgroundColor: const Color(0xFF2C2C2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2E),
          elevation: 0,
        ),
      ),
      navigatorKey: navigatorKey,
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
