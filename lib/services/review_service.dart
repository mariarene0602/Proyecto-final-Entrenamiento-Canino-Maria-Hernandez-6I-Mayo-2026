// lib/services/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todas las reseñas
  Stream<List<ReviewModel>> getAllReviews() {
    return _firestore
        .collection('REVIEWS')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Obtener reseñas de un entrenador específico
  Stream<List<ReviewModel>> getReviewsEntrenador(String entrenadorId) {
    return _firestore
        .collection('REVIEWS')
        .where('entrenadorId', isEqualTo: entrenadorId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Agregar reseña
  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('REVIEWS').add(review.toMap());
    
    // Opcional: Actualizar promedio del entrenador
    final trainerDoc = await _firestore.collection('ENTRENADORES').doc(review.entrenadorId).get();
    if (trainerDoc.exists) {
      final data = trainerDoc.data()!;
      final currentRating = (data['calificacion'] ?? 0.0).toDouble();
      final currentReviewsCount = data['cantidadReviews'] ?? 0;
      
      final newReviewsCount = currentReviewsCount + 1;
      final newRating = ((currentRating * currentReviewsCount) + review.calificacion) / newReviewsCount;
      
      await _firestore.collection('ENTRENADORES').doc(review.entrenadorId).update({
        'calificacion': double.parse(newRating.toStringAsFixed(1)),
        'cantidadReviews': newReviewsCount,
      });
    }
  }
}
