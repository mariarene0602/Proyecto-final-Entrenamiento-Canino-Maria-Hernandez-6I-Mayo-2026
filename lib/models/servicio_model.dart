// lib/models/servicio_model.dart

class ServicioModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precioBase;
  final int duracionMinutos;
  final String categoria; // 'individual', 'grupal', 'intensivo'
  final String? imagenUrl;
  final bool activo;
  final List<String> incluye;

  ServicioModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioBase,
    required this.duracionMinutos,
    required this.categoria,
    this.imagenUrl,
    this.activo = true,
    this.incluye = const [],
  });

  factory ServicioModel.fromMap(Map<String, dynamic> map, String id) {
    return ServicioModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precioBase: (map['precioBase'] ?? 0).toDouble(),
      duracionMinutos: map['duracionMinutos'] ?? 60,
      categoria: map['categoria'] ?? 'individual',
      imagenUrl: map['imagenUrl'],
      activo: map['activo'] ?? true,
      incluye: List<String>.from(map['incluye'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precioBase': precioBase,
      'duracionMinutos': duracionMinutos,
      'categoria': categoria,
      'imagenUrl': imagenUrl,
      'activo': activo,
      'incluye': incluye,
    };
  }
}