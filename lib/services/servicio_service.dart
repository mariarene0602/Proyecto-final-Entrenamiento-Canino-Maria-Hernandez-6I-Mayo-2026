// lib/services/servicio_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/servicio_model.dart';
import '../models/paquete_model.dart';

class ServicioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los servicios
  Stream<List<ServicioModel>> getServicios() {
    return _firestore
        .collection('SERVICIOS')
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServicioModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener paquetes de un servicio
  Stream<List<PaqueteModel>> getPaquetesServicio(String servicioId) {
    return _firestore
        .collection('PAQUETES')
        .where('servicioId', isEqualTo: servicioId)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaqueteModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener todos los paquetes
  Stream<List<PaqueteModel>> getAllPaquetes() {
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

  // Agregar servicio
  Future<void> addServicio(ServicioModel servicio) async {
    await _firestore.collection('SERVICIOS').add(servicio.toMap());
  }

  // Obtener todos los servicios (para admin)
  Stream<List<ServicioModel>> getAllServiciosAdmin() {
    return _firestore
        .collection('SERVICIOS')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ServicioModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Actualizar servicio
  Future<void> updateServicio(String id, Map<String, dynamic> data) async {
    await _firestore.collection('SERVICIOS').doc(id).update(data);
  }

  // Eliminar servicio
  Future<void> deleteServicio(String id) async {
    await _firestore.collection('SERVICIOS').doc(id).delete();
  }
}