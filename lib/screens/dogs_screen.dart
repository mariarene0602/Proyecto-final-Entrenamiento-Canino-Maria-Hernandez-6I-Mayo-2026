// lib/screens/dogs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mascota_provider.dart';
import '../models/mascota_model.dart';

class DogsScreen extends StatefulWidget {
  const DogsScreen({super.key});

  @override
  State<DogsScreen> createState() => _DogsScreenState();
}

class _DogsScreenState extends State<DogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<MascotaProvider>(context, listen: false)
            .loadMascotas(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mascotaProvider = Provider.of<MascotaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Perros'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDogDialog(context),
        child: const Icon(Icons.add),
      ),
      body: mascotaProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.dorado),
            )
          : mascotaProvider.mascotas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 80,
                        color: AppColors.azulMarino.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes perros registrados',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textoClaro,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddDogDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Perro'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mascotaProvider.mascotas.length,
                  itemBuilder: (context, index) {
                    final mascota = mascotaProvider.mascotas[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.azulMarinoClaro,
                          child: Text(
                            mascota.nombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.dorado,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          mascota.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.azulMarino,
                          ),
                        ),
                        subtitle:
                            Text('${mascota.raza} • ${mascota.edad} años'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: AppColors.dorado),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: AppColors.error),
                              onPressed: () => _confirmDelete(context, mascota),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddDogDialog(BuildContext context) {
    final nombreController = TextEditingController();
    final razaController = TextEditingController();
    final edadController = TextEditingController();
    final pesoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Perro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: razaController,
              decoration: const InputDecoration(labelText: 'Raza'),
            ),
            TextField(
              controller: edadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Edad (años)'),
            ),
            TextField(
              controller: pesoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final mascota = MascotaModel(
                id: '',
                nombre: nombreController.text,
                especie: 'perro',
                raza: razaController.text,
                edad: int.tryParse(edadController.text) ?? 0,
                peso: double.tryParse(pesoController.text) ?? 0,
                clienteId: authProvider.user!.uid,
                fechaRegistro: DateTime.now(),
              );
              await Provider.of<MascotaProvider>(context, listen: false)
                  .addMascota(mascota);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MascotaModel mascota) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Perro'),
        content: Text('¿Estás seguro de eliminar a ${mascota.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<MascotaProvider>(context, listen: false)
                  .deleteMascota(mascota.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
