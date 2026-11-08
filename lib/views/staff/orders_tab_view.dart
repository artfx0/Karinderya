import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class OrdersTabView extends StatelessWidget {
  final KarinderyaController controller;

  const OrdersTabView({super.key, required this.controller});

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return AppColors.mustard;
      case OrderStatus.ready:
        return AppColors.leafGreen;
      case OrderStatus.served:
        return AppColors.mutedBrown;
    }
  }

  Color _getPaymentBadgeColor(PaymentStatus payStatus) {
    switch (payStatus) {
      case PaymentStatus.paid:
        return AppColors.leafGreen;
      case PaymentStatus.unpaid:
        return AppColors.mustard;
      case PaymentStatus.onDebt:
        return AppColors.chiliRed;
    }
  }

  String _getPaymentBadgeText(PaymentStatus payStatus) {
    switch (payStatus) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.onDebt:
        return 'On debt';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final currentStatus = controller.selectedOrderTab;
    final orders = controller.ordersBySelectedStatus;

    return Column(
      children: [
        // Segmented Status Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isKitchen ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                width: isKitchen ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                _buildSegmentTab(
                  status: OrderStatus.preparing,
                  title: 'Preparing',
                  count: controller.getOrderCountByStatus(OrderStatus.preparing),
                  isSelected: currentStatus == OrderStatus.preparing,
                  isKitchen: isKitchen,
                ),
                _buildSegmentTab(
                  status: OrderStatus.ready,
                  title: 'Ready',
                  count: controller.getOrderCountByStatus(OrderStatus.ready),
                  isSelected: currentStatus == OrderStatus.ready,
                  isKitchen: isKitchen,
                ),
                _buildSegmentTab(
                  status: OrderStatus.served,
                  title: 'Served',
                  count: controller.getOrderCountByStatus(OrderStatus.served),
                  isSelected: currentStatus == OrderStatus.served,
                  isKitchen: isKitchen,
                ),
              ],
            ),
          ),
        ),

        // Orders List or Empty State
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: SvgPicture.asset('assets/empty-pot.svg'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Walang order pa. Magluto na!',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Walang order sa kategoryang ito sa ngayon.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.mutedBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: orders.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final stripeColor = _getStatusColor(order.status);
                    final payColor = _getPaymentBadgeColor(order.payStatus);

                    return Container(
                      decoration: BoxDecoration(
                        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                          width: isKitchen ? 2.5 : 1.0,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Status Stripe Color
                            Container(
                              width: 8,
                              color: stripeColor,
                            ),

                            // Order Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Order Header: Number, Tag, and Payment Badge
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Order #${order.id}',
                                              style: GoogleFonts.fredoka(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
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
                                                order.kind == OrderKind.takeout
                                                    ? 'Takeout'
                                                    : 'Table ${order.tableNum}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Payment Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: payColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: payColor.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            _getPaymentBadgeText(order.payStatus),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: payColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Items Breakdown
                                    ...order.items.map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          '${item.quantity}x ${item.dish.name}',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Divider(color: AppColors.line, height: 16),

                                    // Footer: Total & Status Action Button
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total (${order.totalItemCount} piraso):',
                                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedBrown),
                                            ),
                                            Text(
                                              '₱${order.total.toStringAsFixed(0)}',
                                              style: GoogleFonts.fredoka(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isKitchen ? AppColors.kitchenText : AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // 48px Action Button to Advance Status
                                        if (order.status == OrderStatus.preparing)
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.leafGreen,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(120, 48),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                            icon: const Icon(Icons.check, size: 18),
                                            label: const Text('Mark Ready'),
                                            onPressed: () {
                                              controller.advanceOrderStatus(order.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Order #${order.id} is now Ready!'),
                                                  backgroundColor: AppColors.leafGreen,
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                          )
                                        else if (order.status == OrderStatus.ready)
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(120, 48),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                            icon: const Icon(Icons.done_all, size: 18),
                                            label: const Text('Mark Served'),
                                            onPressed: () {
                                              controller.advanceOrderStatus(order.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Order #${order.id} is now Served!'),
                                                  backgroundColor: AppColors.leafGreen,
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSegmentTab({
    required OrderStatus status,
    required String title,
    required int count,
    required bool isSelected,
    required bool isKitchen,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setSelectedOrderTab(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : (isKitchen ? AppColors.kitchenText : AppColors.darkBrown),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.3) : AppColors.line,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.fredoka(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.darkBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
