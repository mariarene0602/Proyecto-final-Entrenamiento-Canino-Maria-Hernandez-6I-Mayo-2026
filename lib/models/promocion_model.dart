// lib/models/promocion_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PromocionModel {
  final String id;
  final String titulo;
  final String descripcion;
  final double descuento; // porcentaje
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? codigo;
  final List<String> serviciosAplicables;
  final bool activo;
  final String? imagenUrl;
  final String? terminosCondiciones;

  PromocionModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.descuento,
    required this.fechaInicio,
    required this.fechaFin,
    this.codigo,
    this.serviciosAplicables = const [],
    this.activo = true,
    this.imagenUrl,
    this.terminosCondiciones,
  });

  bool get estaVigente {
    final ahora = DateTime.now();
    return activo && ahora.isAfter(fechaInicio) && ahora.isBefore(fechaFin);
  }

  factory PromocionModel.fromMap(Map<String, dynamic> map, String id) {
    return PromocionModel(
      id: id,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      descuento: (map['descuento'] ?? 0).toDouble(),
      fechaInicio: (map['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (map['fechaFin'] as Timestamp).toDate(),
      codigo: map['codigo'],
      serviciosAplicables: List<String>.from(map['serviciosAplicables'] ?? []),
      activo: map['activo'] ?? true,
      imagenUrl: map['imagenUrl'],
      terminosCondiciones: map['terminosCondiciones'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'descuento': descuento,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'codigo': codigo,
      'serviciosAplicables': serviciosAplicables,
      'activo': activo,
      'imagenUrl': imagenUrl,
      'terminosCondiciones': terminosCondiciones,
    };
  }
}