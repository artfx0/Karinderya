import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import 'customer_picker_sheet.dart';

class CheckoutSheet extends StatelessWidget {
  final KarinderyaController controller;

  const CheckoutSheet({super.key, required this.controller});

  void _onPayCash(BuildContext context) {
    Navigator.pop(context);
    controller.prepareCashPayment();
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
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
              Text(
                'Order Summary',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
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
                    Text(
                      'Order #${controller.activeOrderNumber} ($tableTag)',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
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
                        Text('${item.quantity}x ${item.dish.name}'),
                        Text('₱${item.lineTotal.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppColors.line, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kabuuang Babayaran:',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₱${controller.cartTotal.toStringAsFixed(0)}',
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

          // Payment Options: Cash & Record Utang
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.leafGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              icon: const Icon(Icons.payments_outlined),
              label: Text(
                'Pay Cash — ₱${controller.cartTotal.toStringAsFixed(0)}',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _onPayCash(context),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.chiliRed,
                side: const BorderSide(color: AppColors.chiliRed, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              icon: const Icon(Icons.book_outlined),
              label: Text(
                'Record Utang',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _onRecordUtang(context),
            ),
          ),
        ],
      ),
    );
  }
}
