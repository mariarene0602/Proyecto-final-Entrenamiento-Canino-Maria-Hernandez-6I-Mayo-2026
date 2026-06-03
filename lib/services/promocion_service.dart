// lib/services/promocion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promocion_model.dart';

class PromocionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de promociones activas
  Stream<List<PromocionModel>> getPromociones() {
    return _firestore
        .collection('PROMOCIONES')
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PromocionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Stream de todas las promociones (para admin)
  Stream<List<PromocionModel>> getAllPromocionesAdmin() {
    return _firestore
        .collection('PROMOCIONES')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PromocionModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Agregar promoción
  Future<void> addPromocion(PromocionModel promocion) async {
    await _firestore.collection('PROMOCIONES').add(promocion.toMap());
  }

  // Actualizar promoción
  Future<void> updatePromocion(String id, Map<String, dynamic> data) async {
    await _firestore.collection('PROMOCIONES').doc(id).update(data);
  }

  // Eliminar promoción (soft delete)
  Future<void> deletePromocion(String id) async {
    await _firestore.collection('PROMOCIONES').doc(id).update({'activo': false});
  }
}
