import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to review.');
    }

    final productRef = _firestore.collection('products').doc(productId);
    final reviewsRef = productRef.collection('reviews');

    await _firestore.runTransaction((transaction) async {
      final newReviewRef = reviewsRef.doc();

      transaction.set(newReviewRef, {
        'userId': user.uid,
        'userName': user.displayName ?? 'User',
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    await _updateProductRating(productId);
  }

  Future<void> _updateProductRating(String productId) async {
    final productRef = _firestore.collection('products').doc(productId);
    final reviewsSnapshot = await productRef.collection('reviews').get();

    if (reviewsSnapshot.docs.isEmpty) {
      await productRef.update({
        'rating': 0.0,
        'reviews': 0,
      });
      return;
    }

    double totalRating = 0;

    for (final doc in reviewsSnapshot.docs) {
      final data = doc.data();
      final value = data['rating'];

      if (value is num) {
        totalRating += value.toDouble();
      }
    }

    final reviewCount = reviewsSnapshot.docs.length;
    final averageRating = totalRating / reviewCount;

    await productRef.update({
      'rating': double.parse(averageRating.toStringAsFixed(1)),
      'reviews': reviewCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
