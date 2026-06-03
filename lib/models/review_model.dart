// lib/models/review_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String clienteId;
  final String entrenadorId;
  final String? servicioId;
  final String? reservacionId;
  final int calificacion; // 1-5
  final String? comentario;
  final DateTime fecha;
  final List<String>? fotos;
  final bool verificada;

  ReviewModel({
    required this.id,
    required this.clienteId,
    required this.entrenadorId,
    this.servicioId,
    this.reservacionId,
    required this.calificacion,
    this.comentario,
    required this.fecha,
    this.fotos,
    this.verificada = false,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      entrenadorId: map['entrenadorId'] ?? '',
      servicioId: map['servicioId'],
      reservacionId: map['reservacionId'],
      calificacion: map['calificacion'] ?? 3,
      comentario: map['comentario'],
      fecha: (map['fecha'] as Timestamp).toDate(),
      fotos: map['fotos'] != null ? List<String>.from(map['fotos']) : null,
      verificada: map['verificada'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'entrenadorId': entrenadorId,
      'servicioId': servicioId,
      'reservacionId': reservacionId,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha': Timestamp.fromDate(fecha),
      'fotos': fotos,
      'verificada': verificada,
    };
  }
}