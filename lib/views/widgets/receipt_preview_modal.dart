import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class ReceiptPreviewModal extends StatelessWidget {
  final Order order;
  final KarinderyaController controller;

  const ReceiptPreviewModal({
    super.key,
    required this.order,
    required this.controller,
  });

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    int hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} $hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDateTime(order.createdAt);
    final isKitchen = controller.kitchenMode;
    final staffName = order.staffName ?? controller.currentStaffName;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
        maxWidth: 460,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Sheet Handle & Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.print_outlined, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Preview ng Resibo',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.mutedBrown),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.line),

          // Scrollable Thermal Slip
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Store Branding
                    Text(
                      'KARINDERYA NI ALING NENA',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.courierPrime(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Brgy. San Antonio, Pasig City\nTIN: 421-889-102-000\nPOS Terminal #01',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.courierPrime(fontSize: 11, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    _buildDottedLine(),
                    const SizedBox(height: 10),

                    // Meta Info
                    _buildReceiptRow('Date/Time:', formattedDate),
                    _buildReceiptRow('Order #:', '#${order.id}'),
                    _buildReceiptRow('Cashier:', staffName),
                    _buildReceiptRow(
                      'Order Type:',
                      order.kind == OrderKind.takeout ? 'TAKEOUT' : 'DINE-IN (T-${order.tableNum})',
                    ),
                    if (order.customerName != null && order.customerName!.isNotEmpty)
                      _buildReceiptRow('Customer:', order.customerName!),

                    const SizedBox(height: 10),
                    _buildDottedLine(),
                    const SizedBox(height: 10),

                    // Items Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QTY  ITEM',
                          style: GoogleFonts.courierPrime(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'AMOUNT',
                          style: GoogleFonts.courierPrime(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Items List
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.dish.name}',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                            Text(
                              '₱${item.lineTotal.toStringAsFixed(2)}',
                              style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),
                    _buildDottedLine(),
                    const SizedBox(height: 10),

                    // Total Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'KABUUANG HALAGA:',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.courierPrime(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₱${order.total.toStringAsFixed(2)}',
                          style: GoogleFonts.courierPrime(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Payment Breakdown
                    _buildReceiptRow('Payment Method:', _getPaymentMethodLabel(order.paymentMethod)),
                    if (order.referenceNumber != null && order.referenceNumber!.isNotEmpty)
                      _buildReceiptRow('Ref Number:', order.referenceNumber!),
                    if (order.isVoided) ...[
                      const SizedBox(height: 4),
                      Text(
                        '*** ORDER NA-VOID ***\nReason: ${order.voidReason ?? "N/A"}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.courierPrime(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.chiliRed,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),
                    _buildDottedLine(),
                    const SizedBox(height: 12),

                    // Taglish Footer
                    Text(
                      'Maraming salamat po sa pagtangkilik!\nBalik po kayo muli.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.courierPrime(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Print Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Resibo para sa Order #${order.id} naiprint na!',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.leafGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.print, size: 20),
                label: Text(
                  'I-print sa Thermal Printer',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.courierPrime(fontSize: 11, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.courierPrime(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedLine() {
    return Text(
      '--------------------------------',
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: GoogleFonts.courierPrime(color: Colors.grey.shade400, fontWeight: FontWeight.bold),
    );
  }

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.gcash:
        return 'GCASH (E-Wallet)';
      case PaymentMethod.maya:
        return 'MAYA (E-Wallet)';
      case PaymentMethod.utang:
        return 'LISTA SA UTANG';
    }
  }
}
