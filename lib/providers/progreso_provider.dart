// lib/providers/progreso_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/progreso_model.dart';
import '../services/progreso_service.dart';

class ProgresoProvider with ChangeNotifier {
  final ProgresoService _progresoService = ProgresoService();
  List<ProgresoModel> _progresos = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<ProgresoModel> get progresos => _progresos;
  bool get isLoading => _isLoading;

  void loadProgresos(String mascotaId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _progresoService.getProgresosMascota(mascotaId).listen(
      (data) {
        _progresos = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addProgreso(ProgresoModel progreso) async {
    try {
      await _progresoService.addProgreso(progreso);
      return true;
    } catch (e) {
      debugPrint('Error adding progress entry: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
