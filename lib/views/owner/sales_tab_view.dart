import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_live_clock.dart';
import 'sales_detail_report_view.dart';

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

  String _formatDateLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final target = DateTime(date.year, date.month, date.day);

    final formatted = '${months[date.month - 1]} ${date.day}, ${date.year}';
    if (target == today) return 'Ngayon • $formatted';
    if (target == yesterday) return 'Kahapon • $formatted';
    return formatted;
  }

  void _openReactiveCalendarSheet(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: isKitchen ? Colors.white : AppColors.paperCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
            width: isKitchen ? 2.5 : 1.0,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Pumili ng Petsa ng Benta',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      tooltip: 'Isara',
                    ),
                  ],
                ),
              ),
              // Reactive CalendarDatePicker: zero Apply/Submit/Enter buttons
              Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: isKitchen ? Colors.white : AppColors.paperCard,
                    onSurface: AppColors.darkBrown,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: controller.selectedSalesDate,
                  firstDate: DateTime(2024, 1, 1),
                  lastDate: DateTime(now.year, now.month, now.day),
                  onDateChanged: (pickedDate) {
                    controller.setSalesDate(pickedDate);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final selectedDate = controller.selectedSalesDate;
    final isToday = controller.isSelectedSalesDateToday;

    // Date-Scoped Reactive Sales Calculations
    final activeOrders = controller.ordersForSelectedDate;
    final totalSales = controller.totalSalesForSelectedDate;
    final cashSales = controller.cashSalesForSelectedDate;
    final activeUtangTotal = controller.customers.fold(0.0, (sum, c) => sum + c.balance);
    final topDish = controller.topDishForSelectedDate;

    final goal = controller.dailyGoal;
    final goalRatio = (totalSales / goal).clamp(0.0, 1.0);

    // Dine-In vs Takeout
    final dineInCount = activeOrders.where((o) => o.kind == OrderKind.dineIn).length;
    final takeoutCount = activeOrders.where((o) => o.kind == OrderKind.takeout).length;
    final totalOrdersCount = activeOrders.length;
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
            // Live Digital Clock in Main Dashboard Body (no date, no location)
            DashboardLiveClock(isKitchen: isKitchen),
            const SizedBox(height: 12),

            // Reactive Calendar Filter Pill (tapping a calendar day updates immediately)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _openReactiveCalendarSheet(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                          width: isKitchen ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDateLabel(selectedDate),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: AppColors.mutedBrown, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isToday) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onPressed: () => controller.setSalesDate(DateTime.now()),
                    child: Text(
                      'Today',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Interactive Hero Sales Card with Goal Ring
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SalesDetailReportView(controller: controller),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isToday ? "Today's sales" : "Sales • ${_formatDateLabel(selectedDate)}",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warmCream.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ],
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
                                    const Icon(Icons.receipt_long, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$totalOrdersCount orders recorded',
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

                    // Goal Progress Ring (Tappable independently to edit daily goal)
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
            ),
            const SizedBox(height: 16),

            // Interactive Top-Selling Dish KPI Card -> Menu Setup
            InkWell(
              onTap: () => controller.setOwnerTabIndex(1),
              borderRadius: BorderRadius.circular(20),
              child: Container(
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
                              Expanded(
                                child: Text(
                                  'PINAKA-MABENTA (TOP SELLER)',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            topDish?.name ?? 'Wala pang benta',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                            ),
                          ),
                          Text(
                            topDish != null
                                ? '${topDish.count} orders served (₱${topDish.revenue.toStringAsFixed(0)} total)'
                                : 'Walang naitalang order sa petsang ito',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.mutedBrown),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Low Servings / Inventory KPI Card -> Menu Setup
            InkWell(
              onTap: () => controller.setOwnerTabIndex(1),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Imbentaryo / Paubos na:',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.mutedBrown, size: 20),
                      ],
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
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Cash Sales vs Active Utang KPI Cards Row
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SalesDetailReportView(
                            controller: controller,
                            focusMethod: PaymentMethod.cash,
                            title: 'Cash Sales Report',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Cash Sales',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 16, color: AppColors.mutedBrown),
                            ],
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => controller.setOwnerTabIndex(3),
                    borderRadius: BorderRadius.circular(18),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Active Utang',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 16, color: AppColors.mutedBrown),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${activeUtangTotal.toStringAsFixed(0)}',
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
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 12, height: 12, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Dine-In ($dineInPercent%) - $dineInCount orders',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 12, height: 12, color: AppColors.mustard),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Takeout ($takeoutPercent%) - $takeoutCount orders',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                      Expanded(
                        child: Text(
                          'Cash Count Reconciliation',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
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
