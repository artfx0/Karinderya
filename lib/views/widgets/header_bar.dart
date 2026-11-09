import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class HeaderBar extends StatefulWidget {
  final KarinderyaController controller;

  const HeaderBar({super.key, required this.controller});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    // Update live Philippine clock every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  DateTime get _philippineTime => DateTime.now().toUtc().add(const Duration(hours: 8));

  String _formatPhilippineClock(DateTime dt) {
    int hour = dt.hour;
    final String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    final String hourStr = hour.toString().padLeft(2, '0');
    final String minStr = dt.minute.toString().padLeft(2, '0');
    final String secStr = dt.second.toString().padLeft(2, '0');

    return '$hourStr:$minStr:$secStr $period';
  }

  String _formatPhilippineDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, $monthName ${dt.day}';
  }

  void _showNotificationsSheet(BuildContext context) {
    final lowStock = widget.controller.lowStockDishes;
    final readyOrders = widget.controller.readyOrders;
    final totalAlerts = lowStock.length + readyOrders.length;
    final isKitchen = widget.controller.kitchenMode;

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
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final totalAlerts = controller.lowStockDishes.length + controller.readyOrders.length;
    final staffName = controller.currentStaffName;
    final roleName = controller.role == UserRole.owner ? 'Owner' : 'Staff';

    final phtNow = _philippineTime;
    final formattedTime = _formatPhilippineClock(phtNow);
    final formattedDate = _formatPhilippineDate(phtNow);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Brand Title & Staff Tag (Left) + Top Actions (Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Store Title & Cashier Info
                Expanded(
                  child: Row(
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          roleName.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Action Icons (Kitchen Mode + Notifications)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      onPressed: () => controller.toggleKitchenMode(),
                      icon: Icon(
                        isKitchen ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        size: 20,
                      ),
                      tooltip: 'Kitchen Mode',
                    ),
                    const SizedBox(width: 6),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          onPressed: () => _showNotificationsSheet(context),
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                            size: 20,
                          ),
                          tooltip: 'Mga Alerto',
                        ),
                        if (totalAlerts > 0)
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.chiliRed,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                              alignment: Alignment.center,
                              child: Text(
                                '$totalAlerts',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
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
            const SizedBox(height: 8),

            // Row 2: Sub-bar with Store/Cashier name (Left) and Live Philippine Wall Clock Badge (Right)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Store & Cashier
                  Flexible(
                    child: Text(
                      "Aling Nena's • $staffName",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Live Philippine Wall Clock Badge (PST, UTC+8)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.leafGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedTime,
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• $formattedDate PST',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
