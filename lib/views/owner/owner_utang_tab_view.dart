import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/customer.dart';
import '../../theme/app_theme.dart';

class OwnerUtangTabView extends StatelessWidget {
  final KarinderyaController controller;

  const OwnerUtangTabView({super.key, required this.controller});

  void _showSettleDebtModal(BuildContext context, Customer customer) {
    final payController = TextEditingController(text: customer.balance.toStringAsFixed(0));
    String? error;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) {
          return AlertDialog(
            backgroundColor: controller.kitchenMode ? Colors.white : AppColors.paperCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Mag-record ng Bayad',
              style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suki: ${customer.name}',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kasalukuyang Utang: ₱${customer.balance.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.chiliRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Halaga ng ibabayad ngayon:',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: payController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '₱ ',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: GoogleFonts.inter(color: AppColors.chiliRed, fontSize: 12)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Kanselahin'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.leafGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  final amount = double.tryParse(payController.text.trim());
                  if (amount == null || amount <= 0) {
                    setModalState(() => error = 'Paki-lagay po ang wastong halaga.');
                    return;
                  }

                  controller.settleCustomerDebt(customer.id, amount);
                  Navigator.pop(dialogCtx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Payment recorded. Salamat po!',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.leafGreen,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: const Text('I-record ang Bayad'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final customers = controller.customers;
    final totalOutstanding = customers.fold(0.0, (sum, c) => sum + c.balance);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Total Outstanding Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenBorder : AppColors.darkBrown,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL OUTSTANDING (UTANG)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: AppColors.warmCream.withValues(alpha: 0.8),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.leafGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Owner Access',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${totalOutstanding.toStringAsFixed(0)}',
                    style: GoogleFonts.fredoka(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmCream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pindutin ang sinumang suki upang mag-record ng buo o hulugang bayad.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.warmCream.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Customer Debts List
          Expanded(
            child: customers.isEmpty || (totalOutstanding == 0)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.celebration, color: AppColors.leafGreen, size: 64),
                          const SizedBox(height: 12),
                          Text(
                            'Wala nang utang. Salamat po!',
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lahat ng suki ay nakapagbayad na.',
                            style: GoogleFonts.inter(color: AppColors.mutedBrown),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: customers.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final isPaid = customer.isPaidInFull;

                      return InkWell(
                        onTap: isPaid ? null : () => _showSettleDebtModal(context, customer),
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
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isPaid
                                        ? AppColors.leafGreen.withValues(alpha: 0.15)
                                        : AppColors.chiliRed.withValues(alpha: 0.15),
                                    child: Text(
                                      customer.avatarInitials,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: isPaid ? AppColors.leafGreen : AppColors.chiliRed,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                          ),
                                        ),
                                        Text(
                                          '${customer.openOrders} bukas na order • ${customer.date}',
                                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (isPaid) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.leafGreen.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Bayad na',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.leafGreen,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          '₱${customer.balance.toStringAsFixed(0)}',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.chiliRed,
                                          ),
                                        ),
                                        Text(
                                          'Tap to pay',
                                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              if (!isPaid && customer.originalTotal > 0) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: customer.paymentProgress,
                                    minHeight: 6,
                                    backgroundColor: AppColors.line.withValues(alpha: 0.5),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
