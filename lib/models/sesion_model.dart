// lib/models/sesion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SesionModel {
  final String id;
  final String reservacionId;
  final String entrenadorId;
  final String mascotaId;
  final DateTime fecha;
  final String horaInicio; // Formato "HH:mm" ej: "09:00"
  final String horaFin;    // Formato "HH:mm" ej: "10:00"
  final String estado;     // 'programada', 'en_curso', 'completada', 'cancelada'
  final String? notas;
  final String? ubicacion;

  SesionModel({
    required this.id,
    required this.reservacionId,
    required this.entrenadorId,
    required this.mascotaId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.estado = 'programada',
    this.notas,
    this.ubicacion,
  });

  // Factory para crear desde Firestore
  factory SesionModel.fromMap(Map<String, dynamic> map, String id) {
    return SesionModel(
      id: id,
      reservacionId: map['reservacionId'] ?? '',
      entrenadorId: map['entrenadorId'] ?? '',
      mascotaId: map['mascotaId'] ?? '',
      fecha: (map['fecha'] as Timestamp).toDate(),
      horaInicio: map['horaInicio'] ?? '09:00',
      horaFin: map['horaFin'] ?? '10:00',
      estado: map['estado'] ?? 'programada',
      notas: map['notas'],
      ubicacion: map['ubicacion'],
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'reservacionId': reservacionId,
      'entrenadorId': entrenadorId,
      'mascotaId': mascotaId,
      'fecha': Timestamp.fromDate(fecha),
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'estado': estado,
      'notas': notas,
      'ubicacion': ubicacion,
    };
  }

  // Métodos helper para trabajar con horas
  DateTime get fechaHoraInicio {
    final partes = horaInicio.split(':');
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );
  }

  DateTime get fechaHoraFin {
    final partes = horaFin.split(':');
    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      int.parse(partes[0]),
      int.parse(partes[1]),
    );
  }

  // Duración en minutos
  int get duracionMinutos {
    final inicio = fechaHoraInicio;
    final fin = fechaHoraFin;
    return fin.difference(inicio).inMinutes;
  }

  // Para mostrar en la UI
  String get horarioFormateado => '$horaInicio - $horaFin';
  
  String get fechaFormateada => 
      '${fecha.day}/${fecha.month}/${fecha.year}';

  // Colores según estado
  String get estadoFormateado {
    switch (estado) {
      case 'programada':
        return 'Programada';
      case 'en_curso':
        return 'En Curso';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }
}