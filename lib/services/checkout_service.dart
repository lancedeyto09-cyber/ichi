import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> placeOrder({
    required List<CartItem> cartItems,
    required double totalAmount,
    required String customerName,
    required String customerEmail,
    required String phoneNumber,
    required String houseNumber,
    required String barangay,
    required String municipalityOrCity,
    required String province,
    required String zipCode,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to place an order.');
    }

    if (cartItems.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    await _firestore.runTransaction((transaction) async {
      final productRefs = cartItems
          .map((item) => _firestore.collection('products').doc(item.product.id))
          .toList();

      final productSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];

      for (final ref in productRefs) {
        final snapshot = await transaction.get(ref);
        productSnapshots.add(snapshot);
      }

      for (int i = 0; i < cartItems.length; i++) {
        final cartItem = cartItems[i];
        final productSnapshot = productSnapshots[i];

        if (!productSnapshot.exists) {
          throw Exception('${cartItem.product.name} not found in products.');
        }

        final data = productSnapshot.data();
        if (data == null) {
          throw Exception('${cartItem.product.name} has invalid data.');
        }

        final currentStock = ((data['stock'] ?? 0) as num).toInt();

        if (currentStock < cartItem.quantity) {
          throw Exception(
            'Not enough stock for ${cartItem.product.name}. Available: $currentStock',
          );
        }
      }

      final orderRef = _firestore.collection('orders').doc();

      final items = cartItems.map((item) {
        return {
          'productId': item.product.id,
          'productName': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      transaction.set(orderRef, {
        'id': orderRef.id,
        'customerId': user.uid,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'totalAmount': totalAmount,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'paymentStatus': 'pending',
        'trackingNumber': null,
        'items': items,
        'shippingInfo': {
          'barangay': barangay,
          'house number': houseNumber,
          'municipality or city': municipalityOrCity,
          'phone number': phoneNumber,
          'province': province,
          'zipcode': zipCode,
        },
      });

      for (int i = 0; i < cartItems.length; i++) {
        final cartItem = cartItems[i];
        final productRef = productRefs[i];
        final productSnapshot = productSnapshots[i];
        final data = productSnapshot.data()!;
        final currentStock = ((data['stock'] ?? 0) as num).toInt();

        transaction.update(productRef, {
          'stock': currentStock - cartItem.quantity,
        });
      }
    });
  }
}
