// lib/models/pago_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PagoModel {
  final String id;
  final String clienteId;
  final String? reservacionId;
  final String? contratacionId;
  final double monto;
  final String metodoPago; // 'efectivo', 'tarjeta', 'transferencia'
  final DateTime fechaPago;
  final String estado; // 'completado', 'pendiente', 'reembolsado'
  final String? referencia;
  final String? comprobanteUrl;

  PagoModel({
    required this.id,
    required this.clienteId,
    this.reservacionId,
    this.contratacionId,
    required this.monto,
    required this.metodoPago,
    required this.fechaPago,
    this.estado = 'completado',
    this.referencia,
    this.comprobanteUrl,
  });

  factory PagoModel.fromMap(Map<String, dynamic> map, String id) {
    return PagoModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      reservacionId: map['reservacionId'],
      contratacionId: map['contratacionId'],
      monto: (map['monto'] ?? 0).toDouble(),
      metodoPago: map['metodoPago'] ?? 'efectivo',
      fechaPago: (map['fechaPago'] as Timestamp).toDate(),
      estado: map['estado'] ?? 'completado',
      referencia: map['referencia'],
      comprobanteUrl: map['comprobanteUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'reservacionId': reservacionId,
      'contratacionId': contratacionId,
      'monto': monto,
      'metodoPago': metodoPago,
      'fechaPago': Timestamp.fromDate(fechaPago),
      'estado': estado,
      'referencia': referencia,
      'comprobanteUrl': comprobanteUrl,
    };
  }
}