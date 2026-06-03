// lib/services/sesion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sesion_model.dart';

class SesionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener sesiones para un grupo de mascotas
  Stream<List<SesionModel>> getSesionesMascotas(List<String> mascotaIds) {
    if (mascotaIds.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('SESIONES')
        .where('mascotaId', whereIn: mascotaIds)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => SesionModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.fecha.compareTo(a.fecha));
      return list;
    });
  }

  // Agregar sesión
  Future<void> addSesion(SesionModel sesion) async {
    await _firestore.collection('SESIONES').add(sesion.toMap());
  }

  // Actualizar estado de la sesión
  Future<void> updateEstado(String id, String estado) async {
    await _firestore.collection('SESIONES').doc(id).update({
      'estado': estado,
    });
  }

  // Eliminar/Cancelar sesión
  Future<void> cancelarSesion(String id) async {
    await _firestore.collection('SESIONES').doc(id).update({
      'estado': 'cancelada',
    });
  }
}
