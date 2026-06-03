// lib/models/instalacion_model.dart

class InstalacionModel {
  final String id;
  final String nombre;
  final String tipo; // 'pista', 'sala', 'patio', 'piscina'
  final int capacidad;
  final String? descripcion;
  final String? ubicacion;
  final bool disponible;
  final List<String> equipamiento;

  InstalacionModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.capacidad,
    this.descripcion,
    this.ubicacion,
    this.disponible = true,
    this.equipamiento = const [],
  });

  factory InstalacionModel.fromMap(Map<String, dynamic> map, String id) {
    return InstalacionModel(
      id: id,
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? '',
      capacidad: map['capacidad'] ?? 0,
      descripcion: map['descripcion'],
      ubicacion: map['ubicacion'],
      disponible: map['disponible'] ?? true,
      equipamiento: List<String>.from(map['equipamiento'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'capacidad': capacidad,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'disponible': disponible,
      'equipamiento': equipamiento,
    };
  }
}