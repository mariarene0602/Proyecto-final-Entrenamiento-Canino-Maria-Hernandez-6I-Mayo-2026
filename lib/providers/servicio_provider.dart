// lib/providers/servicio_provider.dart
import 'package:flutter/material.dart';
import '../services/servicio_service.dart';
import '../models/servicio_model.dart';
import '../models/paquete_model.dart';

class ServicioProvider with ChangeNotifier {
  final ServicioService _servicioService = ServicioService();
  List<ServicioModel> _servicios = [];
  List<PaqueteModel> _paquetes = [];
  bool _isLoading = false;

  List<ServicioModel> get servicios => _servicios;
  List<PaqueteModel> get paquetes => _paquetes;
  bool get isLoading => _isLoading;

  void loadServicios() {
    _isLoading = true;
    notifyListeners();
    _servicioService.getServicios().listen((servicios) {
      _servicios = servicios;
      _isLoading = false;
      notifyListeners();
    });
  }

  void loadPaquetes(String servicioId) {
    _servicioService.getPaquetesServicio(servicioId).listen((paquetes) {
      _paquetes = paquetes;
      notifyListeners();
    });
  }

  void loadAllPaquetes() {
    _servicioService.getAllPaquetes().listen((paquetes) {
      _paquetes = paquetes;
      notifyListeners();
    });
  }

  Future<void> addServicio(ServicioModel servicio) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _servicioService.addServicio(servicio);
    } catch (e) {
      debugPrint('Error adding service: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void loadAllServiciosAdmin() {
    _isLoading = true;
    notifyListeners();
    _servicioService.getAllServiciosAdmin().listen((servicios) {
      _servicios = servicios;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateServicio(String id, Map<String, dynamic> data) async {
    await _servicioService.updateServicio(id, data);
  }

  Future<void> deleteServicio(String id) async {
    await _servicioService.deleteServicio(id);
  }
}