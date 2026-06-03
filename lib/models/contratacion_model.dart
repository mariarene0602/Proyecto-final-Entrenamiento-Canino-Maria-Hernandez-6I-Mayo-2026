// lib/models/contratacion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ContratacionModel {
  final String id;
  final String clienteId;
  final String paqueteId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int sesionesRestantes;
  final int sesionesTotales;
  final String estado; // 'activo', 'completado', 'cancelado'
  final double montoTotal;
  final bool pagado;

  ContratacionModel({
    required this.id,
    required this.clienteId,
    required this.paqueteId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.sesionesRestantes,
    required this.sesionesTotales,
    this.estado = 'activo',
    required this.montoTotal,
    this.pagado = false,
  });

  factory ContratacionModel.fromMap(Map<String, dynamic> map, String id) {
    return ContratacionModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      paqueteId: map['paqueteId'] ?? '',
      fechaInicio: (map['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (map['fechaFin'] as Timestamp).toDate(),
      sesionesRestantes: map['sesionesRestantes'] ?? 0,
      sesionesTotales: map['sesionesTotales'] ?? 0,
      estado: map['estado'] ?? 'activo',
      montoTotal: (map['montoTotal'] ?? 0).toDouble(),
      pagado: map['pagado'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'paqueteId': paqueteId,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'sesionesRestantes': sesionesRestantes,
      'sesionesTotales': sesionesTotales,
      'estado': estado,
      'montoTotal': montoTotal,
      'pagado': pagado,
    };
  }
}