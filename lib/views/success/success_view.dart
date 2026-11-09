import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/receipt_preview_modal.dart';

class SuccessView extends StatefulWidget {
  final KarinderyaController controller;

  const SuccessView({super.key, required this.controller});

  @override
  State<SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<SuccessView> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  late AnimationController _confettiController;
  Timer? _autoReturnTimer;
  int _secondsLeft = 5;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();

    // Checkmark animation
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _checkController.forward();

    // Confetti burst animation (<= 1s)
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _confettiController.forward();

    // 5-second countdown timer
    _autoReturnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsLeft--;
          if (_secondsLeft <= 0) {
            timer.cancel();
            widget.controller.setScreen(ScreenState.staff);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _autoReturnTimer?.cancel();
    _checkController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _returnNow() {
    _autoReturnTimer?.cancel();
    widget.controller.setScreen(ScreenState.staff);
  }

  void _openReceiptModal() {
    _autoReturnTimer?.cancel(); // Cancel auto-return when cashier prints receipt
    final lastOrder = widget.controller.lastCompletedOrder;
    if (lastOrder != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ReceiptPreviewModal(
          order: lastOrder,
          controller: widget.controller,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final totalPaid = controller.lastTotalPaid;
    final change = controller.lastChange;
    final orderNum = controller.lastOrderNum;
    final method = controller.lastPaymentMethod;
    final refNum = controller.lastReferenceNumber;
    final lastOrder = controller.lastCompletedOrder;

    return Scaffold(
      backgroundColor: isKitchen ? AppColors.kitchenBg : AppColors.warmCream,
      body: Stack(
        children: [
          // Confetti / Sparkle Burst Particle Painter
          if (!reduceMotion)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(progress: _confettiController.value),
                  );
                },
              ),
            ),

          // Main Success Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Checkmark Circle
                    ScaleTransition(
                      scale: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _checkAnimation,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.leafGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.leafGreen.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "Salamat po!" in Fredoka
                    Text(
                      'Salamat po!',
                      style: GoogleFonts.fredoka(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #$orderNum ay nai-record na sa kusina.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isKitchen ? Colors.grey.shade100 : AppColors.paperCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                          width: isKitchen ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Payment Method Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Paraan ng Bayad:',
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                              ),
                              _buildPaymentMethodBadge(method),
                            ],
                          ),
                          const Divider(color: AppColors.line, height: 20),

                          // Amount Paid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Kabuuang Halaga:',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₱${totalPaid.toStringAsFixed(2)}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBrown,
                                ),
                              ),
                            ],
                          ),

                          // If Cash: Show Change
                          if (method == PaymentMethod.cash) ...[
                            const Divider(color: AppColors.line, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sukli (Change):',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.leafGreen,
                                  ),
                                ),
                                Text(
                                  '₱${change.toStringAsFixed(2)}',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.leafGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // If Digital: Show Reference Number
                          if ((method == PaymentMethod.gcash || method == PaymentMethod.maya) &&
                              refNum != null &&
                              refNum.isNotEmpty) ...[
                            const Divider(color: AppColors.line, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reference No:',
                                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    refNum,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.courierPrime(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // If Utang: Show Customer
                          if (method == PaymentMethod.utang && lastOrder?.customerName != null) ...[
                            const Divider(color: AppColors.line, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nailista kay:',
                                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                                ),
                                Text(
                                  lastOrder!.customerName!,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mustard,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Action 1: Print Receipt Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: _openReceiptModal,
                        icon: const Icon(Icons.print_outlined, size: 20),
                        label: Text(
                          'I-print ang Resibo',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Primary Action 2: New Order / Finish Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _returnNow,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: Text(
                          _secondsLeft > 0 ? 'Bagong Order (${_secondsLeft}s)' : 'Bagong Order',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodBadge(PaymentMethod method) {
    Color color;
    String label;
    IconData icon;

    switch (method) {
      case PaymentMethod.cash:
        color = AppColors.leafGreen;
        label = 'CASH';
        icon = Icons.payments_outlined;
        break;
      case PaymentMethod.gcash:
        color = const Color(0xFF007DFE);
        label = 'GCASH';
        icon = Icons.account_balance_wallet_outlined;
        break;
      case PaymentMethod.maya:
        color = const Color(0xFF00B14F);
        label = 'MAYA';
        icon = Icons.qr_code_scanner;
        break;
      case PaymentMethod.utang:
        color = AppColors.mustard;
        label = 'UTANG';
        icon = Icons.menu_book_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> _pieces = [];

  _ConfettiPainter({required this.progress}) {
    final random = Random(42);
    final colors = [
      AppColors.brandOrange,
      AppColors.leafGreen,
      AppColors.mustard,
      AppColors.primary,
      Colors.pinkAccent,
      Colors.purpleAccent,
    ];

    for (int i = 0; i < 40; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 120 + random.nextDouble() * 240;
      final color = colors[random.nextInt(colors.length)];
      final size = 6.0 + random.nextDouble() * 6.0;
      _pieces.add(_ConfettiPiece(angle: angle, speed: speed, color: color, size: size));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height * 0.38);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final piece in _pieces) {
      final distance = piece.speed * progress;
      final x = center.dx + cos(piece.angle) * distance;
      final y = center.dy + sin(piece.angle) * distance + (progress * progress * 80); // gravity

      final paint = Paint()
        ..color = piece.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), piece.size * (1.0 - progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

class _ConfettiPiece {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  _ConfettiPiece({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}
