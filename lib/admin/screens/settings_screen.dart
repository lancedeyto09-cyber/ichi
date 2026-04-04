import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storeNameCtrl = TextEditingController(text: 'ICHI Music Store');
  final _storeEmailCtrl = TextEditingController(text: 'admin@ichi.com');
  final _storePhoneCtrl = TextEditingController(text: '+63 912 345 6789');
  final _storeAddressCtrl = TextEditingController(
    text: 'Urdaneta City, Pangasinan, Philippines',
  );

  final _currencyCtrl = TextEditingController(text: 'PHP');
  final _taxCtrl = TextEditingController(text: '12');
  final _shippingFeeCtrl = TextEditingController(text: '150');
  final _freeShippingCtrl = TextEditingController(text: '3000');

  bool emailNotifications = true;
  bool orderAlerts = true;
  bool lowStockAlerts = true;
  bool maintenanceMode = false;
  bool guestCheckout = true;
  bool autoApproveReviews = false;
  bool twoFactorAuth = false;

  String selectedTheme = 'Purple';
  String selectedTimeZone = 'Asia/Manila';
  String selectedOrderStatus = 'Processing';

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _storeEmailCtrl.dispose();
    _storePhoneCtrl.dispose();
    _storeAddressCtrl.dispose();
    _currencyCtrl.dispose();
    _taxCtrl.dispose();
    _shippingFeeCtrl.dispose();
    _freeShippingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 700;
    final isVerySmall = screenWidth < 380;

    final storeProfileCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Store Profile',
            'Core business information shown across the platform.',
          ),
          const SizedBox(height: 18),
          _textField(
            controller: _storeNameCtrl,
            label: 'Store Name',
            icon: Icons.store_mall_directory_rounded,
          ),
          const SizedBox(height: 14),
          _textField(
            controller: _storeEmailCtrl,
            label: 'Store Email',
            icon: Icons.email_rounded,
          ),
          const SizedBox(height: 14),
          _textField(
            controller: _storePhoneCtrl,
            label: 'Phone Number',
            icon: Icons.phone_rounded,
          ),
          const SizedBox(height: 14),
          _textField(
            controller: _storeAddressCtrl,
            label: 'Business Address',
            icon: Icons.location_on_rounded,
            maxLines: 2,
          ),
        ],
      ),
    );

    final appearanceCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Appearance & Region',
            'Visual preference and localization settings.',
          ),
          const SizedBox(height: 18),
          _dropdownField(
            label: 'Admin Theme',
            value: selectedTheme,
            icon: Icons.palette_rounded,
            items: const ['Purple', 'Lavender', 'Midnight'],
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedTheme = value);
              }
            },
          ),
          const SizedBox(height: 14),
          _dropdownField(
            label: 'Time Zone',
            value: selectedTimeZone,
            icon: Icons.schedule_rounded,
            items: const [
              'Asia/Manila',
              'UTC',
              'Asia/Singapore',
              'America/New_York',
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedTimeZone = value);
              }
            },
          ),
          const SizedBox(height: 14),
          _textField(
            controller: _currencyCtrl,
            label: 'Currency',
            icon: Icons.payments_rounded,
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryMid],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Keep your settings aligned with your customer-facing app branding for a more premium feel.',
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final checkoutCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Checkout & Shipping',
            'Purchase flow, shipping defaults, and order handling.',
          ),
          const SizedBox(height: 18),
          _textField(
            controller: _taxCtrl,
            label: 'Tax Rate (%)',
            icon: Icons.receipt_long_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _textField(
            controller: _shippingFeeCtrl,
            label: 'Base Shipping Fee',
            icon: Icons.local_shipping_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _textField(
            controller: _freeShippingCtrl,
            label: 'Free Shipping Threshold',
            icon: Icons.card_giftcard_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          _dropdownField(
            label: 'Default New Order Status',
            value: selectedOrderStatus,
            icon: Icons.inventory_rounded,
            items: const [
              'Pending',
              'Processing',
              'Packed',
              'Ready to Ship',
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedOrderStatus = value);
              }
            },
          ),
          const SizedBox(height: 16),
          _switchTile(
            title: 'Allow Guest Checkout',
            subtitle: 'Customers can place orders without signing in.',
            value: guestCheckout,
            onChanged: (value) {
              setState(() => guestCheckout = value);
            },
          ),
        ],
      ),
    );

    final notificationsCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Alerts & Notifications',
            'Control what the admin team gets notified about.',
          ),
          const SizedBox(height: 18),
          _switchTile(
            title: 'Email Notifications',
            subtitle: 'Receive system updates via email.',
            value: emailNotifications,
            onChanged: (value) {
              setState(() => emailNotifications = value);
            },
          ),
          _switchTile(
            title: 'Order Alerts',
            subtitle: 'Get notified about new and updated orders.',
            value: orderAlerts,
            onChanged: (value) {
              setState(() => orderAlerts = value);
            },
          ),
          _switchTile(
            title: 'Low Stock Alerts',
            subtitle: 'Receive alerts when inventory gets low.',
            value: lowStockAlerts,
            onChanged: (value) {
              setState(() => lowStockAlerts = value);
            },
          ),
          _switchTile(
            title: 'Auto Approve Reviews',
            subtitle: 'Publish new customer reviews without moderation.',
            value: autoApproveReviews,
            onChanged: (value) {
              setState(() => autoApproveReviews = value);
            },
          ),
        ],
      ),
    );

    final securityCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Security & Access',
            'Protect the admin panel and account workflows.',
          ),
          const SizedBox(height: 18),
          _switchTile(
            title: 'Two-Factor Authentication',
            subtitle: 'Require an extra verification step for admin sign-in.',
            value: twoFactorAuth,
            onChanged: (value) {
              setState(() => twoFactorAuth = value);
            },
          ),
          _switchTile(
            title: 'Maintenance Mode',
            subtitle:
                'Temporarily pause customer access while updating the store.',
            value: maintenanceMode,
            onChanged: (value) {
              setState(() => maintenanceMode = value);
            },
          ),
          const SizedBox(height: 14),
          _actionPanel(
            color: AppColors.primaryDark,
            icon: Icons.lock_reset_rounded,
            title: 'Reset Admin Password',
            text: 'Update the credentials used to access the admin dashboard.',
            buttonText: 'Reset',
          ),
          const SizedBox(height: 12),
          _actionPanel(
            color: AppColors.warningColor,
            icon: Icons.history_toggle_off_rounded,
            title: 'View Activity Logs',
            text: 'Review sign-ins, system changes, and account actions.',
            buttonText: 'Open Logs',
          ),
        ],
      ),
    );

    final saveCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Save & Deploy',
            'Review your setup and apply changes safely.',
          ),
          const SizedBox(height: 18),
          _summaryRow('Store Name', _storeNameCtrl.text),
          _summaryRow('Theme', selectedTheme),
          _summaryRow('Time Zone', selectedTimeZone),
          _summaryRow(
            'Notifications',
            emailNotifications ? 'Enabled' : 'Disabled',
          ),
          _summaryRow(
            'Maintenance',
            maintenanceMode ? 'On' : 'Off',
          ),
          _summaryRow(
            'Guest Checkout',
            guestCheckout ? 'Allowed' : 'Disabled',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.successColor.withOpacity(0.18),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.successColor,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your current settings are valid and ready to save.',
                    style: TextStyle(
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: BorderSide(
                      color: AppColors.primaryDark.withOpacity(0.28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Changes discarded')),
                    );
                  },
                  child: const Text(
                    'Discard',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved successfully'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: BorderSide(
                        color: AppColors.primaryDark.withOpacity(0.28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Changes discarded')),
                      );
                    },
                    child: const Text(
                      'Discard',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings saved successfully'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(isMobile),
            const SizedBox(height: 20),
            if (isMobile)
              Column(
                children: [
                  _statCard(
                    title: 'Store Status',
                    value: maintenanceMode ? 'Maintenance' : 'Live',
                    subtitle: 'Current storefront mode',
                    icon: Icons.storefront_rounded,
                    color: maintenanceMode
                        ? AppColors.warningColor
                        : AppColors.successColor,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  _statCard(
                    title: 'Notifications',
                    value: emailNotifications ? 'Enabled' : 'Off',
                    subtitle: 'Email system updates',
                    icon: Icons.notifications_active_rounded,
                    color: AppColors.primaryDark,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  _statCard(
                    title: 'Security',
                    value: twoFactorAuth ? '2FA On' : 'Basic',
                    subtitle: 'Admin account protection',
                    icon: Icons.verified_user_rounded,
                    color: AppColors.accentColor,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  _statCard(
                    title: 'Checkout',
                    value: guestCheckout ? 'Guest Allowed' : 'Members Only',
                    subtitle: 'Customer purchase flow',
                    icon: Icons.shopping_cart_checkout_rounded,
                    color: AppColors.warningColor,
                    fullWidth: true,
                  ),
                ],
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _statCard(
                    title: 'Store Status',
                    value: maintenanceMode ? 'Maintenance' : 'Live',
                    subtitle: 'Current storefront mode',
                    icon: Icons.storefront_rounded,
                    color: maintenanceMode
                        ? AppColors.warningColor
                        : AppColors.successColor,
                  ),
                  _statCard(
                    title: 'Notifications',
                    value: emailNotifications ? 'Enabled' : 'Off',
                    subtitle: 'Email system updates',
                    icon: Icons.notifications_active_rounded,
                    color: AppColors.primaryDark,
                  ),
                  _statCard(
                    title: 'Security',
                    value: twoFactorAuth ? '2FA On' : 'Basic',
                    subtitle: 'Admin account protection',
                    icon: Icons.verified_user_rounded,
                    color: AppColors.accentColor,
                  ),
                  _statCard(
                    title: 'Checkout',
                    value: guestCheckout ? 'Guest Allowed' : 'Members Only',
                    subtitle: 'Customer purchase flow',
                    icon: Icons.shopping_cart_checkout_rounded,
                    color: AppColors.warningColor,
                  ),
                ],
              ),
            const SizedBox(height: 22),
            if (isMobile) ...[
              storeProfileCard,
              const SizedBox(height: 16),
              appearanceCard,
              const SizedBox(height: 16),
              checkoutCard,
              const SizedBox(height: 16),
              notificationsCard,
              const SizedBox(height: 16),
              securityCard,
              const SizedBox(height: 16),
              saveCard,
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: storeProfileCard),
                  const SizedBox(width: 16),
                  Expanded(child: appearanceCard),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: checkoutCard),
                  const SizedBox(width: 16),
                  Expanded(child: notificationsCard),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: securityCard),
                  const SizedBox(width: 16),
                  Expanded(child: saveCard),
                ],
              ),
            ],
            if (isVerySmall) const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _header(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your store profile, checkout setup, security, and notification preferences.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryMid],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Store Config',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Manage your store profile, checkout setup, security, and notification preferences.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryMid],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Store Config',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    final card = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Icon(Icons.settings_suggest_rounded, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: card);
    return SizedBox(width: 255, child: card);
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMedium,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _inputDecoration(label, icon),
      borderRadius: BorderRadius.circular(16),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 430;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.16),
        ),
      ),
      child: isSmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Switch(
                    value: value,
                    activeColor: AppColors.primaryDark,
                    onChanged: onChanged,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  activeColor: AppColors.primaryDark,
                  onChanged: onChanged,
                ),
              ],
            ),
    );
  }

  Widget _actionPanel({
    required Color color,
    required IconData icon,
    required String title,
    required String text,
    required String buttonText,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 420;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: isSmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            text,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title clicked')),
                      );
                    },
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title clicked')),
                      );
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.textMedium,
        fontSize: 13,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon, color: AppColors.primaryDark),
      filled: true,
      fillColor: Colors.white.withOpacity(0.88),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primaryLight.withOpacity(0.32),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primaryDark,
          width: 1.4,
        ),
      ),
    );
  }
}
