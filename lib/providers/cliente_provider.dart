// lib/providers/cliente_provider.dart
import 'package:flutter/material.dart';
import '../services/cliente_service.dart';
import '../models/cliente_model.dart';

class ClienteProvider with ChangeNotifier {
  final ClienteService _clienteService = ClienteService();
  ClienteModel? _cliente;
  bool _isLoading = false;

  ClienteModel? get cliente => _cliente;
  bool get isLoading => _isLoading;

  Future<void> loadCliente(String id) async {
    _isLoading = true;
    notifyListeners();
    _cliente = await _clienteService.getCliente(id);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    await _clienteService.updateCliente(id, data);
    await loadCliente(id);
  }

  Stream<ClienteModel?> streamCliente(String id) {
    return _clienteService.streamCliente(id);
  }
}