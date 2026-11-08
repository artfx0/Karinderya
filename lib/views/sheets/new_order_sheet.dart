import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class NewOrderSheet extends StatefulWidget {
  final KarinderyaController controller;

  const NewOrderSheet({super.key, required this.controller});

  @override
  State<NewOrderSheet> createState() => _NewOrderSheetState();
}

class _NewOrderSheetState extends State<NewOrderSheet> {
  OrderKind _selectedKind = OrderKind.dineIn;
  final TextEditingController _tableController = TextEditingController(text: '04');
  bool _confirmedDiscard = false;

  @override
  void initState() {
    super.initState();
    _tableController.text = widget.controller.activeTableNum;
    _selectedKind = widget.controller.activeOrderKind;
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  void _handleStartOrder() {
    widget.controller.startNewOrder(
      kind: _selectedKind,
      tableNum: _tableController.text.trim().isEmpty ? '04' : _tableController.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = widget.controller.kitchenMode;
    final hasActiveCart = !widget.controller.isCartEmpty;

    // If there is an active cart and user hasn't confirmed discard yet
    if (hasActiveCart && !_confirmedDiscard) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(24),
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
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.warning_amber_rounded, color: AppColors.mustard, size: 48),
            const SizedBox(height: 12),
            Text(
              'Itapon ang kasalukuyang order?',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mayroong ${widget.controller.cartItemCount} piraso sa kasalukuyang order (₱${widget.controller.cartTotal.toStringAsFixed(0)}). Nais mo bang burahin ito at magsimula ng bagong order?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.mutedBrown,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Huwag itapon',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.darkBrown),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.chiliRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmedDiscard = true;
                      });
                    },
                    child: Text(
                      'Oo, itapon',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Normal New Order Dialog
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Magsimula ng Bagong Order',
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
          const SizedBox(height: 16),

          // Order Kind Toggle
          Text(
            'Uri ng Order:',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildKindCard(
                  kind: OrderKind.dineIn,
                  title: 'Dine-In',
                  subtitle: 'Kain sa pwesto',
                  icon: Icons.restaurant,
                  isSelected: _selectedKind == OrderKind.dineIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKindCard(
                  kind: OrderKind.takeout,
                  title: 'Takeout',
                  subtitle: 'Pabalot / Bitbit',
                  icon: Icons.takeout_dining,
                  isSelected: _selectedKind == OrderKind.takeout,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table Number if Dine In
          if (_selectedKind == OrderKind.dineIn) ...[
            Text(
              'Numero ng Lamesa (Table #):',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _tableController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Hal. 04',
                filled: true,
                fillColor: isKitchen ? Colors.white : AppColors.warmCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.line),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Start Order Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              onPressed: _handleStartOrder,
              child: Text(
                'Simulan ang Order',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKindCard({
    required OrderKind kind,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedKind = kind),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.paperCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.mutedBrown, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.darkBrown,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.mutedBrown),
            ),
          ],
        ),
      ),
    );
  }
}
