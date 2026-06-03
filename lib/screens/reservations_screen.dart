// lib/screens/reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/reservacion_provider.dart';
import '../providers/mascota_provider.dart';
import '../providers/servicio_provider.dart';
import '../providers/entrenador_provider.dart';
import '../models/reservacion_model.dart';
import '../models/mascota_model.dart';
import '../models/servicio_model.dart';
import '../models/entrenador_model.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final userId = authProvider.user!.uid;
        Provider.of<ReservacionProvider>(context, listen: false).loadReservaciones(userId);
        Provider.of<MascotaProvider>(context, listen: false).loadMascotas(userId);
        Provider.of<ServicioProvider>(context, listen: false).loadServicios();
        Provider.of<EntrenadorProvider>(context, listen: false).loadEntrenadores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservacionProvider = Provider.of<ReservacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservaciones'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewReservationDialog(context),
        child: const Icon(Icons.add),
      ),
      body: reservacionProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.dorado),
            )
          : reservacionProvider.reservaciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 80,
                        color: AppColors.azulMarino.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes reservaciones',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textoClaro,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showNewReservationDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva Reservación'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reservacionProvider.reservaciones.length,
                  itemBuilder: (context, index) {
                    final reservacion = reservacionProvider.reservaciones[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(reservacion.fechaReserva),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.azulMarino,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(reservacion.estado).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    reservacion.estado.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(reservacion.estado),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Precio: \$${reservacion.precioTotal.toStringAsFixed(2)} MXN',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.doradoOscuro,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (reservacion.notasAdicionales != null && reservacion.notasAdicionales!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Nota: ${reservacion.notasAdicionales!}',
                                style: const TextStyle(color: AppColors.textoClaro, fontSize: 12),
                              ),
                            ],
                            if (reservacion.estado == 'pendiente')
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          reservacionProvider.cancelReservacion(reservacion.id);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                          side: const BorderSide(color: AppColors.error),
                                        ),
                                        child: const Text('Cancelar Reservación'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return AppColors.advertencia;
      case 'confirmada':
      case 'confirmado':
        return AppColors.exito;
      case 'cancelada':
      case 'cancelado':
        return AppColors.error;
      case 'completada':
      case 'completado':
        return AppColors.azulMarino;
      default:
        return AppColors.textoClaro;
    }
  }

  void _showNewReservationDialog(BuildContext context) {
    final mascotaProvider = Provider.of<MascotaProvider>(context, listen: false);
    final servicioProvider = Provider.of<ServicioProvider>(context, listen: false);
    final entrenadorProvider = Provider.of<EntrenadorProvider>(context, listen: false);

    if (mascotaProvider.mascotas.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registrar Mascota'),
          content: const Text('Para poder crear una reservación, primero debes registrar a tu mascota en la sección "Mis Perros".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
      return;
    }

    if (servicioProvider.servicios.isEmpty || entrenadorProvider.entrenadores.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sin Datos'),
          content: const Text('Debe existir al menos un servicio y un entrenador en el sistema. Puedes inicializar la base de datos desde el panel de Administración.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
      return;
    }

    MascotaModel selectedPet = mascotaProvider.mascotas.first;
    ServicioModel selectedService = servicioProvider.servicios.first;
    EntrenadorModel selectedTrainer = entrenadorProvider.entrenadores.first;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final notasController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Nueva Reservación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Dropdown
                const Text('Mascota:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<MascotaModel>(
                  initialValue: selectedPet,
                  isExpanded: true,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: mascotaProvider.mascotas.map((m) => DropdownMenuItem(value: m, child: Text(m.nombre))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedPet = val);
                  },
                ),
                const SizedBox(height: 12),

                // Service Dropdown
                const Text('Servicio:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<ServicioModel>(
                  initialValue: selectedService,
                  isExpanded: true,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: servicioProvider.servicios.map((s) => DropdownMenuItem(value: s, child: Text('${s.nombre} (\$${s.precioBase.toStringAsFixed(0)})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedService = val);
                  },
                ),
                const SizedBox(height: 12),

                // Trainer Dropdown
                const Text('Adiestrador:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<EntrenadorModel>(
                  initialValue: selectedTrainer,
                  isExpanded: true,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: entrenadorProvider.entrenadores.map((t) => DropdownMenuItem(value: t, child: Text(t.nombreCompleto))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedTrainer = val);
                  },
                ),
                const SizedBox(height: 12),

                // Date Picker
                const Text('Fecha de Reservación:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setStateDialog(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.azulMarinoClaro),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                        const Icon(Icons.calendar_today, color: AppColors.dorado, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Notes
                const Text('Notas Adicionales:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: notasController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'Ej: Indicaciones especiales para tu perro'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final reservacion = ReservacionModel(
                  id: '',
                  clienteId: authProvider.user!.uid,
                  mascotaId: selectedPet.id,
                  servicioId: selectedService.id,
                  entrenadorId: selectedTrainer.id,
                  fechaReserva: selectedDate,
                  estado: 'confirmada',
                  precioTotal: selectedService.precioBase,
                  pagado: true,
                  metodoPago: 'tarjeta',
                  notasAdicionales: notasController.text.trim(),
                );

                await Provider.of<ReservacionProvider>(context, listen: false)
                    .createReservacion(reservacion);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Reservación creada con éxito!'),
                      backgroundColor: AppColors.exito,
                    ),
                  );
                }
              },
              child: const Text('Reservar'),
            ),
          ],
        ),
      ),
    );
  }
}