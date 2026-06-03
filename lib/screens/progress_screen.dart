// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mascota_provider.dart';
import '../providers/progreso_provider.dart';
import '../models/mascota_model.dart';
import '../models/progreso_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  MascotaModel? _selectedMascota;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<MascotaProvider>(context, listen: false)
            .loadMascotas(authProvider.user!.uid)
            .then((_) {
          if (mounted) {
            final mascotas = Provider.of<MascotaProvider>(context, listen: false).mascotas;
            if (mascotas.isNotEmpty) {
              setState(() {
                _selectedMascota = mascotas.first;
              });
              Provider.of<ProgresoProvider>(context, listen: false)
                  .loadProgresos(mascotas.first.id);
            }
          }
        });
      }
    });
  }

  void _onMascotaChanged(MascotaModel? newMascota) {
    if (newMascota != null) {
      setState(() {
        _selectedMascota = newMascota;
      });
      Provider.of<ProgresoProvider>(context, listen: false)
          .loadProgresos(newMascota.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mascotaProvider = Provider.of<MascotaProvider>(context);
    final progresoProvider = Provider.of<ProgresoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso de Mascotas'),
      ),
      body: mascotaProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
          : mascotaProvider.mascotas.isEmpty
              ? _buildEmptyPetsState()
              : Column(
                  children: [
                    // Dog selector dropdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.azulMarino,
                      child: Row(
                        children: [
                          const Icon(Icons.pets, color: AppColors.dorado, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<MascotaModel>(
                                value: _selectedMascota,
                                dropdownColor: AppColors.azulMarinoClaro,
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.dorado),
                                style: const TextStyle(color: AppColors.blanco, fontSize: 16, fontWeight: FontWeight.bold),
                                isExpanded: true,
                                items: mascotaProvider.mascotas.map((MascotaModel mascota) {
                                  return DropdownMenuItem<MascotaModel>(
                                    value: mascota,
                                    child: Text(mascota.nombre),
                                  );
                                }).toList(),
                                onChanged: _onMascotaChanged,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: progresoProvider.isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
                          : progresoProvider.progresos.isEmpty
                              ? _buildEmptyProgressState()
                              : _buildProgressContent(progresoProvider.progresos),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyPetsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: AppColors.azulMarino.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'No tienes perros registrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registra a tu perro en la sección "Mis Perros" para poder registrar y ver su progreso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textoClaro),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyProgressState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 80, color: AppColors.azulMarino.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Sin progreso registrado para ${_selectedMascota?.nombre}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
            ),
            const SizedBox(height: 8),
            const Text(
              'Una vez que completes sesiones de entrenamiento, verás reportes de obediencia, socialización y energía aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textoClaro),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressContent(List<ProgresoModel> progresos) {
    // We aggregate or take the latest progress metrics
    final latest = progresos.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        const Text(
          'Habilidades y Temperamento',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
        ),
        const SizedBox(height: 16),
        
        // Progress Bars
        _buildMetricBar('Obediencia', latest.nivelObediencia, Icons.check_circle_outline),
        const SizedBox(height: 12),
        _buildMetricBar('Socialización', latest.nivelSocializacion, Icons.people_outline),
        const SizedBox(height: 12),
        _buildMetricBar('Nivel de Energía', latest.nivelEnergia, Icons.bolt),
        
        const SizedBox(height: 24),
        const Text(
          'Historial de Sesiones y Bitácoras',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
        ),
        const SizedBox(height: 12),
        
        // Timeline of logs
        ...progresos.map((progreso) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sesión del ${progreso.fecha.day}/${progreso.fecha.month}/${progreso.fecha.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino, fontSize: 16),
                    ),
                    if (progreso.videoUrl != null)
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: AppColors.dorado, size: 28),
                        onPressed: () => _simulateVideoPlay(context, progreso.videoUrl!),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  progreso.observaciones,
                  style: const TextStyle(color: AppColors.textoOscuro, fontSize: 14),
                ),
                if (progreso.notasEntrenador != null && progreso.notasEntrenador!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.grisClaro,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grisMedio),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.doradoOscuro),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Consejo: ${progreso.notasEntrenador}',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textoClaro),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (progreso.habilidadesTrabajadas.isNotEmpty) ...[
                  const Text('Habilidades Trabajadas:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.azulMarino)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: progreso.habilidadesTrabajadas.map((h) => Chip(
                      label: Text(h, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.azulMarinoClaro.withValues(alpha: 0.1),
                      padding: EdgeInsets.zero,
                    )).toList(),
                  ),
                ],
                if (progreso.logros.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Logros de la sesión 🏆:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.doradoOscuro)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: progreso.logros.map((l) => Chip(
                      label: Text(l, style: const TextStyle(fontSize: 11, color: AppColors.azulMarino)),
                      backgroundColor: AppColors.dorado.withValues(alpha: 0.2),
                      avatar: const Icon(Icons.star, size: 14, color: AppColors.doradoOscuro),
                      padding: EdgeInsets.zero,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildMetricBar(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grisMedio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.dorado, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino)),
              const Spacer(),
              Text('$value / 5', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.doradoOscuro)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 5.0,
              backgroundColor: AppColors.grisMedio,
              color: AppColors.azulMarino,
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _simulateVideoPlay(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.azulMarino,
        title: const Text('Video de Adiestramiento', style: TextStyle(color: AppColors.blanco)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 180,
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.play_circle_outline, size: 64, color: AppColors.dorado),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reproduciendo avance de adiestramiento en video...',
              style: TextStyle(color: AppColors.blanco, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppColors.dorado)),
          ),
        ],
      ),
    );
  }
}