import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class CashPaymentView extends StatefulWidget {
  final KarinderyaController controller;

  const CashPaymentView({super.key, required this.controller});

  @override
  State<CashPaymentView> createState() => _CashPaymentViewState();
}

class _CashPaymentViewState extends State<CashPaymentView> {
  String _cashInput = '';
  String? _errorMessage;

  double get _parsedCash => double.tryParse(_cashInput) ?? 0.0;
  double get _totalToPay => widget.controller.cartTotal;
  double get _change => _parsedCash - _totalToPay;
  bool get _isEnough => _parsedCash >= _totalToPay;

  void _onKeyPress(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      _errorMessage = null;
      if (key == '⌫') {
        if (_cashInput.isNotEmpty) {
          _cashInput = _cashInput.substring(0, _cashInput.length - 1);
        }
      } else if (key == '.') {
        if (!_cashInput.contains('.') && _cashInput.length < 8) {
          _cashInput = _cashInput.isEmpty ? '0.' : '$_cashInput.';
        }
      } else {
        // Digits
        if (_cashInput.length < 8) {
          if (_cashInput == '0') {
            _cashInput = key;
          } else {
            _cashInput += key;
          }
        }
      }
    });
  }

  void _onChipSelected(double amount) {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      _cashInput = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
    });
  }

  void _onExactSelected() {
    _onChipSelected(_totalToPay);
  }

  void _handleConfirmPayment() {
    if (!_isEnough) {
      HapticFeedback.heavyImpact();
      setState(() {
        final shortAmount = (_totalToPay - _parsedCash).toStringAsFixed(0);
        _errorMessage = 'Kulang pa po ang bayad ng ₱$shortAmount.';
      });
      return;
    }

    HapticFeedback.mediumImpact();
    widget.controller.completeCashPayment(_parsedCash);
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = widget.controller.kitchenMode;
    final tableTag = widget.controller.activeOrderKind == OrderKind.takeout
        ? 'Takeout'
        : 'Table ${widget.controller.activeTableNum}';

    return Scaffold(
      backgroundColor: isKitchen ? AppColors.kitchenBg : AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
          ),
          onPressed: () => widget.controller.setScreen(ScreenState.staff),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Payment',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
              ),
            ),
            Text(
              'Order #${widget.controller.activeOrderNumber} - $tableTag',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
            height: isKitchen ? 2.5 : 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Upper Section: Total & Cash Received Display
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                              width: isKitchen ? 2.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kabuuang Babayaran',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
                                    ),
                                  ),
                                  Text(
                                    '${widget.controller.cartItemCount} piraso sa order',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                                  ),
                                ],
                              ),
                              Text(
                                '₱${_totalToPay.toStringAsFixed(0)}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Cash Received Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isKitchen ? Colors.white : AppColors.paperCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isKitchen ? AppColors.kitchenBorder : AppColors.primary,
                              width: 2.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bayad na Natanggap (Cash Received):',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₱',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    _cashInput.isEmpty ? '0' : _cashInput,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Quick Cash Tender Chips Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickChip(
                                label: 'Exact (₱${_totalToPay.toStringAsFixed(0)})',
                                isSelected: _parsedCash == _totalToPay && _cashInput.isNotEmpty,
                                onTap: _onExactSelected,
                                isKitchen: isKitchen,
                              ),
                              const SizedBox(width: 8),
                              _buildQuickChip(
                                label: '₱20',
                                isSelected: _parsedCash == 20,
                                onTap: () => _onChipSelected(20),
                                isKitchen: isKitchen,
                              ),
                              const SizedBox(width: 8),
                              _buildQuickChip(
                                label: '₱50',
                                isSelected: _parsedCash == 50,
                                onTap: () => _onChipSelected(50),
                                isKitchen: isKitchen,
                              ),
                              const SizedBox(width: 8),
                              _buildQuickChip(
                                label: '₱100',
                                isSelected: _parsedCash == 100,
                                onTap: () => _onChipSelected(100),
                                isKitchen: isKitchen,
                              ),
                              const SizedBox(width: 8),
                              _buildQuickChip(
                                label: '₱200',
                                isSelected: _parsedCash == 200,
                                onTap: () => _onChipSelected(200),
                                isKitchen: isKitchen,
                              ),
                              const SizedBox(width: 8),
                              _buildQuickChip(
                                label: '₱500',
                                isSelected: _parsedCash == 500,
                                onTap: () => _onChipSelected(500),
                                isKitchen: isKitchen,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Change or Short Area
                        if (_cashInput.isNotEmpty)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _isEnough
                                  ? AppColors.leafGreen.withValues(alpha: 0.12)
                                  : AppColors.mustard.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isEnough ? AppColors.leafGreen : AppColors.mustard,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _isEnough ? Icons.check_circle : Icons.warning_amber_rounded,
                                      color: _isEnough ? AppColors.leafGreen : AppColors.darkBrown,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isEnough ? 'Sukli (Change):' : 'Kulang pa ng:',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _isEnough ? AppColors.leafGreen : AppColors.darkBrown,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₱${(_isEnough ? _change : -_change).toStringAsFixed(0)}',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _isEnough ? AppColors.leafGreen : AppColors.darkBrown,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Inline Error
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.chiliRed, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.inter(
                                    color: AppColors.chiliRed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Lower Section: 60px Tactile Numeric Keypad & Confirm Button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      top: BorderSide(
                        color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                        width: isKitchen ? 2.5 : 1.0,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 4x3 Keypad Grid
                      _buildKeypadRow(['1', '2', '3'], isKitchen),
                      const SizedBox(height: 8),
                      _buildKeypadRow(['4', '5', '6'], isKitchen),
                      const SizedBox(height: 8),
                      _buildKeypadRow(['7', '8', '9'], isKitchen),
                      const SizedBox(height: 8),
                      _buildKeypadRow(['.', '0', '⌫'], isKitchen),
                      const SizedBox(height: 12),

                      // Confirm Payment Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isEnough ? AppColors.leafGreen : AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: isKitchen ? 0 : 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          onPressed: _handleConfirmPayment,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Kumpirmahin ang Bayad',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isKitchen,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isKitchen ? Colors.white : AppColors.paperCard),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isKitchen ? AppColors.kitchenBorder : AppColors.line),
            width: isKitchen ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isKitchen ? AppColors.kitchenText : AppColors.darkBrown),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys, bool isKitchen) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              height: 54, // 54-60px height
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: key == '⌫'
                      ? (isKitchen ? Colors.grey.shade200 : AppColors.warmCream)
                      : (isKitchen ? Colors.white : AppColors.paperCard),
                  foregroundColor: key == '⌫' ? AppColors.chiliRed : AppColors.darkBrown,
                  elevation: 0,
                  side: BorderSide(
                    color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                    width: isKitchen ? 2 : 1,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => _onKeyPress(key),
                child: Text(
                  key,
                  style: GoogleFonts.fredoka(
                    fontSize: key == '⌫' ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    color: key == '⌫' ? AppColors.chiliRed : AppColors.darkBrown,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
