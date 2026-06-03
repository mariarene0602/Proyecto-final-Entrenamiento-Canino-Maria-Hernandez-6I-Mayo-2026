// lib/screens/services_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/servicio_provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServicioProvider>(context, listen: false).loadServicios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicioProvider = Provider.of<ServicioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
      ),
      body: servicioProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.dorado),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: servicioProvider.servicios.length,
              itemBuilder: (context, index) {
                final servicio = servicioProvider.servicios[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.azulMarino.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getIconForService(servicio.categoria),
                                color: AppColors.azulMarino,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    servicio.nombre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.azulMarino,
                                    ),
                                  ),
                                  Text(
                                    '${servicio.duracionMinutos} min',
                                    style: const TextStyle(
                                        color: AppColors.textoClaro),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${servicio.precioBase.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.doradoOscuro,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          servicio.descripcion,
                          style: const TextStyle(color: AppColors.textoClaro),
                        ),
                        const SizedBox(height: 12),
                        if (servicio.incluye.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: servicio.incluye.map((item) {
                              return Chip(
                                label: Text(item),
                                backgroundColor:
                                    AppColors.azulMarino.withValues(alpha: 0.1),
                                labelStyle: const TextStyle(
                                    color: AppColors.azulMarino, fontSize: 12),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/reservations');
                            },
                            child: const Text('Reservar'),
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

  IconData _getIconForService(String categoria) {
    switch (categoria) {
      case 'individual':
        return Icons.person;
      case 'grupal':
        return Icons.groups;
      case 'intensivo':
        return Icons.bolt;
      default:
        return Icons.pets;
    }
  }
}