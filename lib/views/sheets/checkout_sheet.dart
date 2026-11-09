import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/digital_payment_modal.dart';
import 'customer_picker_sheet.dart';

class CheckoutSheet extends StatelessWidget {
  final KarinderyaController controller;

  const CheckoutSheet({super.key, required this.controller});

  void _onPayCash(BuildContext context) {
    Navigator.pop(context);
    controller.prepareCashPayment();
  }

  void _onPayDigital(BuildContext context, PaymentMethod method) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => DigitalPaymentModal(
        controller: controller,
        method: method,
      ),
    );
  }

  void _onRecordUtang(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => CustomerPickerSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final tableTag = controller.activeOrderKind == OrderKind.takeout
        ? 'Takeout'
        : 'Table ${controller.activeTableNum}';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: 640,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
          width: isKitchen ? 2.5 : 1.0,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order Summary',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${controller.activeOrderNumber} ($tableTag)',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.cartItemCount} piraso',
                        style: GoogleFonts.inter(color: AppColors.mutedBrown),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.line, height: 20),
                  ...controller.cart.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.dish.name}',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₱${item.lineTotal.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.line, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Kabuuang Babayaran:',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₱${controller.cartTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Methods Section
            Text(
              'PARAAN NG PAGBABAYAD',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.mutedBrown,
              ),
            ),
            const SizedBox(height: 10),

            // Payment Methods 2x2 Grid
            Row(
              children: [
                // 1. Cash Payment
                Expanded(
                  child: _buildPaymentTile(
                    title: 'Cash',
                    subtitle: 'Barya / Papel',
                    icon: Icons.payments_outlined,
                    color: AppColors.leafGreen,
                    onTap: () => _onPayCash(context),
                    isKitchen: isKitchen,
                  ),
                ),
                const SizedBox(width: 10),

                // 2. GCash Payment
                Expanded(
                  child: _buildPaymentTile(
                    title: 'GCash',
                    subtitle: 'E-Wallet QR',
                    icon: Icons.account_balance_wallet_outlined,
                    color: const Color(0xFF007DFE),
                    onTap: () => _onPayDigital(context, PaymentMethod.gcash),
                    isKitchen: isKitchen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                // 3. Maya Payment
                Expanded(
                  child: _buildPaymentTile(
                    title: 'Maya',
                    subtitle: 'E-Wallet QR',
                    icon: Icons.qr_code_scanner,
                    color: const Color(0xFF00B14F),
                    onTap: () => _onPayDigital(context, PaymentMethod.maya),
                    isKitchen: isKitchen,
                  ),
                ),
                const SizedBox(width: 10),

                // 4. Utang / Debt Book
                Expanded(
                  child: _buildPaymentTile(
                    title: 'Utang',
                    subtitle: 'Lista sa Suki',
                    icon: Icons.menu_book_outlined,
                    color: AppColors.mustard,
                    textColor: AppColors.darkBrown,
                    onTap: () => _onRecordUtang(context),
                    isKitchen: isKitchen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    Color? textColor,
    required VoidCallback onTap,
    required bool isKitchen,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: isKitchen ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? color,
                    ),
                  ),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.mutedBrown,
                      fontWeight: FontWeight.w500,
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
}
