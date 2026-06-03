// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/cliente_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  ClienteModel? _cliente;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  ClienteModel? get cliente => _cliente;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _cliente?.rol == 'admin';

  AuthProvider() {
    // Escuchar cambios de autenticación
    _authService.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        loadClienteData(user.uid);
      } else {
        _cliente = null;
      }
      notifyListeners();
    });
  }

  // ✅ CORREGIDO - Cargar datos del cliente
  Future<void> loadClienteData(String uid) async {
    try {
      final cliente = await _authService.getClienteData(uid);
      _cliente = cliente;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar datos del cliente: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      if (result != null) {
        _user = _authService.currentUser;
        // Cargar datos del cliente después del login
        await loadClienteData(_user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Credenciales inválidas';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al iniciar sesión';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String nombre,
    String apellido,
    String email,
    String password,
    String telefono,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        nombre,
        apellido,
        email,
        password,
        telefono,
      );
      if (result != null) {
        _user = _authService.currentUser;
        // Cargar datos del cliente recién creado
        await loadClienteData(_user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Error al registrar';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al registrarse';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _cliente = null;
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      default:
        return 'Ocurrió un error: $code';
    }
  }
}