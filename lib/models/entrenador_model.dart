// lib/models/entrenador_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EntrenadorModel {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String especialidad;
  final String? fotoUrl;
  final double calificacion;
  final int cantidadReviews;
  final String? descripcion;
  final List<String> certificaciones;
  final bool disponible;
  final DateTime fechaIngreso;

  EntrenadorModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.especialidad,
    this.fotoUrl,
    this.calificacion = 0.0,
    this.cantidadReviews = 0,
    this.descripcion,
    this.certificaciones = const [],
    this.disponible = true,
    required this.fechaIngreso,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory EntrenadorModel.fromMap(Map<String, dynamic> map, String id) {
    return EntrenadorModel(
      id: id,
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      especialidad: map['especialidad'] ?? '',
      fotoUrl: map['fotoUrl'],
      calificacion: (map['calificacion'] ?? 0).toDouble(),
      cantidadReviews: map['cantidadReviews'] ?? 0,
      descripcion: map['descripcion'],
      certificaciones: List<String>.from(map['certificaciones'] ?? []),
      disponible: map['disponible'] ?? true,
      fechaIngreso: (map['fechaIngreso'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'especialidad': especialidad,
      'fotoUrl': fotoUrl,
      'calificacion': calificacion,
      'cantidadReviews': cantidadReviews,
      'descripcion': descripcion,
      'certificaciones': certificaciones,
      'disponible': disponible,
      'fechaIngreso': Timestamp.fromDate(fechaIngreso),
    };
  }
}