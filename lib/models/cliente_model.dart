// lib/models/cliente_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteModel {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String? direccion;
  final String? fotoUrl;
  final DateTime fechaRegistro;
  final bool activo;
  final String rol; // 'cliente' o 'admin'

  ClienteModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    this.direccion,
    this.fotoUrl,
    required this.fechaRegistro,
    this.activo = true,
    this.rol = 'cliente',
  });

  String get nombreCompleto => '$nombre $apellido';

  factory ClienteModel.fromMap(Map<String, dynamic> map, String id) {
    return ClienteModel(
      id: id,
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      direccion: map['direccion'],
      fotoUrl: map['fotoUrl'],
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
      activo: map['activo'] ?? true,
      rol: map['rol'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'fotoUrl': fotoUrl,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'activo': activo,
      'rol': rol,
    };
  }
}