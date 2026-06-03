// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/notificacion_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<NotificacionProvider>(context, listen: false)
            .loadNotificaciones(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificacionProvider = Provider.of<NotificacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: notificacionProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.dorado),
            )
          : notificacionProvider.notificaciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: AppColors.azulMarino.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes notificaciones',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textoClaro,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notificacionProvider.notificaciones.length,
                  itemBuilder: (context, index) {
                    final notificacion =
                        notificacionProvider.notificaciones[index];
                    return Card(
                      color: notificacion.leida
                          ? AppColors.blanco
                          : AppColors.azulMarino.withValues(alpha: 0.05),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getNotificationColor(
                              notificacion.tipo),
                          child: Icon(
                            _getNotificationIcon(notificacion.tipo),
                            color: AppColors.blanco,
                          ),
                        ),
                        title: Text(
                          notificacion.titulo,
                          style: TextStyle(
                            fontWeight: notificacion.leida
                                ? FontWeight.normal
                                : FontWeight.bold,
                            color: AppColors.azulMarino,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notificacion.mensaje),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(notificacion.fechaCreacion),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textoClaro,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          if (!notificacion.leida) {
                            notificacionProvider
                                .marcarLeida(notificacion.id);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getNotificationIcon(String tipo) {
    switch (tipo) {
      case 'reservacion':
        return Icons.calendar_today;
      case 'recordatorio':
        return Icons.alarm;
      case 'promocion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String tipo) {
    switch (tipo) {
      case 'reservacion':
        return AppColors.exito;
      case 'recordatorio':
        return AppColors.advertencia;
      case 'promocion':
        return AppColors.dorado;
      default:
        return AppColors.azulMarino;
    }
  }
}