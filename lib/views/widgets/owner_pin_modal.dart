import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class OwnerPinModal extends StatefulWidget {
  final KarinderyaController controller;
  final Order order;

  const OwnerPinModal({
    super.key,
    required this.controller,
    required this.order,
  });

  @override
  State<OwnerPinModal> createState() => _OwnerPinModalState();
}

class _OwnerPinModalState extends State<OwnerPinModal> {
  String _enteredPin = '';
  String? _errorMessage;
  String _selectedReason = 'Nagbago ang isip ng customer';

  final List<String> _voidReasons = [
    'Nagbago ang isip ng customer',
    'Maling ulam ang na-punch',
    'Hindi kinuha ang order (Spilled/Abandoned)',
    'Nasunog o depektibong pagkain',
    'Iba pang dahilan',
  ];

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = null;
      });
      if (_enteredPin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  void _submitPin() {
    final success = widget.controller.voidOrder(
      orderId: widget.order.id,
      pin: _enteredPin,
      reason: _selectedReason,
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Order #${widget.order.id} na-void na. Naibalik na sa imbentaryo ang mga ulam.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.chiliRed,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Maling Owner PIN. Hindi maaring mag-void nang walang pahintulot.';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = widget.controller.kitchenMode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: 440,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Icon & Title
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.chiliRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.admin_panel_settings, color: AppColors.chiliRed, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            'Kailangan ng Owner PIN',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ang pag-void ng Order #${widget.order.id} (₱${widget.order.total.toStringAsFixed(2)}) ay nangangailangan ng pahintulot ng may-ari.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
          ),
          const SizedBox(height: 16),

          // Reason Selector
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dahilan ng Pag-void:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isKitchen ? AppColors.kitchenBorder : AppColors.line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReason,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.darkBrown),
                items: _voidReasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(
                      reason,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.darkBrown),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedReason = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // PIN Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < _enteredPin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled
                      ? AppColors.primary
                      : (isKitchen ? AppColors.kitchenBorder : AppColors.line),
                  border: Border.all(
                    color: isFilled ? AppColors.primary : AppColors.mutedBrown.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
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
          const SizedBox(height: 16),

          // Numeric Keypad
          _buildKeypad(),

          const SizedBox(height: 12),
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
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((d) => _buildKey(d)).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((d) => _buildKey(d)).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((d) => _buildKey(d)).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 64, height: 48), // spacer
            _buildKey('0'),
            SizedBox(
              width: 64,
              height: 48,
              child: IconButton(
                onPressed: _onBackspacePressed,
                icon: const Icon(Icons.backspace_outlined, color: AppColors.darkBrown),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String digit) {
    return Container(
      width: 64,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.controller.kitchenMode ? Colors.white : AppColors.warmCream,
          foregroundColor: AppColors.darkBrown,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: widget.controller.kitchenMode ? AppColors.kitchenBorder : AppColors.line,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _onDigitPressed(digit),
        child: Text(
          digit,
          style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
