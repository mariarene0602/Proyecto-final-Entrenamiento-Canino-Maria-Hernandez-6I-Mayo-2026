// lib/services/entrenador_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entrenador_model.dart';

class EntrenadorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los entrenadores
  Stream<List<EntrenadorModel>> getEntrenadores() {
    return _firestore
        .collection('ENTRENADORES')
        .where('disponible', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EntrenadorModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener entrenador por ID
  Future<EntrenadorModel?> getEntrenador(String id) async {
    DocumentSnapshot doc = await _firestore.collection('ENTRENADORES').doc(id).get();
    if (doc.exists) {
      return EntrenadorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Agregar entrenador
  Future<void> addEntrenador(EntrenadorModel entrenador) async {
    await _firestore.collection('ENTRENADORES').add(entrenador.toMap());
  }

  // Obtener todos los entrenadores (para admin)
  Stream<List<EntrenadorModel>> getAllEntrenadoresAdmin() {
    return _firestore
        .collection('ENTRENADORES')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EntrenadorModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Actualizar entrenador
  Future<void> updateEntrenador(String id, Map<String, dynamic> data) async {
    await _firestore.collection('ENTRENADORES').doc(id).update(data);
  }

  // Eliminar entrenador
  Future<void> deleteEntrenador(String id) async {
    await _firestore.collection('ENTRENADORES').doc(id).delete();
  }
}