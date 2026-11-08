import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../theme/app_theme.dart';

class StaffUtangTabView extends StatelessWidget {
  final KarinderyaController controller;

  const StaffUtangTabView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final customers = controller.customers;
    final totalOutstanding = customers.fold(0.0, (sum, c) => sum + c.balance);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Total Outstanding Card (Read Only for Staff)
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
                        'KABUUANG UTANG (LEDGER)',
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
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Staff Read-Only',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${totalOutstanding.toStringAsFixed(0)}',
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmCream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Paalala: Ang May-ari (Owner) lamang ang maaaring magbawas o mag-record ng bayad sa utang.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.warmCream.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Customer Ledger Rows
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: customers.length,
              separatorBuilder: (context, _) => const Divider(color: AppColors.line, height: 16),
              itemBuilder: (context, index) {
                final customer = customers[index];
                final isPaid = customer.isPaidInFull;

                return Container(
                  padding: const EdgeInsets.all(16),
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
                        children: [
                          CircleAvatar(
                            backgroundColor: isPaid
                                ? AppColors.leafGreen.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              customer.avatarInitials,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: isPaid ? AppColors.leafGreen : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                              Text(
                                isPaid ? 'Bayad na' : '₱${customer.balance.toStringAsFixed(0)}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isPaid ? AppColors.leafGreen : AppColors.chiliRed,
                                ),
                              ),
                              if (isPaid)
                                const Icon(Icons.check_circle, color: AppColors.leafGreen, size: 16),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
