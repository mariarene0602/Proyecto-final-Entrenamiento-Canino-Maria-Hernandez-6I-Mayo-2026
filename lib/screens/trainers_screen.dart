// lib/screens/trainers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/entrenador_provider.dart';
import '../models/entrenador_model.dart';

class TrainersScreen extends StatefulWidget {
  const TrainersScreen({super.key});

  @override
  State<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends State<TrainersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EntrenadorProvider>(context, listen: false)
          .loadEntrenadores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entrenadorProvider = Provider.of<EntrenadorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenadores'),
      ),
      body: entrenadorProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.dorado),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entrenadorProvider.entrenadores.length,
              itemBuilder: (context, index) {
                final entrenador = entrenadorProvider.entrenadores[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppColors.azulMarinoClaro,
                          child: Text(
                            entrenador.nombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.dorado,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entrenador.nombreCompleto,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.azulMarino,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entrenador.especialidad,
                                style: const TextStyle(
                                  color: AppColors.doradoOscuro,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 16, color: AppColors.dorado),
                                  Text(
                                    ' ${entrenador.calificacion.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                        color: AppColors.textoClaro),
                                  ),
                                  Text(
                                    ' (${entrenador.cantidadReviews})',
                                    style: const TextStyle(
                                        color: AppColors.textoClaro),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showTrainerProfile(context, entrenador),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dorado,
                            foregroundColor: AppColors.azulMarino,
                          ),
                          child: const Text('Ver Perfil'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showTrainerProfile(BuildContext context, EntrenadorModel trainer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.grisMedio,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: trainer.fotoUrl != null && trainer.fotoUrl!.isNotEmpty
                        ? NetworkImage(trainer.fotoUrl!)
                        : null,
                    backgroundColor: AppColors.azulMarinoClaro,
                    child: trainer.fotoUrl == null || trainer.fotoUrl!.isEmpty
                        ? Text(
                            trainer.nombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.dorado,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainer.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.azulMarino,
                          ),
                        ),
                        Text(
                          trainer.especialidad,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.doradoOscuro,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.dorado, size: 20),
                            Text(
                              ' ${trainer.calificacion.toStringAsFixed(1)} (${trainer.cantidadReviews} reseñas)',
                              style: const TextStyle(color: AppColors.textoClaro),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Sobre el Entrenador',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trainer.descripcion ?? 'Sin descripción disponible.',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textoOscuro,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Certificaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulMarino,
                ),
              ),
              const SizedBox(height: 8),
              trainer.certificaciones.isEmpty
                  ? const Text('Sin certificaciones registradas.', style: TextStyle(color: AppColors.textoClaro))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: trainer.certificaciones.map((cert) => Chip(
                        label: Text(cert),
                        backgroundColor: AppColors.azulMarinoClaro.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(color: AppColors.azulMarino, fontWeight: FontWeight.w600),
                        avatar: const Icon(Icons.verified, color: AppColors.dorado, size: 16),
                      )).toList(),
                    ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: trainer.disponible ? () => _contactTrainer(context, trainer) : null,
                      icon: const Icon(Icons.phone),
                      label: Text(trainer.disponible ? 'Contactar' : 'No Disponible'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.azulMarino,
                        foregroundColor: AppColors.blanco,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _contactTrainer(BuildContext context, EntrenadorModel trainer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactar a ${trainer.nombre}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.dorado),
              title: const Text('Teléfono'),
              subtitle: Text(trainer.telefono),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.dorado),
              title: const Text('Correo'),
              subtitle: Text(trainer.email),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
