// lib/models/mascota_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MascotaModel {
  final String id;
  final String nombre;
  final String especie; // 'perro', 'gato', etc.
  final String raza;
  final int edad;
  final double peso;
  final String? fotoUrl;
  final String clienteId;
  final DateTime fechaRegistro;
  final String? notasMedicas;
  final bool activo;

  MascotaModel({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.edad,
    required this.peso,
    this.fotoUrl,
    required this.clienteId,
    required this.fechaRegistro,
    this.notasMedicas,
    this.activo = true,
  });

  factory MascotaModel.fromMap(Map<String, dynamic> map, String id) {
    return MascotaModel(
      id: id,
      nombre: map['nombre'] ?? '',
      especie: map['especie'] ?? 'perro',
      raza: map['raza'] ?? '',
      edad: map['edad'] ?? 0,
      peso: (map['peso'] ?? 0).toDouble(),
      fotoUrl: map['fotoUrl'],
      clienteId: map['clienteId'] ?? '',
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
      notasMedicas: map['notasMedicas'],
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'edad': edad,
      'peso': peso,
      'fotoUrl': fotoUrl,
      'clienteId': clienteId,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'notasMedicas': notasMedicas,
      'activo': activo,
    };
  }
}