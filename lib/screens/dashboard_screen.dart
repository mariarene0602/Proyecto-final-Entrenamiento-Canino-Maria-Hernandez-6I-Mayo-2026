// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mascota_provider.dart';
import '../providers/sesion_provider.dart';
import '../providers/reservacion_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final userId = authProvider.user!.uid;
        
        // Load pets first, then load sessions based on pet IDs
        final mascotaProvider = Provider.of<MascotaProvider>(context, listen: false);
        mascotaProvider.loadMascotas(userId).then((_) {
          if (mounted) {
            final dogIds = mascotaProvider.mascotas.map((d) => d.id).toList();
            Provider.of<SesionProvider>(context, listen: false).loadSesiones(dogIds);
          }
        });

        // Load reservations
        if (mounted) {
          Provider.of<ReservacionProvider>(context, listen: false).loadReservaciones(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mascotaProvider = Provider.of<MascotaProvider>(context);
    final sesionProvider = Provider.of<SesionProvider>(context);
    final reservacionProvider = Provider.of<ReservacionProvider>(context);

    final totalPets = mascotaProvider.mascotas.length;
    final totalSessions = sesionProvider.sesiones.length;
    final completedSessions = sesionProvider.sesiones.where((s) => s.estado == 'completada').length;
    final pendingReservations = reservacionProvider.reservaciones.where((r) => r.estado == 'pendiente').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Canino'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Métricas del Cliente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Sesiones Totales',
                      totalSessions.toString(),
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Mascotas Registradas',
                      totalPets.toString(),
                      Icons.pets,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Reservas Pendientes',
                      pendingReservations.toString(),
                      Icons.pending,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Sesiones Completadas',
                      completedSessions.toString(),
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Resumen de Estado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryRow('Progreso Promedio', '85%', Icons.trending_up, AppColors.dorado),
                      const Divider(),
                      _buildSummaryRow('Asistencia de Perros', '98%', Icons.check, AppColors.exito),
                      const Divider(),
                      _buildSummaryRow('Tasa de Satisfacción', '5/5', Icons.star, AppColors.dorado),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.dorado),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.azulMarino,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: AppColors.textoClaro, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.azulMarino),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.doradoOscuro),
          ),
        ],
      ),
    );
  }
}