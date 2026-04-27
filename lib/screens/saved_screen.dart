import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import 'product_details_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final savedProducts =
            provider.products.where((p) => p.isFavorite).toList();

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: savedProducts.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: savedProducts.length,
                            itemBuilder: (context, index) {
                              final product = savedProducts[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                          product: product),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.96),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [AppColors.mediumShadow],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: SizedBox(
                                          width: 82,
                                          height: 82,
                                          child: product.image
                                                  .startsWith('http')
                                              ? Image.network(
                                                  product.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _imageFallback(),
                                                )
                                              : Image.asset(
                                                  product.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _imageFallback(),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              product.category,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textMedium,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '₱${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.primaryDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              context
                                                  .read<ProductProvider>()
                                                  .toggleFavorite(product.id);
                                            },
                                            icon: const Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (product.stock <= 0) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'This product is out of stock.',
                                                    ),
                                                    backgroundColor:
                                                        AppColors.errorColor,
                                                  ),
                                                );
                                                return;
                                              }

                                              context
                                                  .read<CartProvider>()
                                                  .addToCart(product);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${product.name} added to cart!',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.successColor,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryDark,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Saved Items',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 70,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'No saved items yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the heart icon on products to save them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _imageFallback() {
    return Center(
      child: Icon(
        Icons.music_note,
        size: 36,
        color: Colors.purple.withOpacity(0.3),
      ),
    );
  }
}
