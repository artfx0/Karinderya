import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../theme/app_theme.dart';
import 'menu_setup_view.dart';
import 'owner_utang_tab_view.dart';
import 'sales_tab_view.dart';
import 'staff_tab_view.dart';

class OwnerDashboardView extends StatelessWidget {
  final KarinderyaController controller;

  const OwnerDashboardView({super.key, required this.controller});

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: controller.kitchenMode ? Colors.white : AppColors.paperCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mag-log out?',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        content: Text(
          'Babalik sa login screen ng Karinderya POS.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Kanselahin',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.darkBrown),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.chiliRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              controller.logout();
            },
            child: Text(
              'Oo, mag-log out',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Magandang umaga!';
    } else if (hour < 13) {
      return 'Magandang tanghali!';
    } else if (hour < 18) {
      return 'Magandang hapon!';
    } else {
      return 'Magandang gabi!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final currentIndex = controller.ownerTabIndex;

    return Scaffold(
      backgroundColor: isKitchen ? AppColors.kitchenBg : AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Owner Header Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                border: Border(
                  bottom: BorderSide(
                    color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                    width: isKitchen ? 2.5 : 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title & Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Karinderya',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.fredoka(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.brandOrange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'OWNER',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brandOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Aling Nena's - ${_getTimeGreeting()}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions: Kitchen Toggle & Logout Button (Strict RBAC: no Staff POS routing)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isKitchen ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                          color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        ),
                        onPressed: () => controller.toggleKitchenMode(),
                        tooltip: 'Kitchen Mode',
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.chiliRed),
                        onPressed: () => _showLogoutConfirmDialog(context),
                        tooltip: 'Mag-log out',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Views Body
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: [
                  SalesTabView(controller: controller),
                  MenuSetupView(controller: controller),
                  StaffTabView(controller: controller),
                  OwnerUtangTabView(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
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
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: currentIndex == 0 ? Icons.query_stats : Icons.query_stats_outlined,
                  label: 'Sales',
                  isSelected: currentIndex == 0,
                  onTap: () => controller.setOwnerTabIndex(0),
                  isKitchen: isKitchen,
                ),
                _buildNavItem(
                  icon: currentIndex == 1 ? Icons.restaurant_menu : Icons.restaurant_menu_outlined,
                  label: 'Menu Setup',
                  isSelected: currentIndex == 1,
                  onTap: () => controller.setOwnerTabIndex(1),
                  isKitchen: isKitchen,
                ),
                _buildNavItem(
                  icon: currentIndex == 2 ? Icons.badge : Icons.badge_outlined,
                  label: 'Staff',
                  isSelected: currentIndex == 2,
                  onTap: () => controller.setOwnerTabIndex(2),
                  isKitchen: isKitchen,
                ),
                _buildNavItem(
                  icon: currentIndex == 3 ? Icons.menu_book : Icons.menu_book_outlined,
                  label: 'Utang',
                  isSelected: currentIndex == 3,
                  onTap: () => controller.setOwnerTabIndex(3),
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
  }) {
    final color = isSelected
        ? AppColors.primary
        : (isKitchen ? AppColors.kitchenText : AppColors.mutedBrown);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
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
    );
  }
}
