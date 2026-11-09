import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../widgets/receipt_preview_modal.dart';
import '../widgets/owner_pin_modal.dart';

class OrderHistoryView extends StatefulWidget {
  final KarinderyaController controller;

  const OrderHistoryView({super.key, required this.controller});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  String _searchFilter = '';
  String _selectedPaymentFilter = 'ALL'; // ALL, CASH, GCASH, MAYA, UTANG, VOIDED

  String _formatTime(DateTime dt) {
    int hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  void _showReceiptModal(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptPreviewModal(
        order: order,
        controller: widget.controller,
      ),
    );
  }

  void _showVoidModal(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OwnerPinModal(
        controller: widget.controller,
        order: order,
      ),
    );
  }

  List<Order> _getFilteredOrders() {
    final allOrders = widget.controller.orders;
    return allOrders.where((order) {
      // Payment Filter
      if (_selectedPaymentFilter == 'CASH' && (order.isVoided || order.paymentMethod != PaymentMethod.cash)) {
        return false;
      }
      if (_selectedPaymentFilter == 'GCASH' && (order.isVoided || order.paymentMethod != PaymentMethod.gcash)) {
        return false;
      }
      if (_selectedPaymentFilter == 'MAYA' && (order.isVoided || order.paymentMethod != PaymentMethod.maya)) {
        return false;
      }
      if (_selectedPaymentFilter == 'UTANG' && (order.isVoided || order.paymentMethod != PaymentMethod.utang)) {
        return false;
      }
      if (_selectedPaymentFilter == 'VOIDED' && !order.isVoided) {
        return false;
      }

      // Search Query
      if (_searchFilter.isNotEmpty) {
        final q = _searchFilter.toLowerCase();
        final matchesId = order.id.toLowerCase().contains(q);
        final matchesCustomer = (order.customerName ?? '').toLowerCase().contains(q);
        final matchesRef = (order.referenceNumber ?? '').toLowerCase().contains(q);
        final matchesItems = order.items.any((i) => i.dish.name.toLowerCase().contains(q));
        if (!matchesId && !matchesCustomer && !matchesRef && !matchesItems) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildPaymentBadge(Order order, bool isKitchen) {
    if (order.isVoided) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.chiliRed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.chiliRed.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined, size: 14, color: AppColors.chiliRed),
            const SizedBox(width: 4),
            Text(
              'VOIDED',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.chiliRed,
              ),
            ),
          ],
        ),
      );
    }

    Color badgeColor;
    String label;
    IconData icon;

    switch (order.paymentMethod) {
      case PaymentMethod.cash:
        badgeColor = AppColors.leafGreen;
        label = 'Cash';
        icon = Icons.payments_outlined;
        break;
      case PaymentMethod.gcash:
        badgeColor = const Color(0xFF007DFE);
        label = 'GCash';
        icon = Icons.account_balance_wallet_outlined;
        break;
      case PaymentMethod.maya:
        badgeColor = const Color(0xFF00B14F);
        label = 'Maya';
        icon = Icons.qr_code_scanner;
        break;
      case PaymentMethod.utang:
        badgeColor = AppColors.mustard;
        label = 'Utang';
        icon = Icons.menu_book_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final filtered = _getFilteredOrders();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Kasaysayan ng Order',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${filtered.length} Orders',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  onChanged: (val) => setState(() => _searchFilter = val),
                  decoration: InputDecoration(
                    hintText: 'Maghanap ng Order #, Customer, o Ulam...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.mutedBrown),
                    isDense: true,
                    filled: true,
                    fillColor: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Lahat', 'ALL', isKitchen),
                      const SizedBox(width: 6),
                      _buildFilterChip('Cash', 'CASH', isKitchen),
                      const SizedBox(width: 6),
                      _buildFilterChip('GCash', 'GCASH', isKitchen),
                      const SizedBox(width: 6),
                      _buildFilterChip('Maya', 'MAYA', isKitchen),
                      const SizedBox(width: 6),
                      _buildFilterChip('Utang', 'UTANG', isKitchen),
                      const SizedBox(width: 6),
                      _buildFilterChip('Voided', 'VOIDED', isKitchen),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 56,
                            color: AppColors.mutedBrown.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Walang natagpuang order',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Subukang palitan ang filter o maghanap ng ibang order number.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      final orderTime = '${_formatDate(order.createdAt)} • ${_formatTime(order.createdAt)}';
                      final customerInfo = order.customerName != null && order.customerName!.isNotEmpty
                          ? order.customerName!
                          : (order.kind == OrderKind.takeout ? 'Takeout' : 'Table ${order.tableNum}');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: order.isVoided
                                ? AppColors.chiliRed.withValues(alpha: 0.4)
                                : (isKitchen ? AppColors.kitchenBorder : AppColors.line),
                            width: order.isVoided ? 1.5 : (isKitchen ? 2 : 1),
                          ),
                          boxShadow: isKitchen
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: order.isVoided
                                ? AppColors.chiliRed.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.12),
                            child: Icon(
                              order.isVoided ? Icons.block : Icons.receipt,
                              color: order.isVoided ? AppColors.chiliRed : AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Order #${order.id}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                    decoration: order.isVoided ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₱${order.total.toStringAsFixed(2)}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: order.isVoided ? AppColors.chiliRed : AppColors.primary,
                                  decoration: order.isVoided ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      customerInfo,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '• $orderTime',
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedBrown),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildPaymentBadge(order, isKitchen),
                                  if (order.referenceNumber != null && order.referenceNumber!.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Ref: ${order.referenceNumber}',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.courierPrime(
                                          fontSize: 11,
                                          color: AppColors.mutedBrown,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (order.isVoided && order.voidReason != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.chiliRed.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Dahilan ng void: ${order.voidReason}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.chiliRed,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(color: AppColors.line),
                                  Text(
                                    'MGA IN-ORDER:',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.6,
                                      color: AppColors.mutedBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...order.items.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${item.quantity}x ${item.dish.name}',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                            ),
                                          ),
                                          Text(
                                            '₱${item.lineTotal.toStringAsFixed(2)}',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.darkBrown,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      // Print Receipt Button
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.darkBrown,
                                            side: const BorderSide(color: AppColors.line),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
                                          onPressed: () => _showReceiptModal(order),
                                          icon: const Icon(Icons.print_outlined, size: 18),
                                          label: Text(
                                            'I-print ang Resibo',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!order.isVoided) ...[
                                        const SizedBox(width: 8),
                                        // Request Void Button
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppColors.chiliRed,
                                              side: const BorderSide(color: AppColors.chiliRed),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                            ),
                                            onPressed: () => _showVoidModal(order),
                                            icon: const Icon(Icons.block, size: 18),
                                            label: Text(
                                              'I-void (Owner PIN)',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isKitchen) {
    final isSelected = _selectedPaymentFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : (isKitchen ? AppColors.kitchenText : AppColors.darkBrown),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isKitchen ? AppColors.kitchenBorder : AppColors.line),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (_) => setState(() => _selectedPaymentFilter = value),
    );
  }
}
