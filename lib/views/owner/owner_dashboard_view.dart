import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import 'menu_setup_view.dart';
import 'owner_utang_tab_view.dart';
import 'sales_tab_view.dart';
import 'staff_tab_view.dart';

class OwnerDashboardView extends StatelessWidget {
  final KarinderyaController controller;

  const OwnerDashboardView({super.key, required this.controller});

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Karinderya',
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
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
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
                        ),
                      ),
                    ],
                  ),

                  // Actions: Kitchen Toggle & "Staff POS" Pill Button
                  Row(
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

                      // "Staff POS" Pill Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: isKitchen ? 0 : 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          minimumSize: const Size(100, 44),
                        ),
                        icon: const Icon(Icons.point_of_sale, size: 18),
                        label: Text(
                          'Staff POS',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: () => controller.setScreen(ScreenState.staff),
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
