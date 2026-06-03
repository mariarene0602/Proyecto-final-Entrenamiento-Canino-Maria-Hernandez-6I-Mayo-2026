// lib/providers/reservacion_provider.dart
import 'package:flutter/material.dart';
import '../services/reservacion_service.dart';
import '../models/reservacion_model.dart';

class ReservacionProvider with ChangeNotifier {
  final ReservacionService _reservacionService = ReservacionService();
  List<ReservacionModel> _reservaciones = [];
  bool _isLoading = false;

  List<ReservacionModel> get reservaciones => _reservaciones;
  bool get isLoading => _isLoading;

  void loadReservaciones(String clienteId) {
    _isLoading = true;
    notifyListeners();
    _reservacionService.getReservacionesCliente(clienteId).listen((reservaciones) {
      _reservaciones = reservaciones;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String> createReservacion(ReservacionModel reservacion) async {
    return await _reservacionService.createReservacion(reservacion);
  }

  Future<void> cancelReservacion(String id) async {
    await _reservacionService.cancelReservacion(id);
  }

  Future<void> updateEstado(String id, String estado) async {
    await _reservacionService.updateEstado(id, estado);
  }

  void loadAllReservacionesAdmin() {
    _isLoading = true;
    notifyListeners();
    _reservacionService.getAllReservacionesAdmin().listen((reservaciones) {
      _reservaciones = reservaciones;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> deleteReservacion(String id) async {
    await _reservacionService.deleteReservacion(id);
  }
}