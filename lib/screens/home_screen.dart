// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mascota_provider.dart';
import '../providers/sesion_provider.dart';
import '../providers/entrenador_provider.dart';
import '../models/mascota_model.dart';
import '../models/entrenador_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

        // Load trainers
        Provider.of<EntrenadorProvider>(context, listen: false).loadEntrenadores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final sesionProvider = Provider.of<SesionProvider>(context);
    final mascotaProvider = Provider.of<MascotaProvider>(context);
    final entrenadorProvider = Provider.of<EntrenadorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canis Academia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      drawer: Drawer(
        child: Material(
          color: AppColors.azulMarino,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.azulMarinoClaro,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.dorado,
                      child: Icon(Icons.person, size: 40, color: AppColors.blanco),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      authProvider.cliente?.nombreCompleto ?? 'Usuario',
                      style: const TextStyle(
                        color: AppColors.blanco,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.cliente?.email ?? '',
                      style: const TextStyle(color: AppColors.grisMedio, fontSize: 14),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(context, Icons.pets, 'Mis Perros', '/dogs'),
              _buildDrawerItem(context, Icons.calendar_today, 'Reservaciones', '/reservations'),
              _buildDrawerItem(context, Icons.fitness_center, 'Entrenamiento', '/training'),
              _buildDrawerItem(context, Icons.trending_up, 'Progreso', '/progress'),
              _buildDrawerItem(context, Icons.star, 'Reseñas', '/reviews'),
              _buildDrawerItem(context, Icons.shopping_cart, 'Compras', '/purchases'),
              const Divider(color: AppColors.dorado),
              _buildDrawerItem(context, Icons.people, 'Entrenadores', '/trainers'),
              _buildDrawerItem(context, Icons.miscellaneous_services, 'Servicios', '/services'),
              _buildDrawerItem(context, Icons.dashboard, 'Dashboard', '/dashboard'),
              if (authProvider.isAdmin)
                _buildDrawerItem(context, Icons.admin_panel_settings, 'Admin', '/admin'),
              const Divider(color: AppColors.dorado),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner principal
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.azulMarino, AppColors.azulMarinoMedio],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡Bienvenido!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blanco,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Entrena a tu mejor amigo',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.doradoClaro,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/reservations'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dorado,
                            foregroundColor: AppColors.azulMarino,
                          ),
                          child: const Text('Reservar Ahora'),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    right: 10,
                    bottom: 10,
                    child: Icon(
                      Icons.pets,
                      size: 100,
                      color: AppColors.dorado,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Acceso rápido
            const Text(
              'Acceso Rápido',
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
                  child: _buildQuickAccessCard(
                    context,
                    icon: Icons.pets,
                    title: 'Mis Perros',
                    subtitle: 'Gestiona tus mascotas',
                    onTap: () => Navigator.pushNamed(context, '/dogs'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Reservar',
                    subtitle: 'Agenda una sesión',
                    onTap: () => Navigator.pushNamed(context, '/reservations'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAccessCard(
                    context,
                    icon: Icons.people,
                    title: 'Entrenadores',
                    subtitle: 'Conoce al equipo',
                    onTap: () => Navigator.pushNamed(context, '/trainers'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAccessCard(
                    context,
                    icon: Icons.trending_up,
                    title: 'Progreso',
                    subtitle: 'Ve los avances',
                    onTap: () => Navigator.pushNamed(context, '/progress'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Próximas sesiones
            const Text(
              'Próximas Sesiones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.azulMarino,
              ),
            ),
            const SizedBox(height: 12),
            _buildUpcomingSessionsList(
              context,
              sesionProvider,
              mascotaProvider,
              entrenadorProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dorado),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.blanco),
      ),
      onTap: () {
        Navigator.pop(context); // Cerrar drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.azulMarino.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.azulMarino.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.dorado),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.azulMarino,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textoClaro,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionsList(
    BuildContext context,
    SesionProvider sesionProvider,
    MascotaProvider mascotaProvider,
    EntrenadorProvider entrenadorProvider,
  ) {
    if (sesionProvider.isLoading || mascotaProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(color: AppColors.dorado),
        ),
      );
    }

    final upcoming = sesionProvider.sesiones.where((s) {
      return s.estado == 'programada' || s.estado == 'en_curso';
    }).toList();

    // Sort by date ascending
    upcoming.sort((a, b) => a.fecha.compareTo(b.fecha));

    if (upcoming.isEmpty) {
      return Card(
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/reservations'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.azulMarino.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: AppColors.azulMarino,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No tienes sesiones programadas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulMarino,
                        ),
                      ),
                      Text(
                        'Reserva tu primera sesión ahora',
                        style: TextStyle(color: AppColors.textoClaro),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.dorado),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcoming.length > 3 ? 3 : upcoming.length, // Show up to 3 upcoming sessions
      itemBuilder: (context, index) {
        final session = upcoming[index];
        final pet = mascotaProvider.mascotas.firstWhere(
          (p) => p.id == session.mascotaId,
          orElse: () => MascotaModel(
            id: '',
            nombre: 'Mascota',
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
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () => Navigator.pushNamed(context, '/training'),
            leading: const CircleAvatar(
              backgroundColor: AppColors.azulMarinoClaro,
              child: Icon(Icons.pets, color: AppColors.dorado),
            ),
            title: Text(
              '${pet.nombre} - ${session.estadoFormateado}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino),
            ),
            subtitle: Text(
              '${DateFormat('dd/MM/yyyy').format(session.fecha)} • ${session.horarioFormateado}\nEntrenador: ${trainer.nombreCompleto}',
              style: const TextStyle(color: AppColors.textoClaro),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.dorado),
          ),
        );
      },
    );
  }
}