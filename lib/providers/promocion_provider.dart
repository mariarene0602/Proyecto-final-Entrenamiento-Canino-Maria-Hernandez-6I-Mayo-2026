// lib/providers/promocion_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/promocion_model.dart';
import '../services/promocion_service.dart';

class PromocionProvider with ChangeNotifier {
  final PromocionService _promocionService = PromocionService();
  List<PromocionModel> _promociones = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<PromocionModel> get promociones => _promociones;
  bool get isLoading => _isLoading;

  void loadPromociones() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _promocionService.getPromociones().listen(
      (data) {
        _promociones = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void loadPromocionesAdmin() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _promocionService.getAllPromocionesAdmin().listen(
      (data) {
        _promociones = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addPromocion(PromocionModel promocion) async {
    try {
      await _promocionService.addPromocion(promocion);
      return true;
    } catch (e) {
      debugPrint('Error adding promotion: $e');
      return false;
    }
  }

  Future<bool> updatePromocion(String id, Map<String, dynamic> data) async {
    try {
      await _promocionService.updatePromocion(id, data);
      return true;
    } catch (e) {
      debugPrint('Error updating promotion: $e');
      return false;
    }
  }

  Future<bool> deletePromocion(String id) async {
    try {
      await _promocionService.deletePromocion(id);
      return true;
    } catch (e) {
      debugPrint('Error deleting promotion: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
