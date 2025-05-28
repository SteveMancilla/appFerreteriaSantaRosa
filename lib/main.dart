import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/carrito_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/productos_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/carrito_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarritoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Móvil',
        theme: ThemeData(
          primaryColor: const Color(0xFF031059),
          scaffoldBackgroundColor: const Color(0xFFF2F2F2),
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/productos': (context) => const ProductosScreen(),
          '/historial': (context) => const HistorialScreen(),
          '/carrito': (context) => const CarritoScreen(),
        },
      ),
    );
  }
}
