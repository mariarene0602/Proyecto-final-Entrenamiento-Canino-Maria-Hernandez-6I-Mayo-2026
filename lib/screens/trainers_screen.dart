// lib/screens/trainers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/entrenador_provider.dart';

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
                          onPressed: () {},
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
}
