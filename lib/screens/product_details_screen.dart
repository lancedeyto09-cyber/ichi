import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../services/auth_service.dart';
import '../services/checkout_service.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../services/user_profile_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  final ReviewService _reviewService = ReviewService();

  int _currentImage = 0;
  int _quantity = 1;

  List<String> get _images {
    if (widget.product.images.isNotEmpty) return widget.product.images;
    if (widget.product.image.isNotEmpty) return [widget.product.image];
    return [];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showAddReviewDialog(Product product) async {
    final commentController = TextEditingController();
    double selectedRating = 5;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rating',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;

                      return IconButton(
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starValue.toDouble();
                          });
                        },
                        icon: Icon(
                          starValue <= selectedRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFB800),
                          size: 30,
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      hintText: 'Write your review...',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please write a review comment.'),
                              ),
                            );
                            return;
                          }

                          try {
                            setDialogState(() => isSubmitting = true);

                            await _reviewService.addReview(
                              productId: product.id,
                              rating: selectedRating,
                              comment: commentController.text.trim(),
                            );

                            if (mounted) {
                              Navigator.pop(dialogContext);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review submitted!'),
                                  backgroundColor: AppColors.successColor,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _increaseQuantity() {
    if (_quantity < widget.product.stock) {
      setState(() => _quantity++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity reached available stock.'),
          backgroundColor: AppColors.warningColor,
        ),
      );
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _buyNow() async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (widget.product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This product is out of stock.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    cart.addToCart(widget.product, quantity: _quantity);
    await _showCheckoutDialog();
  }

  Future<void> _showCheckoutDialog() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    final checkoutService = CheckoutService();
    final profileService = UserProfileService();
    final profile = await profileService.getUserProfile();
    final address = Map<String, dynamic>.from(profile?['address'] ?? {});

    final nameController = TextEditingController(
      text: (profile?['username'] ?? auth.currentUser?.displayName ?? '')
          .toString(),
    );
    final emailController = TextEditingController(
      text: auth.currentUser?.email ?? '',
    );
    final phoneController = TextEditingController(
      text: (profile?['phone'] ?? '').toString(),
    );
    final houseNumberController = TextEditingController(
      text: (address['houseNumber'] ?? '').toString(),
    );
    final barangayController = TextEditingController(
      text: (address['barangay'] ?? '').toString(),
    );
    final cityController = TextEditingController(
      text: (address['municipalityOrCity'] ?? '').toString(),
    );
    final provinceController = TextEditingController(
      text: (address['province'] ?? '').toString(),
    );
    final zipController = TextEditingController(
      text: (address['zipCode'] ?? '').toString(),
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Buy Now'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: houseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'House Number / Street',
                      ),
                    ),
                    TextField(
                      controller: barangayController,
                      decoration: const InputDecoration(labelText: 'Barangay'),
                    ),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'Municipality or City',
                      ),
                    ),
                    TextField(
                      controller: provinceController,
                      decoration: const InputDecoration(labelText: 'Province'),
                    ),
                    TextField(
                      controller: zipController,
                      decoration: const InputDecoration(labelText: 'Zipcode'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Total: ₱${cartProvider.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty ||
                              phoneController.text.trim().isEmpty ||
                              houseNumberController.text.trim().isEmpty ||
                              barangayController.text.trim().isEmpty ||
                              cityController.text.trim().isEmpty ||
                              provinceController.text.trim().isEmpty ||
                              zipController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please complete all checkout fields.',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            setDialogState(() => isSubmitting = true);

                            await checkoutService.placeOrder(
                              cartItems: cartProvider.items,
                              totalAmount: cartProvider.totalPrice,
                              customerName: nameController.text.trim(),
                              customerEmail: emailController.text.trim(),
                              phoneNumber: phoneController.text.trim(),
                              houseNumber: houseNumberController.text.trim(),
                              barangay: barangayController.text.trim(),
                              municipalityOrCity: cityController.text.trim(),
                              province: provinceController.text.trim(),
                              zipCode: zipController.text.trim(),
                            );

                            cartProvider.clearCart();

                            if (mounted) {
                              Navigator.pop(dialogContext);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order placed successfully!'),
                                  backgroundColor: AppColors.successColor,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Place Order'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openFullscreen(int index) {
    if (_images.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenImageViewer(
          images: _images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildImageCarousel(),
                      _buildDetailsCard(product),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          const Expanded(
            child: Text(
              'Product Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [AppColors.mediumShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (_images.isEmpty)
                _imageFallback()
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  onPageChanged: (index) {
                    setState(() => _currentImage = index);
                  },
                  itemBuilder: (context, index) {
                    final image = _images[index];
                    final isNetwork = image.startsWith('http');

                    return GestureDetector(
                      onTap: () => _openFullscreen(index),
                      child: isNetwork
                          ? Image.network(
                              image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                            ),
                    );
                  },
                ),
              if (_images.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (index) => Container(
                        width: _currentImage == index ? 18 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentImage == index
                              ? AppColors.primaryDark
                              : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.zoom_in_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tap to zoom',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_images.length > 1)
          SizedBox(
            height: 72,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                final isNetwork = image.startsWith('http');
                final isSelected = _currentImage == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => _currentImage = index);

                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    width: 66,
                    height: 66,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryDark
                            : Colors.white.withOpacity(0.6),
                        width: isSelected ? 2.2 : 1,
                      ),
                      boxShadow: [AppColors.lightShadow],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isNetwork
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                            )
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDetailsCard(Product product) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.mediumShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Provider.of<ProductProvider>(
                    context,
                    listen: false,
                  ).toggleFavorite(product.id);
                },
                child: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: product.isFavorite ? Colors.red : AppColors.textLight,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.category,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB800),
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '${product.rating} (${product.reviews} reviews)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '₱${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuantitySelector(),
          const SizedBox(height: 14),
          _stockBadge(product),
          const SizedBox(height: 20),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _reviewsSection(product),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: product.stock <= 0
                      ? null
                      : () {
                          Provider.of<CartProvider>(context, listen: false)
                              .addToCart(product, quantity: _quantity);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.name} x$_quantity added to cart!',
                              ),
                              backgroundColor: AppColors.successColor,
                            ),
                          );
                        },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: product.stock <= 0 ? null : _buyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text('Buy Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    final maxStock = widget.product.stock;

    return Row(
      children: [
        const Text(
          'Quantity:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _decreaseQuantity,
          child: _qtyButton(Icons.remove),
        ),
        Container(
          width: 42,
          alignment: Alignment.center,
          child: Text(
            '$_quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
        ),
        GestureDetector(
          onTap: maxStock <= 0 ? null : _increaseQuantity,
          child: _qtyButton(Icons.add),
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _reviewAction(Product product) {
    return FutureBuilder<List<bool>>(
      future: Future.wait([
        _reviewService.hasDeliveredOrderForProduct(product.id),
        _reviewService.hasAlreadyReviewedProduct(product.id),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final canReview = snapshot.data?[0] ?? false;
        final alreadyReviewed = snapshot.data?[1] ?? false;

        if (alreadyReviewed) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Reviewed',
              style: TextStyle(
                color: AppColors.successColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          );
        }

        if (!canReview) {
          return const SizedBox.shrink();
        }

        return TextButton.icon(
          onPressed: () => _showAddReviewDialog(product),
          icon: const Icon(Icons.rate_review_rounded, size: 18),
          label: const Text('Add Review'),
        );
      },
    );
  }

  Widget _reviewsSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
            ),
            _reviewAction(product),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<ReviewModel>>(
          stream: _reviewService.getProductReviews(product.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final reviews = snapshot.data ?? [];

            if (reviews.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'No reviews yet.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            return Column(
              children: reviews.map((review) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.person, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              review.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB800),
                                size: 18,
                              ),
                              Text(
                                review.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        review.comment,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _stockBadge(Product product) {
    final isOut = product.stock <= 0;
    final isLow = product.stock <= 5 && product.stock > 0;

    Color color;
    String text;

    if (isOut) {
      color = AppColors.errorColor;
      text = 'Out of Stock';
    } else if (isLow) {
      color = AppColors.warningColor;
      text = 'Low Stock: ${product.stock} left';
    } else {
      color = AppColors.successColor;
      text = 'In Stock: ${product.stock} available';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Center(
      child: Icon(
        Icons.music_note,
        size: 64,
        color: Colors.purple.withOpacity(0.3),
      ),
    );
  }
}

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _fullscreenImage(String image) {
    final isNetwork = image.startsWith('http');

    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: isNetwork
            ? Image.network(
                image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              )
            : Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, index) {
              return _fullscreenImage(widget.images[index]);
            },
          ),
          Positioned(
            top: 42,
            left: 18,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Text(
              '${_current + 1}/${widget.images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 34,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (i) => Container(
                    width: _current == i ? 18 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _current == i ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
