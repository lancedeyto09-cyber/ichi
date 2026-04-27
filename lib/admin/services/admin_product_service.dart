import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_product_model.dart';

class AdminProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  Future<List<AdminProduct>> getAllProducts() async {
    final snapshot = await _productsRef.get();

    return snapshot.docs
        .map((doc) => AdminProduct.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<AdminProduct>> getProductsByCategory(String category) async {
    final snapshot =
        await _productsRef.where('category', isEqualTo: category).get();

    return snapshot.docs
        .map((doc) => AdminProduct.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<AdminProduct>> searchProducts(String query) async {
    final allProducts = await getAllProducts();
    final q = query.toLowerCase();

    return allProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<AdminProduct>> getLowStockProducts(int threshold) async {
    final allProducts = await getAllProducts();
    return allProducts.where((p) => p.stock <= threshold).toList();
  }

  Future<AdminProduct?> getProductById(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return AdminProduct.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateProduct(AdminProduct product) async {
    await _productsRef.doc(product.id).set(
          product.copyWith(updatedAt: DateTime.now()).toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> deleteProduct(String id) async {
    await _productsRef.doc(id).delete();
  }

  Future<void> addProduct(AdminProduct product) async {
    final docRef = product.id.trim().isNotEmpty
        ? _productsRef.doc(product.id)
        : _productsRef.doc();

    final productToSave = product.copyWith(
      id: docRef.id,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );

    await docRef.set(productToSave.toMap(), SetOptions(merge: true));
  }

  Future<List<String>> getAllCategories() async {
    final allProducts = await getAllProducts();
    return allProducts
        .map((p) => p.category)
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}
