// lib/services/notificacion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacion_model.dart';

class NotificacionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener notificaciones de un cliente
  Stream<List<NotificacionModel>> getNotificaciones(String clienteId) {
    return _firestore
        .collection('NOTIFICACIONES')
        .where('clienteId', isEqualTo: clienteId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificacionModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      if (list.length > 50) {
        return list.sublist(0, 50);
      }
      return list;
    });
  }

  // Marcar como leída
  Future<void> marcarLeida(String id) async {
    await _firestore.collection('NOTIFICACIONES').doc(id).update({
      'leida': true,
    });
  }

  // Enviar notificación
  Future<void> enviarNotificacion(NotificacionModel notificacion) async {
    await _firestore.collection('NOTIFICACIONES').add(notificacion.toMap());
  }
}