// lib/providers/review_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  void loadReviews() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _reviewService.getAllReviews().listen(
      (data) {
        _reviews = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void loadReviewsEntrenador(String entrenadorId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _reviewService.getReviewsEntrenador(entrenadorId).listen(
      (data) {
        _reviews = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addReview(ReviewModel review) async {
    try {
      await _reviewService.addReview(review);
      return true;
    } catch (e) {
      debugPrint('Error leaving review: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
