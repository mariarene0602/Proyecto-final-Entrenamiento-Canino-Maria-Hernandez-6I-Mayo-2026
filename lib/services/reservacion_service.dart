// lib/services/reservacion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservacion_model.dart';

class ReservacionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear reservación
  Future<String> createReservacion(ReservacionModel reservacion) async {
    DocumentReference doc = await _firestore
        .collection('RESERVACIONES')
        .add(reservacion.toMap());
    return doc.id;
  }

  // Obtener reservaciones de un cliente
  Stream<List<ReservacionModel>> getReservacionesCliente(String clienteId) {
    return _firestore
        .collection('RESERVACIONES')
        .where('clienteId', isEqualTo: clienteId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ReservacionModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.fechaReserva.compareTo(a.fechaReserva));
      return list;
    });
  }

  // Actualizar estado de reservación
  Future<void> updateEstado(String id, String estado) async {
    await _firestore.collection('RESERVACIONES').doc(id).update({
      'estado': estado,
    });
  }

  // Cancelar reservación
  Future<void> cancelReservacion(String id) async {
    await _firestore.collection('RESERVACIONES').doc(id).update({
      'estado': 'cancelada',
    });
  }

  // Obtener todas las reservaciones (para admin)
  Stream<List<ReservacionModel>> getAllReservacionesAdmin() {
    return _firestore
        .collection('RESERVACIONES')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ReservacionModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.fechaReserva.compareTo(a.fechaReserva));
      return list;
    });
  }

  // Eliminar reservación
  Future<void> deleteReservacion(String id) async {
    await _firestore.collection('RESERVACIONES').doc(id).delete();
  }
}