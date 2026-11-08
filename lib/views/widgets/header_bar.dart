import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class HeaderBar extends StatelessWidget {
  final KarinderyaController controller;

  const HeaderBar({super.key, required this.controller});

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

  void _showNotificationsSheet(BuildContext context) {
    final lowStock = controller.lowStockDishes;
    final readyOrders = controller.readyOrders;
    final totalAlerts = lowStock.length + readyOrders.length;
    final isKitchen = controller.kitchenMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
            maxWidth: 600,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
              width: isKitchen ? 2.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Mga Alerto ($totalAlerts)',
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: AppColors.line, height: 24),
              if (totalAlerts == 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: SvgPicture.asset('assets/empty-pot.svg'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sapat pa lahat!',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Walang ulam na paubos at walang nakatenggang order.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.mutedBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (readyOrders.isNotEmpty) ...[
                        Text(
                          'HANDA NANG ISERBE',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.leafGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...readyOrders.map(
                          (order) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.leafGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.leafGreen.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: AppColors.leafGreen, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Order #${order.id} (${order.kind == OrderKind.takeout ? "Takeout" : "Table ${order.tableNum}"}) is READY!',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (lowStock.isNotEmpty) ...[
                        Text(
                          'PAUBOS NA ULAM',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.chiliRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...lowStock.map(
                          (dish) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.chiliRed.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.chiliRed.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: AppColors.chiliRed, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${dish.name} — ${dish.stock} na lang ang natitira!',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final totalAlerts = controller.lowStockDishes.length + controller.readyOrders.length;
    final roleName = controller.role == UserRole.owner ? 'Aling Nena / Owner' : 'Ana / Staff';

    return Container(
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
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Store Title & Time Greeting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTimeGreeting(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Aling Nena's - $roleName",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Top Action Icons (Kitchen Mode + Notifications)
            Row(
              children: [
                // Kitchen Mode Toggle (Sun icon)
                IconButton(
                  onPressed: () => controller.toggleKitchenMode(),
                  icon: Icon(
                    isKitchen ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                    color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                    size: 24,
                  ),
                  tooltip: 'Kitchen Mode',
                ),

                // Notifications Bell
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => _showNotificationsSheet(context),
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        size: 24,
                      ),
                      tooltip: 'Mga Alerto',
                    ),
                    if (totalAlerts > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.chiliRed,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          alignment: Alignment.center,
                          child: Text(
                            '$totalAlerts',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
