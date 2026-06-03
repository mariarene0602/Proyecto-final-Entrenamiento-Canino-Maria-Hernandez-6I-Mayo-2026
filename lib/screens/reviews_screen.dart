// lib/screens/reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/review_provider.dart';
import '../providers/entrenador_provider.dart';
import '../models/review_model.dart';
import '../models/entrenador_model.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false).loadReviews();
      Provider.of<EntrenadorProvider>(context, listen: false).loadEntrenadores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final entrenadorProvider = Provider.of<EntrenadorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas de Entrenadores'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReviewDialog(context, entrenadorProvider.entrenadores),
        child: const Icon(Icons.rate_review),
      ),
      body: reviewProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.dorado))
          : reviewProvider.reviews.isEmpty
              ? _buildEmptyState()
              : _buildReviewList(reviewProvider.reviews, entrenadorProvider.entrenadores),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_outline, size: 80, color: AppColors.azulMarino.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay reseñas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sé el primero en calificar a nuestros entrenadores.',
            style: TextStyle(color: AppColors.textoClaro),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList(List<ReviewModel> reviews, List<EntrenadorModel> entrenadores) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        final trainer = entrenadores.firstWhere(
          (e) => e.id == review.entrenadorId,
          orElse: () => EntrenadorModel(
            id: '',
            nombre: 'Entrenador',
            apellido: '',
            email: '',
            telefono: '',
            especialidad: '',
            fechaIngreso: DateTime.now(),
          ),
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.azulMarino,
                            child: Text(
                              trainer.nombre[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trainer.nombreCompleto,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulMarino, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  trainer.especialidad,
                                  style: const TextStyle(color: AppColors.textoClaro, fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (review.verificada) ...[
                      const SizedBox(width: 8),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: AppColors.exito, size: 16),
                          SizedBox(width: 4),
                          Text('Verificado', style: TextStyle(color: AppColors.exito, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < review.calificacion ? Icons.star : Icons.star_border,
                      color: AppColors.dorado,
                      size: 20,
                    );
                  }),
                ),
                if (review.comentario != null && review.comentario!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    review.comentario!,
                    style: const TextStyle(color: AppColors.textoOscuro, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${review.fecha.day}/${review.fecha.month}/${review.fecha.year}',
                      style: const TextStyle(color: AppColors.textoClaro, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddReviewDialog(BuildContext context, List<EntrenadorModel> entrenadores) {
    if (entrenadores.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sin Entrenadores'),
          content: const Text('No hay entrenadores cargados en el sistema para poder evaluar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }

    final commentController = TextEditingController();
    EntrenadorModel selectedTrainer = entrenadores.first;
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Escribir Reseña'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona al entrenador:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<EntrenadorModel>(
                  initialValue: selectedTrainer,
                  isExpanded: true,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: entrenadores.map((e) => DropdownMenuItem(value: e, child: Text(e.nombreCompleto))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setStateDialog(() => selectedTrainer = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Calificación:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIndex) {
                    return IconButton(
                      icon: Icon(
                        starIndex < rating ? Icons.star : Icons.star_border,
                        color: AppColors.dorado,
                        size: 32,
                      ),
                      onPressed: () {
                        setStateDialog(() => rating = starIndex + 1);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Cuéntanos tu experiencia...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final review = ReviewModel(
                  id: '',
                  clienteId: authProvider.user?.uid ?? 'guest',
                  entrenadorId: selectedTrainer.id,
                  calificacion: rating,
                  comentario: commentController.text.trim(),
                  fecha: DateTime.now(),
                  verificada: true,
                );

                final success = await Provider.of<ReviewProvider>(context, listen: false)
                    .addReview(review);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Reseña guardada con éxito!'), backgroundColor: AppColors.exito),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}