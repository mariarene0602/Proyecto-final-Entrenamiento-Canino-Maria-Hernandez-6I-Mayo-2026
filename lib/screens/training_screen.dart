// lib/screens/training_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class TrainingSessionSimulated {
  String id;
  String petName;
  String trainerName;
  DateTime date;
  String timeRange; // e.g. "09:00 - 09:45"
  String status; // 'programada', 'en_curso', 'completada', 'cancelada'
  String location;
  String notes;

  TrainingSessionSimulated({
    required this.id,
    required this.petName,
    required this.trainerName,
    required this.date,
    required this.timeRange,
    required this.status,
    required this.location,
    required this.notes,
  });
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final List<TrainingSessionSimulated> _simulatedSessions = [
    TrainingSessionSimulated(
      id: '1',
      petName: 'Max (Pastor Alemán)',
      trainerName: 'Carlos Mendoza',
      date: DateTime.now().add(const Duration(days: 1)),
      timeRange: '09:00 - 09:45',
      status: 'programada',
      location: 'Parque Hundido',
      notes: 'Trabajaremos comando de atención y caminado junto con correa.',
    ),
    TrainingSessionSimulated(
      id: '2',
      petName: 'Luna (Golden Retriever)',
      trainerName: 'Sofía Martínez',
      date: DateTime.now(),
      timeRange: '11:00 - 11:45',
      status: 'en_curso',
      location: 'Academia Canis',
      notes: 'Sesión de socialización controlada e inducción al circuito Agility.',
    ),
    TrainingSessionSimulated(
      id: '3',
      petName: 'Toby (Beagle)',
      trainerName: 'Alejandro Ruiz',
      date: DateTime.now().subtract(const Duration(days: 1)),
      timeRange: '16:00 - 16:45',
      status: 'completada',
      location: 'Domicilio Cliente',
      notes: 'Evaluación inicial de reactividad ante timbres y ruidos fuertes. Excelente respuesta.',
    ),
  ];

  String _filterPet = 'Todos';

  @override
  Widget build(BuildContext context) {
    // Get unique pet names for filtering
    final petNames = ['Todos', ..._simulatedSessions.map((s) => s.petName.split(' ')[0]).toSet()];

    // Filtered list
    final filtered = _filterPet == 'Todos'
        ? _simulatedSessions
        : _simulatedSessions.where((s) => s.petName.startsWith(_filterPet)).toList();

    // Sort by date descending
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Entrenamiento'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addSimSession',
        onPressed: _showAddSessionDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Simulated Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.dorado.withValues(alpha: 0.15),
            child: const Row(
              children: [
                Icon(Icons.science, color: AppColors.doradoOscuro),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Modo Simulado Activo: Toca los estados para cambiarlos o reprograma horarios interactivos.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                  ),
                ),
              ],
            ),
          ),
          // Pet Filter bar
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
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final session = filtered[index];
                      return _buildSessionCard(session);
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
          const Text('Usa el botón "+" para agregar una sesión simulada.', style: TextStyle(color: AppColors.textoClaro)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(TrainingSessionSimulated session) {
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
                    session.petName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                  ),
                ),
                GestureDetector(
                  onTap: () => _cycleStatus(session),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message: 'Toca para cambiar estado',
                      child: _buildStatusChip(session.status),
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
                Text('Entrenador: ${session.trainerName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.dorado, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd/MM/yyyy').format(session.date)}  •  ${session.timeRange}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.dorado, size: 16),
                const SizedBox(width: 8),
                Text('Lugar: ${session.location}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (session.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text('Notas de la Sesión:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.azulMarino)),
              const SizedBox(height: 4),
              Text(
                session.notes,
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

  void _cycleStatus(TrainingSessionSimulated session) {
    final list = ['programada', 'en_curso', 'completada', 'cancelada'];
    final idx = list.indexOf(session.status);
    final nextIdx = (idx + 1) % list.length;
    setState(() {
      session.status = list[nextIdx];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado de la sesión actualizado a: ${session.status.toUpperCase()}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _deleteSession(TrainingSessionSimulated session) {
    setState(() {
      _simulatedSessions.remove(session);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión simulada eliminada'), backgroundColor: AppColors.error),
    );
  }

  void _rescheduleSession(TrainingSessionSimulated session) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: session.date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && mounted) {
      setState(() {
        session.date = picked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fecha de sesión actualizada'), backgroundColor: AppColors.exito),
      );
    }
  }

  void _showAddSessionDialog() {
    final petController = TextEditingController();
    final trainerController = TextEditingController(text: 'Carlos Mendoza');
    final timeController = TextEditingController(text: '10:00 - 10:45');
    final locController = TextEditingController(text: 'Parque Hundido');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Sesión Simulada'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: petController,
                decoration: const InputDecoration(labelText: 'Mascota (nombre y raza)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: trainerController,
                decoration: const InputDecoration(labelText: 'Adiestrador'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Horario (Rango)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locController,
                decoration: const InputDecoration(labelText: 'Lugar'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notas / Plan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (petController.text.isNotEmpty) {
                setState(() {
                  _simulatedSessions.add(
                    TrainingSessionSimulated(
                      id: DateTime.now().toString(),
                      petName: petController.text.trim(),
                      trainerName: trainerController.text.trim(),
                      date: DateTime.now().add(const Duration(days: 1)),
                      timeRange: timeController.text.trim(),
                      status: 'programada',
                      location: locController.text.trim(),
                      notes: notesController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión simulada creada con éxito'), backgroundColor: AppColors.exito),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}