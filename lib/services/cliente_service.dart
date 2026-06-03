// lib/services/cliente_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente_model.dart';

class ClienteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener cliente por ID
  Future<ClienteModel?> getCliente(String id) async {
    DocumentSnapshot doc = await _firestore.collection('CLIENTES').doc(id).get();
    if (doc.exists) {
      return ClienteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Actualizar perfil
  Future<void> updateCliente(String id, Map<String, dynamic> data) async {
    await _firestore.collection('CLIENTES').doc(id).update(data);
  }

  // Stream de cliente
  Stream<ClienteModel?> streamCliente(String id) {
    return _firestore.collection('CLIENTES').doc(id).snapshots().map(
      (doc) {
        if (doc.exists) {
          return ClienteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
        return null;
      },
    );
  }
}