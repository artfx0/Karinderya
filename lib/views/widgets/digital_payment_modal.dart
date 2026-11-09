import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class DigitalPaymentModal extends StatefulWidget {
  final KarinderyaController controller;
  final PaymentMethod method; // gcash or maya

  const DigitalPaymentModal({
    super.key,
    required this.controller,
    required this.method,
  });

  @override
  State<DigitalPaymentModal> createState() => _DigitalPaymentModalState();
}

class _DigitalPaymentModalState extends State<DigitalPaymentModal> {
  final TextEditingController _refController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  void _confirmPayment() {
    final ref = _refController.text.trim();
    if (ref.isEmpty) {
      setState(() {
        _errorMessage = 'Pakilagay ang Reference Number mula sa resibo ng customer.';
      });
      return;
    }

    Navigator.pop(context); // Close modal
    widget.controller.completeDigitalPayment(
      method: widget.method,
      referenceNumber: ref,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGCash = widget.method == PaymentMethod.gcash;
    final brandColor = isGCash ? const Color(0xFF007DFE) : const Color(0xFF00B14F);
    final brandName = isGCash ? 'GCash' : 'Maya';
    final merchantNum = isGCash ? '0917-555-4321' : '0918-777-6543';
    final total = widget.controller.cartTotal;
    final isKitchen = widget.controller.kitchenMode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: 480,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
          width: isKitchen ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar with Brand
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: brandColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isGCash ? Icons.account_balance_wallet : Icons.qr_code_scanner,
                        color: brandColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$brandName QR Payment',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                        Text(
                          'Aling Nena • $merchantNum',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.mutedBrown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.mutedBrown),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(color: AppColors.line, height: 24),

            // Amount to Pay Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: brandColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'HALAGANG DAPAT MATANGGAP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: brandColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₱${total.toStringAsFixed(2)}',
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual QR Code Card (POS Counter Standee Simulation)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: brandColor, width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Simulated QR Grid Pattern
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 130,
                          color: brandColor.withValues(alpha: 0.85),
                        ),
                        // Center merchant pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: brandColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            brandName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'I-scan ng customer ang QR code sa counter standee',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedBrown),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reference Number Input
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reference / Transaction No. mula sa SMS o App:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _refController,
              keyboardType: TextInputType.text,
              autofocus: true,
              style: GoogleFonts.courierPrime(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
              decoration: InputDecoration(
                hintText: 'Halimbawa: 1024 8829 3910',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                prefixIcon: Icon(Icons.receipt, color: brandColor, size: 20),
                isDense: true,
                filled: true,
                fillColor: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isKitchen ? AppColors.kitchenBorder : AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: isKitchen ? AppColors.kitchenBorder : AppColors.line),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.chiliRed,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: _confirmPayment,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  'Kumpirmahin ang Bayad ($brandName)',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Kanselahin',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedBrown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
