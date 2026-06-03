// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cliente_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Iniciar sesión
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('CLIENTES')
            .doc(result.user!.uid)
            .get();
        
        if (userDoc.exists) {
          return {
            'uid': result.user!.uid,
            'email': result.user!.email,
            'data': userDoc.data(),
          };
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Registrar
  Future<Map<String, dynamic>?> register(
    String nombre,
    String apellido,
    String email,
    String password,
    String telefono,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Crear documento en CLIENTES
        await _firestore.collection('CLIENTES').doc(result.user!.uid).set({
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'telefono': telefono,
          'fechaRegistro': Timestamp.now(),
          'activo': true,
          'rol': 'cliente',
        });

        return {
          'uid': result.user!.uid,
          'email': result.user!.email,
        };
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ✅ AGREGAR ESTE MÉTODO - Obtener datos del cliente
  Future<ClienteModel?> getClienteData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('CLIENTES').doc(uid).get();
      if (doc.exists) {
        return ClienteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener cliente: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}