// lib/providers/entrenador_provider.dart
import 'package:flutter/material.dart';
import '../services/entrenador_service.dart';
import '../models/entrenador_model.dart';

class EntrenadorProvider with ChangeNotifier {
  final EntrenadorService _entrenadorService = EntrenadorService();
  List<EntrenadorModel> _entrenadores = [];
  bool _isLoading = false;

  List<EntrenadorModel> get entrenadores => _entrenadores;
  bool get isLoading => _isLoading;

  void loadEntrenadores() {
    _isLoading = true;
    notifyListeners();
    _entrenadorService.getEntrenadores().listen((entrenadores) {
      _entrenadores = entrenadores;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<EntrenadorModel?> getEntrenador(String id) async {
    return await _entrenadorService.getEntrenador(id);
  }

  Future<void> addEntrenador(EntrenadorModel entrenador) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _entrenadorService.addEntrenador(entrenador);
    } catch (e) {
      debugPrint('Error adding trainer: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void loadAllEntrenadoresAdmin() {
    _isLoading = true;
    notifyListeners();
    _entrenadorService.getAllEntrenadoresAdmin().listen((entrenadores) {
      _entrenadores = entrenadores;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateEntrenador(String id, Map<String, dynamic> data) async {
    await _entrenadorService.updateEntrenador(id, data);
  }

  Future<void> deleteEntrenador(String id) async {
    await _entrenadorService.deleteEntrenador(id);
  }
}