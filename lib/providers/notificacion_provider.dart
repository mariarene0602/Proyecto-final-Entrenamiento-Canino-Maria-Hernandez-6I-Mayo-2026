// lib/providers/notificacion_provider.dart
import 'package:flutter/material.dart';
import '../services/notificacion_service.dart';
import '../models/notificacion_model.dart';

class NotificacionProvider with ChangeNotifier {
  final NotificacionService _notificacionService = NotificacionService();
  List<NotificacionModel> _notificaciones = [];
  bool _isLoading = false;

  List<NotificacionModel> get notificaciones => _notificaciones;
  bool get isLoading => _isLoading;
  int get notificacionesNoLeidas =>
      _notificaciones.where((n) => !n.leida).length;

  void loadNotificaciones(String clienteId) {
    _isLoading = true;
    notifyListeners();
    _notificacionService.getNotificaciones(clienteId).listen((notificaciones) {
      _notificaciones = notificaciones;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> marcarLeida(String id) async {
    await _notificacionService.marcarLeida(id);
  }

  Future<void> enviarNotificacion(NotificacionModel notificacion) async {
    await _notificacionService.enviarNotificacion(notificacion);
  }
}