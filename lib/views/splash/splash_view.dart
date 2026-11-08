import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class SplashView extends StatefulWidget {
  final KarinderyaController controller;

  const SplashView({super.key, required this.controller});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  Timer? _timer;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Auto-advance after 2000ms
    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        _opacity = 0.0;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.controller.setScreen(ScreenState.login);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedOpacity(
      duration: Duration(milliseconds: reduceMotion ? 0 : 300),
      opacity: _opacity,
      child: Scaffold(
        backgroundColor: AppColors.brandOrange,
        body: Stack(
          children: [
            // Banig Woven Texture Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: SvgPicture.asset(
                  'assets/banig.svg',
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),

            // Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Floating Mascot
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, reduceMotion ? 0 : _floatAnimation.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SvgPicture.asset(
                        'assets/mascot.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Brand Title
                  Text(
                    'Karinderya',
                    style: GoogleFonts.fredoka(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmCream,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sarap ng bahay, handa na!',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
