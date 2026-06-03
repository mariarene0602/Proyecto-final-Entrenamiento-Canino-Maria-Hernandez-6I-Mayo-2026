// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/mascota_provider.dart';
import 'providers/entrenador_provider.dart';
import 'providers/servicio_provider.dart';
import 'providers/reservacion_provider.dart';
import 'providers/notificacion_provider.dart';
import 'providers/sesion_provider.dart';
import 'providers/progreso_provider.dart';
import 'providers/review_provider.dart';
import 'providers/paquete_provider.dart';
import 'providers/promocion_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dogs_screen.dart';
import 'screens/trainers_screen.dart';
import 'screens/services_screen.dart';
import 'screens/reservations_screen.dart';
import 'screens/training_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/purchases_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Still run the app – show an error banner instead of black screen
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error al iniciar Firebase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => MascotaProvider()),
        ChangeNotifierProvider(create: (_) => EntrenadorProvider()),
        ChangeNotifierProvider(create: (_) => ServicioProvider()),
        ChangeNotifierProvider(create: (_) => ReservacionProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionProvider()),
        ChangeNotifierProvider(create: (_) => SesionProvider()),
        ChangeNotifierProvider(create: (_) => ProgresoProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => PaqueteProvider()),
        ChangeNotifierProvider(create: (_) => PromocionProvider()),
      ],
      child: MaterialApp(
        title: 'Canis Academia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/dogs': (context) => const DogsScreen(),
          '/trainers': (context) => const TrainersScreen(),
          '/services': (context) => const ServicesScreen(),
          '/reservations': (context) => const ReservationsScreen(),
          '/training': (context) => const TrainingScreen(),
          '/progress': (context) => const ProgressScreen(),
          '/reviews': (context) => const ReviewsScreen(),
          '/purchases': (context) => const PurchasesScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/admin': (context) => const AdminScreen(),
        },
      ),
    );
  }
}