// lib/providers/mascota_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/mascota_service.dart';
import '../models/mascota_model.dart';

class MascotaProvider with ChangeNotifier {
  final MascotaService _mascotaService = MascotaService();
  List<MascotaModel> _mascotas = [];
  bool _isLoading = false;

  List<MascotaModel> get mascotas => _mascotas;
  bool get isLoading => _isLoading;

  Future<void> loadMascotas(String clienteId) async {
    _isLoading = true;
    notifyListeners();
    final completer = Completer<void>();
    _mascotaService.getMascotasCliente(clienteId).listen((mascotas) {
      _mascotas = mascotas;
      _isLoading = false;
      notifyListeners();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> addMascota(MascotaModel mascota) async {
    await _mascotaService.addMascota(mascota);
  }

  Future<void> updateMascota(String id, Map<String, dynamic> data) async {
    await _mascotaService.updateMascota(id, data);
  }

  Future<void> deleteMascota(String id) async {
    await _mascotaService.deleteMascota(id);
  }

  void loadAllMascotasAdmin() {
    _isLoading = true;
    notifyListeners();
    _mascotaService.getAllMascotasAdmin().listen((mascotas) {
      _mascotas = mascotas;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> hardDeleteMascota(String id) async {
    await _mascotaService.hardDeleteMascota(id);
  }
}