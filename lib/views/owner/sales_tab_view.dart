import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class SalesTabView extends StatefulWidget {
  final KarinderyaController controller;

  const SalesTabView({super.key, required this.controller});

  @override
  State<SalesTabView> createState() => _SalesTabViewState();
}

class _SalesTabViewState extends State<SalesTabView> {
  final TextEditingController _cashCountController = TextEditingController();

  @override
  void dispose() {
    _cashCountController.dispose();
    super.dispose();
  }

  void _showEditGoalDialog(BuildContext context) {
    final goalController = TextEditingController(
      text: widget.controller.dailyGoal.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.controller.kitchenMode ? Colors.white : AppColors.paperCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'I-set ang Daily Sales Goal',
          style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target na benta sa araw na ito:',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedBrown),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₱ ',
                filled: true,
                fillColor: AppColors.warmCream,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kanselahin'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newGoal = double.tryParse(goalController.text.trim()) ?? widget.controller.dailyGoal;
              widget.controller.updateDailyGoal(newGoal);
              Navigator.pop(ctx);
            },
            child: const Text('I-save'),
          ),
        ],
      ),
    );
  }

  void _openDrawer(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_open, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Cash drawer opened.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.darkBrown,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;

    // Sales Calculations
    final totalSales = controller.orders.fold(0.0, (sum, o) => sum + o.total);
    final cashSales = controller.orders
        .where((o) => o.payStatus == PaymentStatus.paid)
        .fold(0.0, (sum, o) => sum + o.total);
    final utangSales = controller.orders
        .where((o) => o.payStatus == PaymentStatus.onDebt)
        .fold(0.0, (sum, o) => sum + o.total);

    final goal = controller.dailyGoal;
    final goalRatio = (totalSales / goal).clamp(0.0, 1.0);

    // Dine-In vs Takeout
    final dineInCount = controller.orders.where((o) => o.kind == OrderKind.dineIn).length;
    final takeoutCount = controller.orders.where((o) => o.kind == OrderKind.takeout).length;
    final totalOrdersCount = controller.orders.length;
    final dineInPercent = totalOrdersCount > 0 ? (dineInCount / totalOrdersCount * 100).round() : 50;
    final takeoutPercent = 100 - dineInPercent;

    // Cash Count Calculation
    final countedCash = double.tryParse(_cashCountController.text.trim()) ?? cashSales;
    final diff = countedCash - cashSales;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Sales Card with Goal Ring
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenBorder : AppColors.brandOrange,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isKitchen
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.brandOrange.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's sales",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warmCream.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${totalSales.toStringAsFixed(0)}',
                          style: GoogleFonts.fredoka(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.trending_up, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+12% vs kahapon',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Goal Progress Ring (Tappable to edit)
                  InkWell(
                    onTap: () => _showEditGoalDialog(context),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: goalRatio,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(goalRatio * 100).round()}%',
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'of ₱${(goal / 1000).toStringAsFixed(1)}k',
                                style: GoogleFonts.inter(fontSize: 9, color: Colors.white),
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
            const SizedBox(height: 16),

            // Quick Actions: Set Today's Menu & Open Drawer
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: isKitchen ? 0 : 2,
                    ),
                    icon: const Icon(Icons.restaurant_menu, size: 20),
                    label: const Text('Set today’s menu'),
                    onPressed: () => controller.setOwnerTabIndex(1), // Switch to Menu Setup
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBrown,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                        width: isKitchen ? 2 : 1.5,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.point_of_sale, size: 20),
                    label: const Text('Open drawer'),
                    onPressed: () => _openDrawer(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top-Selling Dish Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.categoryUlam, width: 2),
                      color: AppColors.warmCream,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset('assets/adobo.svg'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.mustard, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'PINAKA-MABENTA (TOP SELLER)',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Chicken Adobo',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                        Text(
                          '15 orders served today (₱1,350 total)',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Low Servings Chips Row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Imbentaryo / Paubos na:',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (controller.lowStockDishes.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.leafGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.leafGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.leafGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Sapat pa lahat ng ulam',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.leafGreen,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: controller.lowStockDishes.map((dish) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            avatar: const Icon(Icons.warning_amber_rounded, color: AppColors.chiliRed, size: 16),
                            label: Text('${dish.name}: ${dish.stock} left'),
                            backgroundColor: AppColors.chiliRed.withValues(alpha: 0.1),
                            side: BorderSide(color: AppColors.chiliRed.withValues(alpha: 0.3)),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.chiliRed,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Cash Sales vs Utang Metric Cards Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                        width: isKitchen ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cash Sales',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${cashSales.toStringAsFixed(0)}',
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.leafGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                        width: isKitchen ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nailistang Utang',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${utangSales.toStringAsFixed(0)}',
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.chiliRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekly Sales Bar Chart
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benta Ngayong Linggo (Weekly)',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildWeeklyBar('Mon', 0.45, false, '₱2.2k'),
                      _buildWeeklyBar('Tue', 0.60, false, '₱3.0k'),
                      _buildWeeklyBar('Wed', 0.55, false, '₱2.8k'),
                      _buildWeeklyBar('Thu', 0.70, false, '₱3.5k'),
                      _buildWeeklyBar('Fri', 0.85, false, '₱4.2k'),
                      _buildWeeklyBar('Sat', 0.95, false, '₱4.8k'),
                      _buildWeeklyBar('Sun', goalRatio, true, 'Today'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dine-in vs Takeout Donut / Proportion
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dine-in laban sa Takeout',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: dineInPercent,
                          child: Container(
                            height: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          flex: takeoutPercent,
                          child: Container(
                            height: 16,
                            color: AppColors.mustard,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 12, height: 12, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Dine-In ($dineInPercent%) - $dineInCount orders'),
                        ],
                      ),
                      Row(
                        children: [
                          Container(width: 12, height: 12, color: AppColors.mustard),
                          const SizedBox(width: 6),
                          Text('Takeout ($takeoutPercent%) - $takeoutCount orders'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cash Count Reconciliation Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cash Count Reconciliation',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      _buildReconciliationBadge(diff),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inaasahang Cash sa Drawer: ₱${cashSales.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cashCountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Ilagay ang aktwal na nabilang na cash...',
                      prefixText: '₱ ',
                      filled: true,
                      fillColor: isKitchen ? Colors.white : AppColors.warmCream,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBar(String day, double ratio, bool isToday, String label) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppColors.primary : AppColors.mutedBrown,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 22,
          height: 90 * ratio,
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : AppColors.mustard.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: isToday ? AppColors.primary : AppColors.darkBrown,
          ),
        ),
      ],
    );
  }

  Widget _buildReconciliationBadge(double diff) {
    if (diff == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.leafGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Balanced',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.leafGreen),
        ),
      );
    } else if (diff > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.mustard.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Over by ₱${diff.toStringAsFixed(0)}',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.chiliRed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Short by ₱${(-diff).toStringAsFixed(0)}',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.chiliRed),
        ),
      );
    }
  }
}
