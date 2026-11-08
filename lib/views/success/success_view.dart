import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

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

    // Auto-return to Menu after 1500ms
    _autoReturnTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.controller.setScreen(ScreenState.staff);
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

  @override
  Widget build(BuildContext context) {
    final isKitchen = widget.controller.kitchenMode;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final totalPaid = widget.controller.lastTotalPaid;
    final change = widget.controller.lastChange;
    final orderNum = widget.controller.lastOrderNum;

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
                        width: 100,
                        height: 100,
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
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // "Salamat po!" in Fredoka
                    Text(
                      'Salamat po!',
                      style: GoogleFonts.fredoka(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Order #$orderNum ay nai-record na bilang PAID.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Big Green Card: Amount Paid & Change
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.leafGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.leafGreen,
                          width: isKitchen ? 2.5 : 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Halagang Binayaran:',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '₱${totalPaid.toStringAsFixed(0)}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBrown,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.leafGreen, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sukli (Change to return):',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.leafGreen,
                                ),
                              ),
                              Text(
                                '₱${change.toStringAsFixed(0)}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.leafGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Return Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: _returnNow,
                        child: Text(
                          'Bumalik sa Menu (1.5s)',
                          style: GoogleFonts.inter(
                            fontSize: 16,
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
