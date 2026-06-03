// lib/models/reservacion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservacionModel {
  final String id;
  final String clienteId;
  final String mascotaId;
  final String servicioId;
  final String? paqueteId;
  final String entrenadorId;
  final String? instalacionId;
  final DateTime fechaReserva;
  final String estado; // 'pendiente', 'confirmada', 'en_curso', 'completada', 'cancelada'
  final double precioTotal;
  final String? metodoPago;
  final bool pagado;
  final String? notasAdicionales;

  ReservacionModel({
    required this.id,
    required this.clienteId,
    required this.mascotaId,
    required this.servicioId,
    this.paqueteId,
    required this.entrenadorId,
    this.instalacionId,
    required this.fechaReserva,
    this.estado = 'pendiente',
    required this.precioTotal,
    this.metodoPago,
    this.pagado = false,
    this.notasAdicionales,
  });

  factory ReservacionModel.fromMap(Map<String, dynamic> map, String id) {
    return ReservacionModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      mascotaId: map['mascotaId'] ?? '',
      servicioId: map['servicioId'] ?? '',
      paqueteId: map['paqueteId'],
      entrenadorId: map['entrenadorId'] ?? '',
      instalacionId: map['instalacionId'],
      fechaReserva: (map['fechaReserva'] as Timestamp).toDate(),
      estado: map['estado'] ?? 'pendiente',
      precioTotal: (map['precioTotal'] ?? 0).toDouble(),
      metodoPago: map['metodoPago'],
      pagado: map['pagado'] ?? false,
      notasAdicionales: map['notasAdicionales'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'mascotaId': mascotaId,
      'servicioId': servicioId,
      'paqueteId': paqueteId,
      'entrenadorId': entrenadorId,
      'instalacionId': instalacionId,
      'fechaReserva': Timestamp.fromDate(fechaReserva),
      'estado': estado,
      'precioTotal': precioTotal,
      'metodoPago': metodoPago,
      'pagado': pagado,
      'notasAdicionales': notasAdicionales,
    };
  }
}