import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../constants/app_colors.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    final favorites = provider.products.where((p) => p.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'No saved products yet',
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final product = favorites[index];

                return _productCard(context, product);
              },
            ),
    );
  }

  Widget _productCard(BuildContext context, Product product) {
    final provider = context.read<ProductProvider>();
    final hasNetwork = product.image.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.mediumShadow],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: hasNetwork
                        ? Image.network(product.image, fit: BoxFit.cover)
                        : Image.asset(product.image, fit: BoxFit.cover),
                  ),

                  ///  REMOVE FAVORITE
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () {
                        provider.toggleFavorite(product.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₱${product.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
