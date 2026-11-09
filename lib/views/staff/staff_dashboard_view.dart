import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import '../sheets/new_order_sheet.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/header_bar.dart';
import 'menu_tab_view.dart';
import 'order_history_view.dart';
import 'orders_tab_view.dart';
import 'shift_summary_view.dart';
import 'staff_settings_view.dart';

class StaffDashboardView extends StatelessWidget {
  final KarinderyaController controller;

  const StaffDashboardView({super.key, required this.controller});

  void _openNewOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => NewOrderSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final currentIndex = controller.staffTabIndex.clamp(0, 4);
    final activeOrdersCount = controller.getOrderCountByStatus(OrderStatus.preparing) +
        controller.getOrderCountByStatus(OrderStatus.ready);

    return Scaffold(
      backgroundColor: isKitchen ? AppColors.kitchenBg : AppColors.warmCream,
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openNewOrderSheet(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: Text(
                'Bagong Order',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar with Live Philippine Standard Time (PST) Clock
            HeaderBar(controller: controller),

            // Tab Body with Stack for Floating Cart Bar
            Expanded(
              child: Stack(
                children: [
                  // Tab Screens
                  IndexedStack(
                    index: currentIndex,
                    children: [
                      MenuTabView(controller: controller),
                      OrdersTabView(controller: controller),
                      OrderHistoryView(controller: controller),
                      ShiftSummaryView(controller: controller),
                      StaffSettingsView(controller: controller),
                    ],
                  ),

                  // Floating Cart Bar (Above Bottom Nav)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: FloatingCartBar(controller: controller),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 5-Tab Ergonomic Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
          border: Border(
            top: BorderSide(
              color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
              width: isKitchen ? 2.5 : 1.0,
            ),
          ),
          boxShadow: isKitchen
              ? null
              : [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 1. Menu Tab
                _buildNavItem(
                  icon: currentIndex == 0 ? Icons.restaurant_menu : Icons.restaurant_menu_outlined,
                  label: 'Menu',
                  isSelected: currentIndex == 0,
                  onTap: () => controller.setStaffTabIndex(0),
                  isKitchen: isKitchen,
                ),

                // 2. Active Orders Tab
                _buildNavItem(
                  icon: currentIndex == 1 ? Icons.receipt_long : Icons.receipt_long_outlined,
                  label: 'Orders',
                  badgeCount: activeOrdersCount > 0 ? activeOrdersCount : null,
                  isSelected: currentIndex == 1,
                  onTap: () => controller.setStaffTabIndex(1),
                  isKitchen: isKitchen,
                ),

                // 3. Order History Tab
                _buildNavItem(
                  icon: currentIndex == 2 ? Icons.history : Icons.history_outlined,
                  label: 'History',
                  isSelected: currentIndex == 2,
                  onTap: () => controller.setStaffTabIndex(2),
                  isKitchen: isKitchen,
                ),

                // 4. Shift Summary Tab
                _buildNavItem(
                  icon: currentIndex == 3 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
                  label: 'Shift',
                  isSelected: currentIndex == 3,
                  onTap: () => controller.setStaffTabIndex(3),
                  isKitchen: isKitchen,
                ),

                // 5. Settings Tab
                _buildNavItem(
                  icon: currentIndex == 4 ? Icons.settings : Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: currentIndex == 4,
                  onTap: () => controller.setStaffTabIndex(4),
                  isKitchen: isKitchen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isKitchen,
    int? badgeCount,
  }) {
    final color = isSelected
        ? AppColors.primary
        : (isKitchen ? AppColors.kitchenText : AppColors.mutedBrown);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 24),
                  if (badgeCount != null)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: const BoxDecoration(
                          color: AppColors.chiliRed,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
