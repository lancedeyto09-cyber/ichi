import '../models/admin_user_management_model.dart';

class AdminUserService {
  static final List<AdminCustomerUser> _customers = [
    AdminCustomerUser(
      id: 'CUST-001',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+1-555-0101',
      registeredDate: DateTime.now().subtract(const Duration(days: 90)),
      totalOrders: 5,
      totalSpent: 1299.95,
      isActive: true,
      accountStatus: 'active',
      favoriteProducts: ['1', '3', '5'],
    ),
    AdminCustomerUser(
      id: 'CUST-002',
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '+1-555-0102',
      registeredDate: DateTime.now().subtract(const Duration(days: 60)),
      totalOrders: 3,
      totalSpent: 899.97,
      isActive: true,
      accountStatus: 'active',
      favoriteProducts: ['2', '4'],
    ),
    AdminCustomerUser(
      id: 'CUST-003',
      name: 'Mike Johnson',
      email: 'mike@example.com',
      phone: '+1-555-0103',
      registeredDate: DateTime.now().subtract(const Duration(days: 30)),
      totalOrders: 8,
      totalSpent: 2499.92,
      isActive: true,
      accountStatus: 'active',
      favoriteProducts: ['1', '2', '3', '4', '5'],
    ),
    AdminCustomerUser(
      id: 'CUST-004',
      name: 'Sarah Williams',
      email: 'sarah@example.com',
      phone: '+1-555-0104',
      registeredDate: DateTime.now().subtract(const Duration(days: 15)),
      totalOrders: 2,
      totalSpent: 599.98,
      isActive: false,
      accountStatus: 'suspended',
      favoriteProducts: ['3'],
    ),
  ];

  List<AdminCustomerUser> getAllCustomers() {
    return _customers;
  }

  List<AdminCustomerUser> getActiveCustomers() {
    return _customers
        .where((c) => c.isActive && c.accountStatus == 'active')
        .toList();
  }

  AdminCustomerUser? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<AdminCustomerUser> searchCustomers(String query) {
    return _customers
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void suspendCustomer(String customerId) {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final customer = _customers[index];
      _customers[index] = AdminCustomerUser(
        id: customer.id,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        profileImage: customer.profileImage,
        registeredDate: customer.registeredDate,
        totalOrders: customer.totalOrders,
        totalSpent: customer.totalSpent,
        isActive: false,
        accountStatus: 'suspended',
        favoriteProducts: customer.favoriteProducts,
      );
    }
  }

  void activateCustomer(String customerId) {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final customer = _customers[index];
      _customers[index] = AdminCustomerUser(
        id: customer.id,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        profileImage: customer.profileImage,
        registeredDate: customer.registeredDate,
        totalOrders: customer.totalOrders,
        totalSpent: customer.totalSpent,
        isActive: true,
        accountStatus: 'active',
        favoriteProducts: customer.favoriteProducts,
      );
    }
  }
}
