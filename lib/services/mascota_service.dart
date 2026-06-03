// lib/services/mascota_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mascota_model.dart';

class MascotaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener mascotas de un cliente
  Stream<List<MascotaModel>> getMascotasCliente(String clienteId) {
    return _firestore
        .collection('MASCOTAS')
        .where('clienteId', isEqualTo: clienteId)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MascotaModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Agregar mascota
  Future<void> addMascota(MascotaModel mascota) async {
    await _firestore.collection('MASCOTAS').add(mascota.toMap());
  }

  // Actualizar mascota
  Future<void> updateMascota(String id, Map<String, dynamic> data) async {
    await _firestore.collection('MASCOTAS').doc(id).update(data);
  }

  // Eliminar mascota (soft delete)
  Future<void> deleteMascota(String id) async {
    await _firestore.collection('MASCOTAS').doc(id).update({'activo': false});
  }

  // Obtener todas las mascotas (para admin)
  Stream<List<MascotaModel>> getAllMascotasAdmin() {
    return _firestore
        .collection('MASCOTAS')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MascotaModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Eliminar mascota definitivamente
  Future<void> hardDeleteMascota(String id) async {
    await _firestore.collection('MASCOTAS').doc(id).delete();
  }
}