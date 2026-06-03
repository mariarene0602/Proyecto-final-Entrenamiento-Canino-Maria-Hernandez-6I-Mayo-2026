// lib/providers/paquete_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/paquete_model.dart';
import '../services/paquete_service.dart';

class PaqueteProvider with ChangeNotifier {
  final PaqueteService _paqueteService = PaqueteService();
  List<PaqueteModel> _paquetes = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<PaqueteModel> get paquetes => _paquetes;
  bool get isLoading => _isLoading;

  void loadPaquetes() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _paqueteService.getPaquetes().listen(
      (data) {
        _paquetes = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void loadPaquetesAdmin() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _paqueteService.getAllPaquetesAdmin().listen(
      (data) {
        _paquetes = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addPaquete(PaqueteModel paquete) async {
    try {
      await _paqueteService.addPaquete(paquete);
      return true;
    } catch (e) {
      debugPrint('Error adding package: $e');
      return false;
    }
  }

  Future<bool> updatePaquete(String id, Map<String, dynamic> data) async {
    try {
      await _paqueteService.updatePaquete(id, data);
      return true;
    } catch (e) {
      debugPrint('Error updating package: $e');
      return false;
    }
  }

  Future<bool> deletePaquete(String id) async {
    try {
      await _paqueteService.deletePaquete(id);
      return true;
    } catch (e) {
      debugPrint('Error deleting package: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
