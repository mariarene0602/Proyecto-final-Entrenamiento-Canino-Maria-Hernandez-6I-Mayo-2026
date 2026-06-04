// lib/providers/sesion_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sesion_model.dart';
import '../services/sesion_service.dart';

class SesionProvider with ChangeNotifier {
  final SesionService _sesionService = SesionService();
  List<SesionModel> _sesiones = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<SesionModel> get sesiones => _sesiones;
  bool get isLoading => _isLoading;

  void loadSesiones(List<String> mascotaIds) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _sesionService.getSesionesMascotas(mascotaIds).listen(
      (data) {
        _sesiones = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateEstado(String id, String estado) async {
    try {
      await _sesionService.updateEstado(id, estado);
    } catch (e) {
      debugPrint('Error updating session status: $e');
    }
  }

  Future<void> updateFecha(String id, DateTime fecha) async {
    try {
      await _sesionService.updateFecha(id, fecha);
    } catch (e) {
      debugPrint('Error updating session date: $e');
    }
  }

  Future<void> addSesion(SesionModel sesion) async {
    try {
      await _sesionService.addSesion(sesion);
    } catch (e) {
      debugPrint('Error adding session: $e');
    }
  }

  Future<void> cancelarSesion(String id) async {
    try {
      await _sesionService.cancelarSesion(id);
    } catch (e) {
      debugPrint('Error cancelling session: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
