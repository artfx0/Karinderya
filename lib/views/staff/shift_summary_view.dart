import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../theme/app_theme.dart';

class ShiftSummaryView extends StatefulWidget {
  final KarinderyaController controller;

  const ShiftSummaryView({super.key, required this.controller});

  @override
  State<ShiftSummaryView> createState() => _ShiftSummaryViewState();
}

class _ShiftSummaryViewState extends State<ShiftSummaryView> {
  final TextEditingController _countedCashController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final shift = widget.controller.currentShift;
    if (shift?.actualCountedCash != null) {
      _countedCashController.text = shift!.actualCountedCash!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _countedCashController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    int hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  void _onCountedCashChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', ''));
    if (parsed != null) {
      widget.controller.updateCountedCash(parsed);
    }
  }

  void _showEndShiftDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: widget.controller.kitchenMode ? Colors.white : AppColors.paperCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'I-end ang kasalukuyang shift?',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        content: Text(
          'Mase-save ang reconciliation ng iyong cash drawer para sa araw na ito at mai-print ang Z-read report.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Kanselahin',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.darkBrown),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              widget.controller.endCurrentShift();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Matagumpay na natapos ang shift ni ${widget.controller.currentStaffName}!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: AppColors.leafGreen,
                ),
              );
            },
            child: Text(
              'Oo, I-end ang Shift',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _printShiftSummary() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.print, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Nagpi-print ng Shift Summary slip...',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.darkBrown,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final shift = controller.currentShift;

    if (shift == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Walang aktibong shift sa kasalukuyan.',
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.mutedBrown),
          ),
        ),
      );
    }

    final startTimeStr = _formatTime(shift.startedAt);
    final variance = shift.cashVariance;
    final hasCounted = shift.actualCountedCash != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cashier Shift Profile Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 2 : 1,
                ),
                boxShadow: isKitchen
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      shift.cashierName.isNotEmpty ? shift.cashierName[0] : 'S',
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shift.cashierName,
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: shift.isActive ? AppColors.leafGreen : AppColors.mutedBrown,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                shift.isActive ? 'Aktibo • Mula $startTimeStr' : 'Tapos na ang shift',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.mutedBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.leafGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Staff Drawer',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.leafGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mandatory Shift Metrics Grid
            Text(
              'BUOD NG AKING SHIFT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.mutedBrown,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                // Metric 1: Total Orders Taken
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.receipt_long,
                    iconBg: AppColors.primary.withValues(alpha: 0.12),
                    iconColor: AppColors.primary,
                    label: 'Nai-punch na Order',
                    value: '${shift.ordersCount}',
                    isKitchen: isKitchen,
                  ),
                ),
                const SizedBox(width: 10),

                // Metric 2: Total Cash Received
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.payments,
                    iconBg: AppColors.leafGreen.withValues(alpha: 0.12),
                    iconColor: AppColors.leafGreen,
                    label: 'Natanggap na Cash',
                    value: '₱${shift.cashSales.toStringAsFixed(2)}',
                    isKitchen: isKitchen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                // Metric 3: Debt Payments Collected
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.price_check,
                    iconBg: AppColors.mustard.withValues(alpha: 0.2),
                    iconColor: AppColors.darkBrown,
                    label: 'Bayad sa Utang',
                    value: '₱${shift.utangCollected.toStringAsFixed(2)}',
                    isKitchen: isKitchen,
                  ),
                ),
                const SizedBox(width: 10),

                // Digital Payments (GCash + Maya)
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.qr_code_2,
                    iconBg: const Color(0xFF007DFE).withValues(alpha: 0.12),
                    iconColor: const Color(0xFF007DFE),
                    label: 'Digital (GCash/Maya)',
                    value: '₱${shift.totalDigitalSales.toStringAsFixed(2)}',
                    isKitchen: isKitchen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Cash Drawer Reconciliation Card
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
                          'Reconciliation ng Cash Drawer',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.point_of_sale, color: AppColors.primary, size: 22),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildDrawerRow('Panimulang Float (Sinsilyo):', '₱${shift.startingFloat.toStringAsFixed(2)}'),
                  _buildDrawerRow('+ Benta sa Cash:', '₱${shift.cashSales.toStringAsFixed(2)}'),
                  _buildDrawerRow('+ Nakolektang Bayad sa Utang:', '₱${shift.utangCollected.toStringAsFixed(2)}'),
                  const Divider(color: AppColors.line, height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Inaasahang Pera sa Drawer:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₱${shift.expectedCashInDrawer.toStringAsFixed(2)}',
                        style: GoogleFonts.fredoka(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Actual Counted Cash Input
                  Text(
                    'Aktwal na Binilang sa Drawer:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _countedCashController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: _onCountedCashChanged,
                    decoration: InputDecoration(
                      prefixText: '₱ ',
                      prefixStyle: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                      hintText: '0.00',
                      isDense: true,
                      filled: true,
                      fillColor: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Variance Indicator
                  if (hasCounted) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: variance == 0
                            ? AppColors.leafGreen.withValues(alpha: 0.12)
                            : (variance > 0
                                ? AppColors.mustard.withValues(alpha: 0.2)
                                : AppColors.chiliRed.withValues(alpha: 0.12)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: variance == 0
                              ? AppColors.leafGreen
                              : (variance > 0 ? AppColors.mustard : AppColors.chiliRed),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            variance == 0
                                ? Icons.check_circle_outline
                                : (variance > 0 ? Icons.arrow_upward : Icons.warning_amber_rounded),
                            color: variance == 0
                                ? AppColors.leafGreen
                                : (variance > 0 ? AppColors.darkBrown : AppColors.chiliRed),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              variance == 0
                                  ? 'Tugma ang drawer! (Balanced)'
                                  : (variance > 0
                                      ? '+₱${variance.toStringAsFixed(2)} Sobra sa Drawer (Over)'
                                      : '-₱${variance.abs().toStringAsFixed(2)} Kulang ang Drawer (Short)'),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: variance == 0
                                    ? AppColors.leafGreen
                                    : (variance > 0 ? AppColors.darkBrown : AppColors.chiliRed),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Shift Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBrown,
                      side: const BorderSide(color: AppColors.line, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _printShiftSummary,
                    icon: const Icon(Icons.print_outlined, size: 20),
                    label: Text(
                      'I-print ang Buod',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                    ),
                    onPressed: () => _showEndShiftDialog(context),
                    icon: const Icon(Icons.done_all, size: 20),
                    label: Text(
                      'I-end ang Shift',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required bool isKitchen,
  }) {
    return Container(
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
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkBrown),
          ),
        ],
      ),
    );
  }
}
