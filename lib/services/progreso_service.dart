// lib/services/progreso_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progreso_model.dart';

class ProgresoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener historial de progreso de una mascota
  Stream<List<ProgresoModel>> getProgresosMascota(String mascotaId) {
    return _firestore
        .collection('PROGRESOS')
        .where('mascotaId', isEqualTo: mascotaId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProgresoModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Registrar progreso
  Future<void> addProgreso(ProgresoModel progreso) async {
    await _firestore.collection('PROGRESOS').add(progreso.toMap());
  }
}
