// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';
import '../providers/mascota_provider.dart';
import '../providers/entrenador_provider.dart';
import '../providers/servicio_provider.dart';
import '../providers/paquete_provider.dart';
import '../providers/promocion_provider.dart';
import '../providers/reservacion_provider.dart';
import '../models/entrenador_model.dart';
import '../models/servicio_model.dart';
import '../models/paquete_model.dart';
import '../models/promocion_model.dart';
import '../models/mascota_model.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAllData();
    });
  }

  void _refreshAllData() {
    Provider.of<EntrenadorProvider>(context, listen: false).loadAllEntrenadoresAdmin();
    Provider.of<ServicioProvider>(context, listen: false).loadAllServiciosAdmin();
    Provider.of<PaqueteProvider>(context, listen: false).loadPaquetesAdmin();
    Provider.of<PromocionProvider>(context, listen: false).loadPromocionesAdmin();
    Provider.of<MascotaProvider>(context, listen: false).loadAllMascotasAdmin();
    Provider.of<ReservacionProvider>(context, listen: false).loadAllReservacionesAdmin();
  }

  Future<void> _seedData() async {
    setState(() => _isSeeding = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final mascotaProvider = Provider.of<MascotaProvider>(context, listen: false);
    
    final dogIds = mascotaProvider.mascotas.map((d) => d.id).toList();
    await FirebaseService.seedDatabase(
      userId: authProvider.user?.uid,
      mascotaIds: dogIds,
    );

    _refreshAllData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Base de datos poblada con éxito!'),
          backgroundColor: AppColors.exito,
        ),
      );
      setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin CRUD Panel'),
          actions: [
            _isSeeding
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.blanco, strokeWidth: 2))),
                  )
                : IconButton(
                    icon: const Icon(Icons.restore_page),
                    tooltip: 'Seed Demo Data',
                    onPressed: _seedData,
                  ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refrescar',
              onPressed: _refreshAllData,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.dorado,
            unselectedLabelColor: AppColors.blanco.withValues(alpha: 0.6),
            indicatorColor: AppColors.dorado,
            tabs: const [
              Tab(text: 'Entrenadores'),
              Tab(text: 'Servicios'),
              Tab(text: 'Paquetes'),
              Tab(text: 'Promociones'),
              Tab(text: 'Mascotas'),
              Tab(text: 'Reservaciones'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTrainersTab(),
            _buildServicesTab(),
            _buildPackagesTab(),
            _buildPromotionsTab(),
            _buildPetsTab(),
            _buildReservationsTab(),
          ],
        ),
      ),
    );
  }

  // ==================== 1. TRAINERS TAB ====================
  Widget _buildTrainersTab() {
    final provider = Provider.of<EntrenadorProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addTrainerBtn',
        onPressed: () => _showTrainerFormDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.entrenadores.length,
              itemBuilder: (context, index) {
                final trainer = provider.entrenadores[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: trainer.disponible ? AppColors.exito.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: trainer.disponible ? AppColors.exito : AppColors.error),
                    ),
                    title: Text(trainer.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${trainer.especialidad} • Rating: ${trainer.calificacion} ⭐'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.dorado),
                          onPressed: () => _showTrainerFormDialog(context, trainer),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, () async {
                            await provider.deleteEntrenador(trainer.id);
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showTrainerFormDialog(BuildContext context, EntrenadorModel? trainer) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: trainer?.nombre);
    final apellidoController = TextEditingController(text: trainer?.apellido);
    final emailController = TextEditingController(text: trainer?.email);
    final telefonoController = TextEditingController(text: trainer?.telefono);
    final especialidadController = TextEditingController(text: trainer?.especialidad);
    final descController = TextEditingController(text: trainer?.descripcion);
    bool disponible = trainer?.disponible ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(trainer == null ? 'Nuevo Entrenador' : 'Editar Entrenador'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: apellidoController,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: telefonoController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: especialidadController,
                    decoration: const InputDecoration(labelText: 'Especialidad'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Disponible', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    value: disponible,
                    onChanged: (val) => setStateDialog(() => disponible = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'nombre': nombreController.text.trim(),
                    'apellido': apellidoController.text.trim(),
                    'email': emailController.text.trim(),
                    'telefono': telefonoController.text.trim(),
                    'especialidad': especialidadController.text.trim(),
                    'descripcion': descController.text.trim(),
                    'disponible': disponible,
                  };

                  final provider = Provider.of<EntrenadorProvider>(context, listen: false);
                  if (trainer == null) {
                    final newTrainer = EntrenadorModel(
                      id: '',
                      nombre: data['nombre'] as String,
                      apellido: data['apellido'] as String,
                      email: data['email'] as String,
                      telefono: data['telefono'] as String,
                      especialidad: data['especialidad'] as String,
                      descripcion: data['descripcion'] as String,
                      disponible: disponible,
                      fechaIngreso: DateTime.now(),
                    );
                    await provider.addEntrenador(newTrainer);
                  } else {
                    await provider.updateEntrenador(trainer.id, data);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 2. SERVICES TAB ====================
  Widget _buildServicesTab() {
    final provider = Provider.of<ServicioProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addServiceBtn',
        onPressed: () => _showServiceFormDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.servicios.length,
              itemBuilder: (context, index) {
                final service = provider.servicios[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: service.activo ? AppColors.azulMarino : AppColors.grisMedio,
                      child: const Icon(Icons.miscellaneous_services, color: AppColors.dorado),
                    ),
                    title: Text(service.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\$${service.precioBase} • ${service.duracionMinutos} min'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.dorado),
                          onPressed: () => _showServiceFormDialog(context, service),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, () async {
                            await provider.deleteServicio(service.id);
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showServiceFormDialog(BuildContext context, ServicioModel? service) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: service?.nombre);
    final descController = TextEditingController(text: service?.descripcion);
    final precioController = TextEditingController(text: service?.precioBase.toString());
    final duracionController = TextEditingController(text: service?.duracionMinutos.toString());
    bool activo = service?.activo ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(service == null ? 'Nuevo Servicio' : 'Editar Servicio'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio Base'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: duracionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duración (minutos)'),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Activo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    value: activo,
                    onChanged: (val) => setStateDialog(() => activo = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'nombre': nombreController.text.trim(),
                    'descripcion': descController.text.trim(),
                    'precioBase': double.tryParse(precioController.text) ?? 0.0,
                    'duracionMinutos': int.tryParse(duracionController.text) ?? 60,
                    'activo': activo,
                  };

                  final provider = Provider.of<ServicioProvider>(context, listen: false);
                  if (service == null) {
                    final newService = ServicioModel(
                      id: '',
                      nombre: data['nombre'] as String,
                      descripcion: data['descripcion'] as String,
                      precioBase: data['precioBase'] as double,
                      duracionMinutos: data['duracionMinutos'] as int,
                      categoria: 'individual',
                      activo: activo,
                    );
                    await provider.addServicio(newService);
                  } else {
                    await provider.updateServicio(service.id, data);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 3. PACKAGES TAB ====================
  Widget _buildPackagesTab() {
    final provider = Provider.of<PaqueteProvider>(context);
    final servicioProvider = Provider.of<ServicioProvider>(context);
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addPackageBtn',
        onPressed: () => _showPackageFormDialog(context, null, servicioProvider.servicios),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.paquetes.length,
              itemBuilder: (context, index) {
                final package = provider.paquetes[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: package.activo ? AppColors.dorado.withValues(alpha: 0.1) : AppColors.grisMedio,
                      child: const Icon(Icons.shopping_bag, color: AppColors.dorado),
                    ),
                    title: Text(package.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\$${package.precio} • ${package.numeroSesiones} sesiones'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.dorado),
                          onPressed: () => _showPackageFormDialog(context, package, servicioProvider.servicios),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, () async {
                            await provider.deletePaquete(package.id);
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPackageFormDialog(BuildContext context, PaqueteModel? package, List<ServicioModel> servicios) {
    if (servicios.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registra un Servicio'),
          content: const Text('Para crear un paquete, primero debes registrar al menos un servicio.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))],
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: package?.nombre);
    final descController = TextEditingController(text: package?.descripcion);
    final precioController = TextEditingController(text: package?.precio.toString());
    final sesionesController = TextEditingController(text: package?.numeroSesiones.toString());
    final diasController = TextEditingController(text: package?.duracionDias.toString());
    ServicioModel selectedService = package != null 
        ? servicios.firstWhere((s) => s.id == package.servicioId, orElse: () => servicios.first)
        : servicios.first;
    bool activo = package?.activo ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(package == null ? 'Nuevo Paquete' : 'Editar Paquete'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ServicioModel>(
                    initialValue: selectedService,
                    decoration: const InputDecoration(labelText: 'Servicio'),
                    items: servicios.map((s) => DropdownMenuItem(value: s, child: Text(s.nombre))).toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => selectedService = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: sesionesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Número de Sesiones'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: diasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duración (días)'),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Activo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    value: activo,
                    onChanged: (val) => setStateDialog(() => activo = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'nombre': nombreController.text.trim(),
                    'descripcion': descController.text.trim(),
                    'precio': double.tryParse(precioController.text) ?? 0.0,
                    'numeroSesiones': int.tryParse(sesionesController.text) ?? 5,
                    'duracionDias': int.tryParse(diasController.text) ?? 30,
                    'servicioId': selectedService.id,
                    'activo': activo,
                    'beneficios': package?.beneficios ?? ['Acceso prioritario', 'Certificado'],
                  };

                  final provider = Provider.of<PaqueteProvider>(context, listen: false);
                  if (package == null) {
                    final newPkg = PaqueteModel(
                      id: '',
                      nombre: data['nombre'] as String,
                      descripcion: data['descripcion'] as String,
                      precio: data['precio'] as double,
                      numeroSesiones: data['numeroSesiones'] as int,
                      duracionDias: data['duracionDias'] as int,
                      servicioId: data['servicioId'] as String,
                      activo: activo,
                      beneficios: data['beneficios'] as List<String>,
                    );
                    await provider.addPaquete(newPkg);
                  } else {
                    await provider.updatePaquete(package.id, data);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 4. PROMOTIONS TAB ====================
  Widget _buildPromotionsTab() {
    final provider = Provider.of<PromocionProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addPromoBtn',
        onPressed: () => _showPromoFormDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.promociones.length,
              itemBuilder: (context, index) {
                final promo = provider.promociones[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: promo.activo ? AppColors.dorado.withValues(alpha: 0.1) : AppColors.grisMedio,
                      child: const Icon(Icons.local_offer, color: AppColors.dorado),
                    ),
                    title: Text(promo.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Código: ${promo.codigo} • ${promo.descuento}% desc'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.dorado),
                          onPressed: () => _showPromoFormDialog(context, promo),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, () async {
                            await provider.deletePromocion(promo.id);
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPromoFormDialog(BuildContext context, PromocionModel? promo) {
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController(text: promo?.titulo);
    final descController = TextEditingController(text: promo?.descripcion);
    final descPercentController = TextEditingController(text: promo?.descuento.toString());
    final codigoController = TextEditingController(text: promo?.codigo);
    bool activo = promo?.activo ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(promo == null ? 'Nueva Promoción' : 'Editar Promoción'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descPercentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Descuento (%)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: codigoController,
                    decoration: const InputDecoration(labelText: 'Código de Cupón'),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Activo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    value: activo,
                    onChanged: (val) => setStateDialog(() => activo = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final data = {
                    'titulo': tituloController.text.trim(),
                    'descripcion': descController.text.trim(),
                    'descuento': double.tryParse(descPercentController.text) ?? 10.0,
                    'codigo': codigoController.text.trim().toUpperCase(),
                    'activo': activo,
                  };

                  final provider = Provider.of<PromocionProvider>(context, listen: false);
                  if (promo == null) {
                    final newPromo = PromocionModel(
                      id: '',
                      titulo: data['titulo'] as String,
                      descripcion: data['descripcion'] as String,
                      descuento: data['descuento'] as double,
                      codigo: data['codigo'] as String,
                      activo: activo,
                      fechaInicio: DateTime.now(),
                      fechaFin: DateTime.now().add(const Duration(days: 30)),
                    );
                    await provider.addPromocion(newPromo);
                  } else {
                    await provider.updatePromocion(promo.id, data);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 5. PETS TAB ====================
  Widget _buildPetsTab() {
    final provider = Provider.of<MascotaProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addPetBtn',
        onPressed: () => _showPetFormDialog(context, null),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.mascotas.length,
              itemBuilder: (context, index) {
                final pet = provider.mascotas[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.azulMarino.withValues(alpha: 0.1),
                      child: const Icon(Icons.pets, color: AppColors.dorado),
                    ),
                    title: Text(pet.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${pet.raza} • ${pet.edad} años • Cliente: ${pet.clienteId.substring(0, 5)}...'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.dorado),
                          onPressed: () => _showPetFormDialog(context, pet),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, () async {
                            await provider.hardDeleteMascota(pet.id);
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPetFormDialog(BuildContext context, MascotaModel? pet) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: pet?.nombre);
    final razaController = TextEditingController(text: pet?.raza);
    final edadController = TextEditingController(text: pet?.edad.toString());
    final pesoController = TextEditingController(text: pet?.peso.toString());
    final clienteIdController = TextEditingController(text: pet?.clienteId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet == null ? 'Nueva Mascota' : 'Editar Mascota'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: razaController,
                  decoration: const InputDecoration(labelText: 'Raza'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: edadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Edad (años)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: pesoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: clienteIdController,
                  decoration: const InputDecoration(labelText: 'ID del Cliente Owner'),
                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final data = {
                  'nombre': nombreController.text.trim(),
                  'especie': 'perro',
                  'raza': razaController.text.trim(),
                  'edad': int.tryParse(edadController.text) ?? 0,
                  'peso': double.tryParse(pesoController.text) ?? 5.0,
                  'clienteId': clienteIdController.text.trim(),
                  'fechaRegistro': pet?.fechaRegistro ?? DateTime.now(),
                  'activo': true,
                };

                final provider = Provider.of<MascotaProvider>(context, listen: false);
                if (pet == null) {
                  final newPet = MascotaModel(
                    id: '',
                    nombre: data['nombre'] as String,
                    especie: 'perro',
                    raza: data['raza'] as String,
                    edad: data['edad'] as int,
                    peso: data['peso'] as double,
                    clienteId: data['clienteId'] as String,
                    fechaRegistro: DateTime.now(),
                  );
                  await provider.addMascota(newPet);
                } else {
                  await provider.updateMascota(pet.id, data);
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ==================== 6. RESERVATIONS TAB ====================
  Widget _buildReservationsTab() {
    final provider = Provider.of<ReservacionProvider>(context);
    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.reservaciones.length,
              itemBuilder: (context, index) {
                final booking = provider.reservaciones[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(booking.estado).withValues(alpha: 0.1),
                      child: Icon(Icons.event, color: _getStatusColor(booking.estado)),
                    ),
                    title: Text('Mascota: ${booking.mascotaId.substring(0, 5)}...'),
                    subtitle: Text('Estado: ${booking.estado.toUpperCase()}\nFecha: ${booking.fechaReserva.day}/${booking.fechaReserva.month}/${booking.fechaReserva.year}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: booking.estado == 'confirmado' ? 'confirmada' : (booking.estado == 'cancelado' ? 'cancelada' : booking.estado),
                          items: const [
                            DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                            DropdownMenuItem(value: 'confirmada', child: Text('Confirmada')),
                            DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                          ],
                          onChanged: (val) async {
                            if (val != null) {
                              await provider.updateEstado(booking.id, val);
                              _refreshAllData();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, () async {
                            await provider.deleteReservacion(booking.id);
                          }),
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
      default:
        return AppColors.azulMarino;
    }
  }

  // ==================== COMMON DELETE CONFIRMATION ====================
  void _confirmDelete(BuildContext context, Future<void> Function() onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: const Text('¿Estás seguro de eliminar permanentemente este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await onDelete();
              _refreshAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registro eliminado con éxito'), backgroundColor: AppColors.exito),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}