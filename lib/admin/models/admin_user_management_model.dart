class AdminCustomerUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final DateTime registeredDate;
  final int totalOrders;
  final double totalSpent;
  final bool isActive;
  final String accountStatus; // active, suspended, deleted
  final List<String> favoriteProducts;

  AdminCustomerUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.registeredDate,
    required this.totalOrders,
    required this.totalSpent,
    required this.isActive,
    required this.accountStatus,
    required this.favoriteProducts,
  });
}
