import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class SalesDetailReportView extends StatelessWidget {
  final KarinderyaController controller;
  final PaymentMethod? focusMethod;
  final String title;

  const SalesDetailReportView({
    super.key,
    required this.controller,
    this.focusMethod,
    this.title = 'Detalye ng Benta (Sales Report)',
  });

  String _formatOrderTime(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  String _methodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.gcash:
        return 'GCash';
      case PaymentMethod.maya:
        return 'Maya';
      case PaymentMethod.utang:
        return 'Utang';
    }
  }

  Color _methodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return AppColors.leafGreen;
      case PaymentMethod.gcash:
        return Colors.blue.shade700;
      case PaymentMethod.maya:
        return Colors.teal.shade700;
      case PaymentMethod.utang:
        return AppColors.chiliRed;
    }
  }

  String _formatDateBadge(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final activeOrders = controller.ordersForSelectedDate;
    final filteredOrders = focusMethod == null
        ? activeOrders
        : activeOrders.where((o) => o.paymentMethod == focusMethod).toList();

    final totalRevenue = filteredOrders.fold(0.0, (sum, o) => sum + o.total);
    final avgTicket = filteredOrders.isNotEmpty ? totalRevenue / filteredOrders.length : 0.0;

    final cashTotal = activeOrders
        .where((o) => o.paymentMethod == PaymentMethod.cash)
        .fold(0.0, (sum, o) => sum + o.total);
    final gcashTotal = activeOrders
        .where((o) => o.paymentMethod == PaymentMethod.gcash)
        .fold(0.0, (sum, o) => sum + o.total);
    final mayaTotal = activeOrders
        .where((o) => o.paymentMethod == PaymentMethod.maya)
        .fold(0.0, (sum, o) => sum + o.total);
    final utangTotal = activeOrders
        .where((o) => o.paymentMethod == PaymentMethod.utang)
        .fold(0.0, (sum, o) => sum + o.total);

    return Scaffold(
      backgroundColor: isKitchen ? AppColors.kitchenBg : AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        foregroundColor: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.fredoka(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: isKitchen ? 2 : 1,
            color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Top Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isKitchen ? AppColors.kitchenBorder : AppColors.darkBrown,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  focusMethod == null ? 'KABUUANG BENTA' : 'KABUUANG ${_methodLabel(focusMethod!).toUpperCase()}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.warmCream.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₱${totalRevenue.toStringAsFixed(2)}',
                  style: GoogleFonts.fredoka(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _summaryChip(_formatDateBadge(controller.selectedSalesDate)),
                    _summaryChip('${filteredOrders.length} Orders'),
                    _summaryChip('Avg: ₱${avgTicket.toStringAsFixed(0)} / order'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Channels Breakdown
          Container(
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
                  'Breakdown ayon sa Paraan ng Bayad',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _breakdownRow('Cash Payments', cashTotal, AppColors.leafGreen),
                const SizedBox(height: 8),
                _breakdownRow('GCash Collections', gcashTotal, Colors.blue.shade700),
                const SizedBox(height: 8),
                _breakdownRow('Maya Collections', mayaTotal, Colors.teal.shade700),
                const SizedBox(height: 8),
                _breakdownRow('Utang / Credit Recorded', utangTotal, AppColors.chiliRed),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Mga Transaksyon (${filteredOrders.length})',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 10),

          if (filteredOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isKitchen ? AppColors.kitchenBorder : AppColors.line),
              ),
              child: Center(
                child: Text(
                  'Walang naitalang transaksyon para sa filter na ito.',
                  style: GoogleFonts.inter(color: AppColors.mutedBrown),
                ),
              ),
            )
          else
            ...filteredOrders.map((order) => _buildOrderRowCard(order, isKitchen)),
        ],
      ),
    );
  }

  Widget _summaryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, double amount, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.darkBrown),
                ),
              ),
            ],
          ),
        ),
        Text(
          '₱${amount.toStringAsFixed(0)}',
          style: GoogleFonts.fredoka(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderRowCard(Order order, bool isKitchen) {
    final badgeColor = _methodColor(order.paymentMethod);
    final itemsSummary = order.items.map((i) => '${i.quantity}x ${i.dish.name}').join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        borderRadius: BorderRadius.circular(16),
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
                child: Row(
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _methodLabel(order.paymentMethod),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₱${order.total.toStringAsFixed(0)}',
                style: GoogleFonts.fredoka(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            itemsSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.darkBrown),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${order.kind == OrderKind.dineIn ? "Table ${order.tableNum}" : "Takeout"} • ${order.staffName ?? "Staff"}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedBrown),
                ),
              ),
              Text(
                _formatOrderTime(order.createdAt),
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedBrown),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
