import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../services/checkout_service.dart';
import 'product_details_screen.dart';
import '../services/user_profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  int _selectedIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  Future<void> _logout() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);

    try {
      await auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
              title: const Text('Checkout'),
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
                          fontWeight: FontWeight.w700,
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Order placed successfully!',
                                  ),
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildCategoriesSection(),
                      const SizedBox(height: 28),
                      _buildFeaturedProductsSection(),
                      const SizedBox(height: 28),
                      _buildAllProductsSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                Provider.of<AuthService>(
                      context,
                      listen: false,
                    ).currentUser?.displayName ??
                    'User',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [AppColors.lightShadow],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (value) {
            Provider.of<ProductProvider>(
              context,
              listen: false,
            ).searchProducts(value);

            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search musical instruments...',
            hintStyle: const TextStyle(color: AppColors.textLight),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.primaryDark,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.primaryDark,
                    ),
                    onPressed: () {
                      _searchCtrl.clear();

                      Provider.of<ProductProvider>(
                        context,
                        listen: false,
                      ).searchProducts('');

                      setState(() {});
                    },
                  ),
                Consumer<ProductProvider>(
                  builder: (_, provider, __) {
                    final hasFilter = provider.searchQuery.isNotEmpty ||
                        provider.minPrice != null ||
                        provider.maxPrice != null ||
                        provider.sortBy != 'none' ||
                        provider.selectedCategory != 'All';

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primaryDark,
                          ),
                          onPressed: _showFilterSheet,
                        ),
                        if (hasFilter)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    final minCtrl = TextEditingController(
      text: provider.minPrice?.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: provider.maxPrice?.toString() ?? '',
    );

    String selectedSort = provider.sortBy;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min Price',
                            prefixText: '₱',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Price',
                            prefixText: '₱',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedSort,
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'none',
                        child: Text('Default'),
                      ),
                      DropdownMenuItem(
                        value: 'price_low',
                        child: Text('Price: Low to High'),
                      ),
                      DropdownMenuItem(
                        value: 'price_high',
                        child: Text('Price: High to Low'),
                      ),
                      DropdownMenuItem(
                        value: 'rating',
                        child: Text('Highest Rating'),
                      ),
                      DropdownMenuItem(
                        value: 'name',
                        child: Text('Name A-Z'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedSort = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            provider.clearFilters();
                            _searchCtrl.clear();
                            Navigator.pop(context);
                            setState(() {});
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final min = double.tryParse(minCtrl.text.trim());
                            final max = double.tryParse(maxCtrl.text.trim());

                            provider.setPriceFilter(min, max);
                            provider.setSort(selectedSort);

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: provider.categories.map((category) {
                    final isSelected = category == provider.selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => provider.filterByCategory(category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.95)
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryDark
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 340,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.featuredProducts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildProductCard(
                        provider.featuredProducts[index],
                        isFeatured: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllProductsSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${provider.products.length} result${provider.products.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.60,
                ),
                itemCount: provider.products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(provider.products[index]);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, {bool isFeatured = false}) {
    final hasNetworkImage = product.image.startsWith('http');

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
        width: isFeatured ? 240 : null,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.mediumShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isFeatured ? 150 : 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: hasNetworkImage
                          ? Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                            )
                          : Image.asset(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _imageFallback(),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<ProductProvider>(
                          context,
                          listen: false,
                        ).toggleFavorite(product.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [AppColors.lightShadow],
                        ),
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: product.isFavorite
                              ? Colors.red
                              : AppColors.textLight,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  if (product.stock <= 5)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Low Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${product.rating} (${product.reviews})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₱${product.price.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (product.stock <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('This product is out of stock.'),
                                  backgroundColor: AppColors.errorColor,
                                ),
                              );
                              return;
                            }

                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(product, quantity: 1);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart!'),
                                duration: const Duration(milliseconds: 800),
                                backgroundColor: AppColors.successColor,
                              ),
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(10),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [AppColors.heavyShadow],
      ),
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);

                if (index == 2) {
                  _showCartBottomSheet().then((_) {
                    if (mounted) {
                      setState(() => _selectedIndex = 0);
                    }
                  });
                } else if (index == 3) {
                  Navigator.pushNamed(context, '/saved').then((_) {
                    if (mounted) {
                      setState(() => _selectedIndex = 0);
                    }
                  });
                } else if (index == 4) {
                  Navigator.pushNamed(context, '/profile').then((_) {
                    if (mounted) {
                      setState(() => _selectedIndex = 0);
                    }
                  });
                } else if (index == 1) {
                  Navigator.pushNamed(context, '/explore').then((_) {
                    if (mounted) {
                      setState(() => _selectedIndex = 0);
                    }
                  });
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primaryDark,
              unselectedItemColor: AppColors.textLight,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_bag_outlined),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.errorColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_bag),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.errorColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_outline),
                  activeIcon: Icon(Icons.bookmark),
                  label: 'Saved',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCartBottomSheet() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            return DraggableScrollableSheet(
              initialChildSize: 0.78,
              minChildSize: 0.55,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: AppColors.textLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Shopping Cart',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            if (cartProvider.itemCount > 0)
                              TextButton.icon(
                                onPressed: () => cartProvider.clearCart(),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.errorColor,
                                ),
                                label: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: AppColors.errorColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: cartProvider.itemCount == 0
                            ? Center(
                                child: Container(
                                  margin: const EdgeInsets.all(24),
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 70,
                                        color: AppColors.textLight,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Your cart is empty',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Add products to your cart first.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: cartProvider.itemCount,
                                itemBuilder: (context, index) {
                                  final cartItem = cartProvider.items[index];
                                  final product = cartItem.product;
                                  final hasNetworkImage =
                                      product.image.startsWith('http');

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgLight,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: SizedBox(
                                            width: 76,
                                            height: 76,
                                            child: hasNetworkImage
                                                ? Image.network(
                                                    product.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            _imageFallback(),
                                                  )
                                                : Image.asset(
                                                    product.image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
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
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                product.category,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textMedium,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '₱${cartItem.totalPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.primaryDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                cartProvider.removeFromCart(
                                                  product.id,
                                                );
                                              },
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: AppColors.errorColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 18,
                                                  color: AppColors.errorColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: cartItem.quantity > 1
                                                      ? () {
                                                          cartProvider
                                                              .updateQuantity(
                                                            product.id,
                                                            cartItem.quantity -
                                                                1,
                                                          );
                                                        }
                                                      : null,
                                                  child: _cartQtyButton(
                                                    Icons.remove,
                                                    light: true,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 28,
                                                  child: Text(
                                                    '${cartItem.quantity}',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 13,
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: cartItem.quantity <
                                                          product.stock
                                                      ? () {
                                                          cartProvider
                                                              .updateQuantity(
                                                            product.id,
                                                            cartItem.quantity +
                                                                1,
                                                          );
                                                        }
                                                      : null,
                                                  child: _cartQtyButton(
                                                    Icons.add,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (cartProvider.itemCount > 0)
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 18,
                                offset: const Offset(0, -6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₱${cartProvider.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showCheckoutDialog();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.payment_rounded,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Proceed to Checkout',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _cartQtyButton(IconData icon, {bool light = false}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: light ? Colors.white : AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: light
            ? Border.all(color: AppColors.primaryDark.withOpacity(0.25))
            : null,
      ),
      child: Icon(
        icon,
        size: 15,
        color: light ? AppColors.primaryDark : Colors.white,
      ),
    );
  }

  Widget _imageFallback() {
    return Center(
      child: Icon(
        Icons.music_note,
        size: 40,
        color: Colors.purple.withOpacity(0.3),
      ),
    );
  }
}
