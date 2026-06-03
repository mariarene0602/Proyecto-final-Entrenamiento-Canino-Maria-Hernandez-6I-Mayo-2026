// lib/models/progreso_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgresoModel {
  final String id;
  final String mascotaId;
  final String sesionId;
  final String entrenadorId;
  final DateTime fecha;
  final String observaciones;
  final int nivelEnergia; // 1-5
  final int nivelObediencia; // 1-5
  final int nivelSocializacion; // 1-5
  final List<String> habilidadesTrabajadas;
  final List<String> logros;
  final String? notasEntrenador;
  final String? videoUrl;

  ProgresoModel({
    required this.id,
    required this.mascotaId,
    required this.sesionId,
    required this.entrenadorId,
    required this.fecha,
    required this.observaciones,
    required this.nivelEnergia,
    required this.nivelObediencia,
    required this.nivelSocializacion,
    this.habilidadesTrabajadas = const [],
    this.logros = const [],
    this.notasEntrenador,
    this.videoUrl,
  });

  double get nivelPromedio =>
      (nivelEnergia + nivelObediencia + nivelSocializacion) / 3.0;

  factory ProgresoModel.fromMap(Map<String, dynamic> map, String id) {
    return ProgresoModel(
      id: id,
      mascotaId: map['mascotaId'] ?? '',
      sesionId: map['sesionId'] ?? '',
      entrenadorId: map['entrenadorId'] ?? '',
      fecha: (map['fecha'] as Timestamp).toDate(),
      observaciones: map['observaciones'] ?? '',
      nivelEnergia: map['nivelEnergia'] ?? 1,
      nivelObediencia: map['nivelObediencia'] ?? 1,
      nivelSocializacion: map['nivelSocializacion'] ?? 1,
      habilidadesTrabajadas: List<String>.from(map['habilidadesTrabajadas'] ?? []),
      logros: List<String>.from(map['logros'] ?? []),
      notasEntrenador: map['notasEntrenador'],
      videoUrl: map['videoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mascotaId': mascotaId,
      'sesionId': sesionId,
      'entrenadorId': entrenadorId,
      'fecha': Timestamp.fromDate(fecha),
      'observaciones': observaciones,
      'nivelEnergia': nivelEnergia,
      'nivelObediencia': nivelObediencia,
      'nivelSocializacion': nivelSocializacion,
      'habilidadesTrabajadas': habilidadesTrabajadas,
      'logros': logros,
      'notasEntrenador': notasEntrenador,
      'videoUrl': videoUrl,
    };
  }
}