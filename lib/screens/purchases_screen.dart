// lib/screens/purchases_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/mascota_provider.dart';
import '../providers/paquete_provider.dart';
import '../models/paquete_model.dart';
import '../models/pago_model.dart';
import '../models/mascota_model.dart';
import '../services/pago_service.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PagoService _pagoService = PagoService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<PaqueteProvider>(context, listen: false).loadPaquetes();
        Provider.of<MascotaProvider>(context, listen: false).loadMascotas(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final paqueteProvider = Provider.of<PaqueteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras y Paquetes'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.dorado,
          unselectedLabelColor: AppColors.blanco.withValues(alpha: 0.6),
          indicatorColor: AppColors.dorado,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_bag), text: 'Paquetes'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Catalog
          paqueteProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
              : paqueteProvider.paquetes.isEmpty
                  ? _buildEmptyPackagesState()
                  : _buildCatalogList(paqueteProvider.paquetes),
          
          // Tab 2: History
          authProvider.user == null
              ? const Center(child: Text('Inicia sesión para ver tu historial.'))
              : StreamBuilder<List<PagoModel>>(
                  stream: _pagoService.getPagosCliente(authProvider.user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.dorado));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyHistoryState();
                    }
                    return _buildHistoryList(snapshot.data!);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyPackagesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.azulMarino.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'No hay paquetes disponibles hoy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: AppColors.azulMarino.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Aún no has realizado compras',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
          ),
          const SizedBox(height: 8),
          const Text(
            'Los paquetes adquiridos se listarán aquí.',
            style: TextStyle(color: AppColors.textoClaro),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogList(List<PaqueteModel> paquetes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paquetes.length,
      itemBuilder: (context, index) {
        final paquete = paquetes[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        paquete.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulMarino,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.dorado.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${paquete.numeroSesiones} Sesiones',
                        style: const TextStyle(
                          color: AppColors.doradoOscuro,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  paquete.descripcion,
                  style: const TextStyle(color: AppColors.textoClaro),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Beneficios Incluidos:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino, fontSize: 13),
                ),
                const SizedBox(height: 6),
                ...paquete.beneficios.map((b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: AppColors.exito, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(b, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${paquete.precio.toStringAsFixed(2)} MXN',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.doradoOscuro,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showPurchaseDialog(context, paquete),
                      child: const Text('ADQUIRIR'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(List<PagoModel> pagos) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pagos.length,
      itemBuilder: (context, index) {
        final pago = pagos[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: pago.estado == 'completado'
                  ? AppColors.exito.withValues(alpha: 0.1)
                  : AppColors.advertencia.withValues(alpha: 0.1),
              child: Icon(
                Icons.payment,
                color: pago.estado == 'completado' ? AppColors.exito : AppColors.advertencia,
              ),
            ),
            title: Text(
              'Pago de ${pago.metodoPago.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino),
            ),
            subtitle: Text(
              'Fecha: ${pago.fechaPago.day}/${pago.fechaPago.month}/${pago.fechaPago.year}\nReferencia: ${pago.referencia ?? "N/A"}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${pago.monto.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.doradoOscuro, fontSize: 16),
                ),
                Text(
                  pago.estado.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: pago.estado == 'completado' ? AppColors.exito : AppColors.advertencia,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPurchaseDialog(BuildContext context, PaqueteModel paquete) {
    final mascotaProvider = Provider.of<MascotaProvider>(context, listen: false);
    if (mascotaProvider.mascotas.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registra un Perro'),
          content: const Text('Para poder comprar un paquete de adiestramiento, primero debes registrar a tu mascota en la sección "Mis Perros".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    MascotaModel selectedDog = mascotaProvider.mascotas.first;
    String selectedPaymentMethod = 'tarjeta';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.blanco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adquirir ${paquete.nombre}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
              ),
              const SizedBox(height: 8),
              Text(
                'Monto a pagar: \$${paquete.precio.toStringAsFixed(2)} MXN',
                style: const TextStyle(fontSize: 16, color: AppColors.doradoOscuro, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Dog Dropdown
              const Text('Selecciona la mascota a inscribir:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<MascotaModel>(
                initialValue: selectedDog,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: mascotaProvider.mascotas.map((d) => DropdownMenuItem(value: d, child: Text(d.nombre))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedDog = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Payment Selection
              const Text('Método de pago:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedPaymentMethod,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: const [
                  DropdownMenuItem(value: 'tarjeta', child: Text('Tarjeta de Crédito / Débito 💳')),
                  DropdownMenuItem(value: 'transferencia', child: Text('Transferencia Bancaria 🏦')),
                  DropdownMenuItem(value: 'efectivo', child: Text('Pago en Tienda / Efectivo 💵')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedPaymentMethod = val);
                  }
                },
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final refCode = 'PAG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                    
                    final pago = PagoModel(
                      id: '',
                      clienteId: authProvider.user!.uid,
                      contratacionId: paquete.id, // Linking package ID
                      monto: paquete.precio,
                      metodoPago: selectedPaymentMethod,
                      fechaPago: DateTime.now(),
                      estado: 'completado',
                      referencia: refCode,
                    );

                    await _pagoService.registrarPago(pago);

                    if (context.mounted) {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('¡Compra Exitosa!'),
                          content: Text('Se ha registrado el pago con la referencia $refCode. El paquete ahora está activo para tu mascota ${selectedDog.nombre}.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _tabController.animateTo(1); // Jump to transactions
                              },
                              child: const Text('Ver Transacciones'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('CONFIRMAR Y PAGAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}