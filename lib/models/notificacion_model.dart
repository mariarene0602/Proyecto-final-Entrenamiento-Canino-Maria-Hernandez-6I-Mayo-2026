// lib/models/notificacion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacionModel {
  final String id;
  final String clienteId;
  final String titulo;
  final String mensaje;
  final String tipo; // 'reservacion', 'recordatorio', 'promocion', 'sistema'
  final DateTime fechaCreacion;
  final bool leida;
  final String? accionUrl;

  NotificacionModel({
    required this.id,
    required this.clienteId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.fechaCreacion,
    this.leida = false,
    this.accionUrl,
  });

  factory NotificacionModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificacionModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      titulo: map['titulo'] ?? '',
      mensaje: map['mensaje'] ?? '',
      tipo: map['tipo'] ?? 'sistema',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      leida: map['leida'] ?? false,
      accionUrl: map['accionUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'leida': leida,
      'accionUrl': accionUrl,
    };
  }
}