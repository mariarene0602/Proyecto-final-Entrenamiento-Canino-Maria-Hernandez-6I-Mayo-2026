// lib/services/pago_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pago_model.dart';

class PagoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrar pago
  Future<void> registrarPago(PagoModel pago) async {
    await _firestore.collection('PAGOS').add(pago.toMap());
  }

  // Obtener pagos de un cliente
  Stream<List<PagoModel>> getPagosCliente(String clienteId) {
    return _firestore
        .collection('PAGOS')
        .where('clienteId', isEqualTo: clienteId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PagoModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.fechaPago.compareTo(a.fechaPago));
      return list;
    });
  }
}