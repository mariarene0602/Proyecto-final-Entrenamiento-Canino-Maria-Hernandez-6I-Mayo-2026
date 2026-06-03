// lib/models/paquete_model.dart

class PaqueteModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int numeroSesiones;
  final int duracionDias;
  final String servicioId;
  final List<String> beneficios;
  final bool activo;
  final double descuento; // porcentaje

  PaqueteModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.numeroSesiones,
    required this.duracionDias,
    required this.servicioId,
    this.beneficios = const [],
    this.activo = true,
    this.descuento = 0,
  });

  factory PaqueteModel.fromMap(Map<String, dynamic> map, String id) {
    return PaqueteModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      numeroSesiones: map['numeroSesiones'] ?? 0,
      duracionDias: map['duracionDias'] ?? 30,
      servicioId: map['servicioId'] ?? '',
      beneficios: List<String>.from(map['beneficios'] ?? []),
      activo: map['activo'] ?? true,
      descuento: (map['descuento'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'numeroSesiones': numeroSesiones,
      'duracionDias': duracionDias,
      'servicioId': servicioId,
      'beneficios': beneficios,
      'activo': activo,
      'descuento': descuento,
    };
  }
}