// lib/services/paquete_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paquete_model.dart';

class PaqueteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de todos los paquetes activos
  Stream<List<PaqueteModel>> getPaquetes() {
    return _firestore
        .collection('PAQUETES')
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaqueteModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Stream de todos los paquetes (incluidos inactivos para admin)
  Stream<List<PaqueteModel>> getAllPaquetesAdmin() {
    return _firestore
        .collection('PAQUETES')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaqueteModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Agregar paquete
  Future<void> addPaquete(PaqueteModel paquete) async {
    await _firestore.collection('PAQUETES').add(paquete.toMap());
  }

  // Actualizar paquete
  Future<void> updatePaquete(String id, Map<String, dynamic> data) async {
    await _firestore.collection('PAQUETES').doc(id).update(data);
  }

  // Eliminar paquete (soft delete)
  Future<void> deletePaquete(String id) async {
    await _firestore.collection('PAQUETES').doc(id).update({'activo': false});
  }
}
