// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDatabase({String? userId, List<String>? mascotaIds}) async {
    try {
      // Seed default admin user
      try {
        final auth = FirebaseAuth.instance;
        final adminQuery = await _firestore
            .collection('CLIENTES')
            .where('email', isEqualTo: 'admin@canis.com')
            .get();
            
        if (adminQuery.docs.isEmpty) {
          UserCredential cred = await auth.createUserWithEmailAndPassword(
            email: 'admin@canis.com',
            password: 'admin123',
          );
          await _firestore.collection('CLIENTES').doc(cred.user!.uid).set({
            'nombre': 'Admin',
            'apellido': 'Canis',
            'email': 'admin@canis.com',
            'telefono': '555-0100',
            'fechaRegistro': Timestamp.now(),
            'activo': true,
            'rol': 'admin',
          });
          debugPrint('Default Admin user registered successfully');
        } else {
          final adminDoc = adminQuery.docs.first;
          if (adminDoc['rol'] != 'admin') {
            await _firestore.collection('CLIENTES').doc(adminDoc.id).update({
              'rol': 'admin',
            });
          }
        }
      } catch (authError) {
        debugPrint('Admin user seeding check completed (user might already exist): $authError');
        try {
          final adminQuery = await _firestore
              .collection('CLIENTES')
              .where('email', isEqualTo: 'admin@canis.com')
              .get();
          if (adminQuery.docs.isNotEmpty && adminQuery.docs.first['rol'] != 'admin') {
            await _firestore.collection('CLIENTES').doc(adminQuery.docs.first.id).update({
              'rol': 'admin',
            });
          }
        } catch (updateError) {
          debugPrint('Error checking admin role: $updateError');
        }
      }

      final trainersSnap = await _firestore.collection('ENTRENADORES').get();
      List<String> trainerIds = [];

      if (trainersSnap.docs.isEmpty) {
        // Seed Trainers
        final trainers = [
          {
            'nombre': 'Carlos',
            'apellido': 'Mendoza',
            'email': 'carlos@canis.com',
            'telefono': '555-0199',
            'especialidad': 'Obediencia Básica y Socialización',
            'fotoUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
            'calificacion': 4.9,
            'cantidadReviews': 24,
            'descripcion': 'Especialista en cachorros y comportamiento canino.',
            'certificaciones': ['Adiestrador Certificado APDT', 'Primeros Auxilios Caninos'],
            'disponible': true,
            'fechaIngreso': Timestamp.now(),
          },
          {
            'nombre': 'Sofía',
            'apellido': 'Martínez',
            'email': 'sofia@canis.com',
            'telefono': '555-0188',
            'especialidad': 'Agility y Modificación de Conducta',
            'fotoUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200',
            'calificacion': 4.8,
            'cantidadReviews': 18,
            'descripcion': 'Amante de los perros de trabajo y experta en Agility competitivo.',
            'certificaciones': ['Certificación KPA CTP', 'Comportamiento Canino Avanzado'],
            'disponible': true,
            'fechaIngreso': Timestamp.now(),
          },
          {
            'nombre': 'Alejandro',
            'apellido': 'Ruiz',
            'email': 'alejandro@canis.com',
            'telefono': '555-0177',
            'especialidad': 'Guardia, Protección y Adiestramiento Avanzado',
            'fotoUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200',
            'calificacion': 5.0,
            'cantidadReviews': 12,
            'descripcion': 'Más de 10 años entrenando perros de servicio y protección familiar.',
            'certificaciones': ['Instructor de Perros de Utilidad', 'Adiestramiento IPO'],
            'disponible': true,
            'fechaIngreso': Timestamp.now(),
          }
        ];

        for (var t in trainers) {
          final docRef = await _firestore.collection('ENTRENADORES').add(t);
          trainerIds.add(docRef.id);
        }
        debugPrint('Seeded Trainers successfully');
      } else {
        trainerIds = trainersSnap.docs.map((doc) => doc.id).toList();
      }

      // Seed Services & Packages
      final servicesSnap = await _firestore.collection('SERVICIOS').get();
      if (servicesSnap.docs.isEmpty) {
        final servicesData = [
          {
            'nombre': 'Adiestramiento de Cachorros',
            'descripcion': 'Ideal para perritos de 2 a 6 meses. Socialización, control de mordida y comandos básicos.',
            'precioBase': 1500.0,
            'duracionMinutos': 45,
            'categoria': 'individual',
            'imagenUrl': 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=300',
            'activo': true,
            'incluye': ['Socialización con otros cachorros', 'Aprender a caminar con correa', 'Sentarse, echarse y quedarse', 'Asesoría para dueños'],
            'paquetes': [
              {
                'nombre': 'Paquete Cachorro Feliz',
                'descripcion': '5 sesiones intensivas para el nuevo integrante del hogar.',
                'precio': 6750.0,
                'numeroSesiones': 5,
                'duracionDias': 30,
                'beneficios': ['5 Sesiones personalizadas', 'Kit de clicker y premios gratis', 'Manual digital de entrenamiento', 'Graduación y diploma de cachorro'],
                'activo': true,
                'descuento': 10.0,
              }
            ]
          },
          {
            'nombre': 'Obediencia Urbana',
            'descripcion': 'Para perros de todas las edades. Comandos de control a distancia, caminar sin tirar de la correa en ambientes reales.',
            'precioBase': 2200.0,
            'duracionMinutos': 60,
            'categoria': 'individual',
            'imagenUrl': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&q=80&w=300',
            'activo': true,
            'incluye': ['Llamado confiable con distracciones', 'Caminar al junto sin correa', 'Echarse a distancia', 'Comportamiento en cafés y parques'],
            'paquetes': [
              {
                'nombre': 'Paquete Obediencia Pro',
                'descripcion': '10 sesiones individuales a domicilio o parque.',
                'precio': 18700.0,
                'numeroSesiones': 10,
                'duracionDias': 60,
                'beneficios': ['10 Sesiones individuales', 'Silbato de entrenamiento incluido', 'Seguimiento en video de cada sesión', 'Certificación de Obediencia Urbana'],
                'activo': true,
                'descuento': 15.0,
              }
            ]
          },
          {
            'nombre': 'Corrección de Conducta',
            'descripcion': 'Enfoque en problemas de reactividad, agresividad leve, ansiedad por separación o miedos extremos.',
            'precioBase': 3000.0,
            'duracionMinutos': 60,
            'categoria': 'individual',
            'imagenUrl': 'https://images.unsplash.com/photo-1537151625747-7ae8704189d4?auto=format&fit=crop&q=80&w=300',
            'activo': true,
            'incluye': ['Evaluación de temperamento', 'Plan de modificación personalizado', 'Sesiones controladas de contracondicionamiento', 'Soporte vía WhatsApp'],
            'paquetes': [
              {
                'nombre': 'Paquete Conducta Estable',
                'descripcion': '8 sesiones intensivas de modificación conductual.',
                'precio': 21120.0,
                'numeroSesiones': 8,
                'duracionDias': 45,
                'beneficios': ['8 Sesiones de corrección', 'Acceso a clases grupales de socialización', 'Soporte permanente del entrenador', 'Garantía de seguimiento a los 3 meses'],
                'activo': true,
                'descuento': 12.0,
              }
            ]
          }
        ];

        for (var service in servicesData) {
          final paquetes = service.remove('paquetes') as List<Map<String, dynamic>>;
          final sDoc = await _firestore.collection('SERVICIOS').add(service);

          for (var p in paquetes) {
            p['servicioId'] = sDoc.id;
            await _firestore.collection('PAQUETES').add(p);
          }
        }
        debugPrint('Seeded Services and Packages successfully');
      }

      // Seed Promotions
      final promoSnap = await _firestore.collection('PROMOCIONES').get();
      if (promoSnap.docs.isEmpty) {
        final promotions = [
          {
            'titulo': 'Descuento de Invierno',
            'descripcion': '¡15% de descuento en todos los paquetes individuales usando el código CANIS15!',
            'descuento': 15.0,
            'fechaInicio': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
            'fechaFin': Timestamp.fromDate(DateTime.now().add(const Duration(days: 45))),
            'codigo': 'CANIS15',
            'serviciosAplicables': [],
            'activo': true,
            'imagenUrl': 'https://images.unsplash.com/photo-1485988412941-77a35537dae4?auto=format&fit=crop&q=80&w=300',
            'terminosCondiciones': 'Válido para un uso por cliente.',
          },
          {
            'titulo': 'Cachorro Consentido',
            'descripcion': '¡Obtén un 20% de descuento en el Paquete Cachorro Feliz!',
            'descuento': 20.0,
            'fechaInicio': Timestamp.fromDate(DateTime.now()),
            'fechaFin': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
            'codigo': 'CACHORRO20',
            'serviciosAplicables': [],
            'activo': true,
            'imagenUrl': 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&q=80&w=300',
            'terminosCondiciones': 'Válido solo para cachorros menores a 6 meses.',
          }
        ];

        for (var p in promotions) {
          await _firestore.collection('PROMOCIONES').add(p);
        }
        debugPrint('Seeded Promotions successfully');
      }

      // Seed mock reviews
      final reviewsSnap = await _firestore.collection('REVIEWS').get();
      if (reviewsSnap.docs.isEmpty && trainerIds.isNotEmpty) {
        final reviews = [
          {
            'clienteId': userId ?? 'mock_user_id',
            'entrenadorId': trainerIds[0],
            'calificacion': 5,
            'comentario': 'Excelente entrenador, mi cachorro aprendió a sentarse y quedarse quieto en solo 3 sesiones.',
            'fecha': Timestamp.now(),
            'verificada': true,
          },
          {
            'clienteId': 'another_client',
            'entrenadorId': trainerIds[1],
            'calificacion': 4,
            'comentario': 'Muy profesional, gran paciencia y conocimiento en agility.',
            'fecha': Timestamp.now(),
            'verificada': true,
          }
        ];
        for (var r in reviews) {
          await _firestore.collection('REVIEWS').add(r);
        }
        debugPrint('Seeded Reviews successfully');
      }

      // Seed mock sessions and progress if userId and mascotaIds are provided
      if (userId != null && mascotaIds != null && mascotaIds.isNotEmpty && trainerIds.isNotEmpty) {
        final sessionsSnap = await _firestore.collection('SESIONES')
            .where('mascotaId', whereIn: mascotaIds)
            .get();

        if (sessionsSnap.docs.isEmpty) {
          final servicesSnapshot = await _firestore.collection('SERVICIOS').get();
          final serviceId = servicesSnapshot.docs.first.id;

          // Create past completed session
          final completedSessionRef = await _firestore.collection('SESIONES').add({
            'reservacionId': 'mock_res_1',
            'entrenadorId': trainerIds[0],
            'mascotaId': mascotaIds[0],
            'fecha': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
            'horaInicio': '09:00',
            'horaFin': '09:45',
            'estado': 'completada',
            'notas': 'Primera sesión de socialización. El perro estuvo receptivo pero un poco tímido al inicio.',
            'ubicacion': 'Parque Hundido',
          });

          // Add progress for the completed session
          await _firestore.collection('PROGRESOS').add({
            'mascotaId': mascotaIds[0],
            'sesionId': completedSessionRef.id,
            'entrenadorId': trainerIds[0],
            'fecha': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
            'observaciones': 'Logró socializar con dos perros de raza pequeña de manera pacífica. Mostró avances en el comando de atención.',
            'nivelEnergia': 4,
            'nivelObediencia': 3,
            'nivelSocializacion': 3,
            'habilidadesTrabajadas': ['Atención', 'Enfoque', 'Caminar junto'],
            'logros': ['Contacto visual constante', 'Socialización controlada'],
            'notasEntrenador': 'Seguir reforzando el contacto visual en la calle.',
            'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-playful-dog-in-the-grass-1175-large.mp4',
          });

          // Create upcoming programada session
          await _firestore.collection('SESIONES').add({
            'reservacionId': 'mock_res_2',
            'entrenadorId': trainerIds[0],
            'mascotaId': mascotaIds[0],
            'fecha': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
            'horaInicio': '10:00',
            'horaFin': '10:45',
            'estado': 'programada',
            'notas': 'Continuaremos trabajando en obediencia básica y llamado.',
            'ubicacion': 'Parque Hundido',
          });

          // Also seed a default booking/reservacion
          await _firestore.collection('RESERVACIONES').add({
            'clienteId': userId,
            'mascotaId': mascotaIds[0],
            'servicioId': serviceId,
            'entrenadorId': trainerIds[0],
            'fechaReserva': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
            'estado': 'confirmada',
            'precioTotal': 1500.0,
            'metodoPago': 'tarjeta',
            'pagado': true,
            'notasAdicionales': 'Favor de traer silbato',
          });

          // Seed a notification
          await _firestore.collection('NOTIFICACIONES').add({
            'clienteId': userId,
            'titulo': 'Nueva Reservación Confirmada',
            'mensaje': 'Tu sesión de adiestramiento para el parque ha sido confirmada.',
            'tipo': 'reservacion',
            'fechaCreacion': Timestamp.now(),
            'leida': false,
          });

          debugPrint('Seeded Mock Sessions, Progress, Reservations and Notifications successfully');
        }
      }
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }
}
