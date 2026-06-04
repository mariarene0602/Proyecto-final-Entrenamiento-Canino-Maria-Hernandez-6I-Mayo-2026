// lib/screens/training_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mascota_provider.dart';
import '../providers/sesion_provider.dart';
import '../providers/entrenador_provider.dart';
import '../providers/progreso_provider.dart';
import '../models/sesion_model.dart';
import '../models/mascota_model.dart';
import '../models/entrenador_model.dart';
import '../models/progreso_model.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String _filterPet = 'Todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final userId = authProvider.user!.uid;
        final mascotaProvider = Provider.of<MascotaProvider>(context, listen: false);
        mascotaProvider.loadMascotas(userId).then((_) {
          if (mounted) {
            final dogIds = mascotaProvider.mascotas.map((d) => d.id).toList();
            Provider.of<SesionProvider>(context, listen: false).loadSesiones(dogIds);
          }
        });
        Provider.of<EntrenadorProvider>(context, listen: false).loadEntrenadores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mascotaProvider = Provider.of<MascotaProvider>(context);
    final sesionProvider = Provider.of<SesionProvider>(context);
    final entrenadorProvider = Provider.of<EntrenadorProvider>(context);

    // Get unique pet names for filtering
    final petNames = ['Todos', ...mascotaProvider.mascotas.map((m) => m.nombre).toSet()];

    // Filtered list
    final filtered = sesionProvider.sesiones.where((s) {
      if (_filterPet == 'Todos') return true;
      final pet = mascotaProvider.mascotas.firstWhere(
        (p) => p.id == s.mascotaId,
        orElse: () => MascotaModel(
          id: '',
          nombre: '',
          especie: 'perro',
          raza: '',
          edad: 0,
          peso: 0,
          clienteId: '',
          fechaRegistro: DateTime.now(),
        ),
      );
      return pet.nombre == _filterPet;
    }).toList();

    // Sort by date descending
    filtered.sort((a, b) => b.fecha.compareTo(a.fecha));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Entrenamiento'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRealSession',
        onPressed: _showAddSessionDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.azulMarino,
            child: Row(
              children: [
                const Icon(Icons.filter_alt, color: AppColors.dorado, size: 20),
                const SizedBox(width: 8),
                const Text('Filtrar Mascota: ', style: TextStyle(color: AppColors.blanco, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: petNames.map((pet) {
                        final isSelected = _filterPet == pet;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(pet),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _filterPet = pet);
                            },
                            selectedColor: AppColors.dorado,
                            backgroundColor: AppColors.azulMarinoClaro,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.azulMarino : AppColors.blanco,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: sesionProvider.isLoading || mascotaProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final session = filtered[index];
                          return _buildSessionCard(session, mascotaProvider, entrenadorProvider);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: AppColors.azulMarino.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No hay sesiones registradas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino)),
          const SizedBox(height: 8),
          const Text('Usa el botón "+" para programar una sesión de entrenamiento.', style: TextStyle(color: AppColors.textoClaro)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SesionModel session, MascotaProvider mascotaProvider, EntrenadorProvider entrenadorProvider) {
    final pet = mascotaProvider.mascotas.firstWhere(
      (p) => p.id == session.mascotaId,
      orElse: () => MascotaModel(
        id: '',
        nombre: 'Perro',
        especie: 'perro',
        raza: '',
        edad: 0,
        peso: 0,
        clienteId: '',
        fechaRegistro: DateTime.now(),
      ),
    );
    final trainer = entrenadorProvider.entrenadores.firstWhere(
      (e) => e.id == session.entrenadorId,
      orElse: () => EntrenadorModel(
        id: '',
        nombre: 'Entrenador',
        apellido: '',
        email: '',
        telefono: '',
        especialidad: '',
        fechaIngreso: DateTime.now(),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${pet.nombre} (${pet.raza})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                  ),
                ),
                GestureDetector(
                  onTap: () => _cycleStatus(session),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message: 'Toca para cambiar estado',
                      child: _buildStatusChip(session.estado),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.dorado, size: 16),
                const SizedBox(width: 8),
                Text('Entrenador: ${trainer.nombreCompleto}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.dorado, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(session.fecha)}  •  ${session.horarioFormateado}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.dorado, size: 16),
                const SizedBox(width: 8),
                Text('Lugar: ${session.ubicacion ?? "Academia Canis"}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (session.notas != null && session.notas!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text('Notas de la Sesión:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.azulMarino)),
              const SizedBox(height: 4),
              Text(
                session.notas!,
                style: const TextStyle(fontSize: 13, color: AppColors.textoClaro, fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _rescheduleSession(session),
                  icon: const Icon(Icons.edit_calendar, size: 16),
                  label: const Text('Reprogramar', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: () => _deleteSession(session),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color textColor = AppColors.blanco;
    String label;

    switch (status) {
      case 'programada':
        color = AppColors.azulMarinoClaro;
        label = 'Programada 📅';
        break;
      case 'en_curso':
        color = AppColors.advertencia;
        textColor = AppColors.azulMarino;
        label = 'En Curso 🐕';
        break;
      case 'completada':
        color = AppColors.exito;
        label = 'Completada 🏆';
        break;
      case 'cancelada':
        color = AppColors.error;
        label = 'Cancelada ❌';
        break;
      default:
        color = AppColors.grisMedio;
        textColor = AppColors.textoOscuro;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  void _cycleStatus(SesionModel session) async {
    final list = ['programada', 'en_curso', 'completada', 'cancelada'];
    final idx = list.indexOf(session.estado);
    final nextIdx = (idx + 1) % list.length;
    final nextStatus = list[nextIdx];

    if (nextStatus == 'completada') {
      _showProgressFormDialog(session);
    } else {
      await Provider.of<SesionProvider>(context, listen: false).updateEstado(session.id, nextStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado de la sesión actualizado a: ${nextStatus.toUpperCase()}'),
            backgroundColor: AppColors.exito,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _deleteSession(SesionModel session) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Sesión'),
        content: const Text('¿Estás seguro de cancelar esta sesión de entrenamiento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<SesionProvider>(context, listen: false).cancelarSesion(session.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cancelada con éxito'), backgroundColor: AppColors.error),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _rescheduleSession(SesionModel session) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: session.fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && mounted) {
      await Provider.of<SesionProvider>(context, listen: false).updateFecha(session.id, picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fecha de sesión actualizada'), backgroundColor: AppColors.exito),
        );
      }
    }
  }

  void _showProgressFormDialog(SesionModel session) {
    final obsController = TextEditingController();
    final notesController = TextEditingController();
    final habsController = TextEditingController(text: 'Sentarse, Echarse, Caminar junto');
    final logrosController = TextEditingController(text: 'Mayor concentración, Caminar sin tirar de la correa');
    int obedience = 4;
    int social = 4;
    int energy = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Registrar Progreso de Mascota'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registra el desempeño y comportamiento en esta sesión para actualizar el historial de progreso.',
                  style: TextStyle(fontSize: 12, color: AppColors.textoClaro),
                ),
                const SizedBox(height: 16),
                const Text('Nivel de Obediencia (1-5):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Slider(
                  value: obedience.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: obedience.toString(),
                  activeColor: AppColors.dorado,
                  onChanged: (val) => setStateDialog(() => obedience = val.toInt()),
                ),
                const Text('Nivel de Socialización (1-5):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Slider(
                  value: social.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: social.toString(),
                  activeColor: AppColors.dorado,
                  onChanged: (val) => setStateDialog(() => social = val.toInt()),
                ),
                const Text('Nivel de Energía (1-5):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Slider(
                  value: energy.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: energy.toString(),
                  activeColor: AppColors.dorado,
                  onChanged: (val) => setStateDialog(() => energy = val.toInt()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: obsController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones de la Sesión',
                    hintText: 'Ej: El perro estuvo muy receptivo al adiestramiento...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Consejo / Nota del Entrenador',
                    hintText: 'Ej: Practicar llamado antes de comer...',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: habsController,
                  decoration: const InputDecoration(
                    labelText: 'Habilidades Trabajadas (separadas por coma)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: logrosController,
                  decoration: const InputDecoration(
                    labelText: 'Logros Obtenidos (separados por coma)',
                  ),
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
                final progreso = ProgresoModel(
                  id: '',
                  mascotaId: session.mascotaId,
                  sesionId: session.id,
                  entrenadorId: session.entrenadorId,
                  fecha: DateTime.now(),
                  observaciones: obsController.text.trim().isNotEmpty 
                      ? obsController.text.trim() 
                      : 'Sesión completada con éxito. Excelente desempeño.',
                  nivelEnergia: energy,
                  nivelObediencia: obedience,
                  nivelSocializacion: social,
                  habilidadesTrabajadas: habsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                  logros: logrosController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                  notasEntrenador: notesController.text.trim().isNotEmpty 
                      ? notesController.text.trim() 
                      : 'Continuar reforzando los comandos básicos en casa.',
                  videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-playful-dog-in-the-grass-1175-large.mp4',
                );

                final progressProvider = Provider.of<ProgresoProvider>(context, listen: false);
                final sessionProvider = Provider.of<SesionProvider>(context, listen: false);

                final success = await progressProvider.addProgreso(progreso);
                if (success) {
                  await sessionProvider.updateEstado(session.id, 'completada');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Sesión Completada y Progreso Registrado!'),
                        backgroundColor: AppColors.exito,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al guardar el progreso.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSessionDialog() {
    final mascotaProvider = Provider.of<MascotaProvider>(context, listen: false);
    final entrenadorProvider = Provider.of<EntrenadorProvider>(context, listen: false);

    if (mascotaProvider.mascotas.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registra un Perro'),
          content: const Text('Para poder programar una sesión, primero debes registrar a tu mascota en la sección "Mis Perros".'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))],
        ),
      );
      return;
    }

    if (entrenadorProvider.entrenadores.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sin Entrenadores'),
          content: const Text('No hay entrenadores disponibles en el sistema.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))],
        ),
      );
      return;
    }

    MascotaModel selectedPet = mascotaProvider.mascotas.first;
    EntrenadorModel selectedTrainer = entrenadorProvider.entrenadores.first;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final timeController = TextEditingController(text: '10:00 - 10:45');
    final locController = TextEditingController(text: 'Academia Canis');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Programar Sesión de Entrenamiento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mascota:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                DropdownButtonFormField<MascotaModel>(
                  initialValue: selectedPet,
                  items: mascotaProvider.mascotas.map((m) => DropdownMenuItem(value: m, child: Text(m.nombre))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedPet = val);
                  },
                ),
                const SizedBox(height: 10),
                const Text('Entrenador:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                DropdownButtonFormField<EntrenadorModel>(
                  initialValue: selectedTrainer,
                  items: entrenadorProvider.entrenadores.map((t) => DropdownMenuItem(value: t, child: Text(t.nombreCompleto))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => selectedTrainer = val);
                  },
                ),
                const SizedBox(height: 10),
                const Text('Fecha:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.grisMedio), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                        const Icon(Icons.calendar_today, color: AppColors.dorado),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Horario (Ej: 10:00 - 10:45)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locController,
                  decoration: const InputDecoration(labelText: 'Lugar'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notas / Plan'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final times = timeController.text.split('-');
                final startStr = times.isNotEmpty ? times[0].trim() : '10:00';
                final endStr = times.length > 1 ? times[1].trim() : '10:45';

                final newSession = SesionModel(
                  id: '',
                  reservacionId: 'manual_${DateTime.now().millisecondsSinceEpoch}',
                  entrenadorId: selectedTrainer.id,
                  mascotaId: selectedPet.id,
                  fecha: selectedDate,
                  horaInicio: startStr,
                  horaFin: endStr,
                  estado: 'programada',
                  ubicacion: locController.text.trim(),
                  notas: notesController.text.trim(),
                );

                await Provider.of<SesionProvider>(context, listen: false).addSesion(newSession);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesión programada con éxito'), backgroundColor: AppColors.exito),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}