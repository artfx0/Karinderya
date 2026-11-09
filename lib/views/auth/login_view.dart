import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/karinderya_controller.dart';
import '../../models/seed_data.dart';
import '../../theme/app_theme.dart';

class LoginView extends StatefulWidget {
  final KarinderyaController controller;

  const LoginView({super.key, required this.controller});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late AnimationController _steamController;
  late Animation<double> _steamAnimation;

  final TextEditingController _emailController = TextEditingController(
    text: SeedData.demoStaffEmail,
  );
  final TextEditingController _passwordController = TextEditingController(
    text: SeedData.demoStaffPassword,
  );

  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  String? _authError;

  @override
  void initState() {
    super.initState();
    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _steamAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _steamController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _steamController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Magandang umaga!';
    } else if (hour < 13) {
      return 'Magandang tanghali!';
    } else if (hour < 18) {
      return 'Magandang hapon!';
    } else {
      return 'Magandang gabi!';
    }
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = email.isEmpty || !email.contains('@')
          ? 'Paki-check po ang email address.'
          : null;
      _passwordError = password.isEmpty ? 'Ilagay po ang password.' : null;
      _authError = null;
    });

    if (_emailError != null || _passwordError != null) return;

    final success = widget.controller.loginWithCredentials(email, password);
    if (!success) {
      setState(() {
        _authError = 'Maling email o password. Paki-subukan muli.';
      });
    }
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.controller.kitchenMode
                ? Colors.white
                : AppColors.paperCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: widget.controller.kitchenMode
                  ? AppColors.kitchenBorder
                  : AppColors.line,
              width: widget.controller.kitchenMode ? 2.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Nakalimutan ang Password?',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ask your owner to reset it, po. Sila po ang may hawak ng admin access sa accounts.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.mutedBrown,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Naiintindihan ko',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSignUpSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.controller.kitchenMode
                ? Colors.white
                : AppColors.paperCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: widget.controller.kitchenMode
                  ? AppColors.kitchenBorder
                  : AppColors.line,
              width: widget.controller.kitchenMode ? 2.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kailangan ng Account?',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ask your owner for an invite. Sila po ang magdaragdag ng inyong account sa Staff list.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.mutedBrown,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Sige po',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isKitchen = widget.controller.kitchenMode;

    return Scaffold(
      backgroundColor: isKitchen ? AppColors.kitchenBg : AppColors.warmCream,
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Header Section
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
                        decoration: BoxDecoration(
                          color: isKitchen
                              ? AppColors.kitchenBorder
                              : AppColors.brandOrange,
                          boxShadow: isKitchen
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.brandOrange.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Column(
                          children: [
                            // Top Bar with Brand & Kitchen Mode Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Karinderya',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warmCream,
                                  ),
                                ),
                                IconButton.filledTonal(
                                  onPressed: () =>
                                      widget.controller.toggleKitchenMode(),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.25,
                                    ),
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(48, 48),
                                  ),
                                  icon: Icon(
                                    isKitchen
                                        ? Icons.wb_sunny
                                        : Icons.wb_sunny_outlined,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'Kitchen Mode',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Floating Food Art
                            AnimatedBuilder(
                              animation: _steamController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    reduceMotion ? 0 : _steamAnimation.value,
                                  ),
                                  child: child,
                                );
                              },
                              child: Container(
                                height: 130,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: SvgPicture.asset(
                                  'assets/hero-art.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Wavy Cream Divider
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipPath(
                          clipper: _WaveClipper(),
                          child: Container(
                            height: 24,
                            color: isKitchen
                                ? AppColors.kitchenBg
                                : AppColors.warmCream,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Greeting & Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTimeGreeting(),
                          style: GoogleFonts.fredoka(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isKitchen
                                ? AppColors.kitchenText
                                : AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mag-login upang simulan ang POS at pagtitinda.",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: isKitchen
                                ? AppColors.kitchenText
                                : AppColors.mutedBrown,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Auth Error Banner (if incorrect credentials)
                        if (_authError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.chiliRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.chiliRed.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.chiliRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _authError!,
                                    style: GoogleFonts.inter(
                                      color: AppColors.chiliRed,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        Text(
                          'Email Address',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isKitchen
                                ? AppColors.kitchenText
                                : AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: isKitchen
                                ? AppColors.kitchenText
                                : AppColors.darkBrown,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isKitchen
                                ? Colors.white
                                : AppColors.paperCard,
                            hintText: 'halimbawa@karinderya.ph',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.mutedBrown,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isKitchen
                                    ? AppColors.kitchenBorder
                                    : AppColors.line,
                                width: isKitchen ? 2 : 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isKitchen
                                    ? AppColors.kitchenBorder
                                    : AppColors.line,
                                width: isKitchen ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        if (_emailError != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 16,
                                color: AppColors.chiliRed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _emailError!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.chiliRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Password Field
                        Text(
                          'Password',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isKitchen
                                ? AppColors.kitchenText
                                : AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: isKitchen
                                ? AppColors.kitchenText
                                : AppColors.darkBrown,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isKitchen
                                ? Colors.white
                                : AppColors.paperCard,
                            hintText: '••••••••',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.mutedBrown,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.mutedBrown,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isKitchen
                                    ? AppColors.kitchenBorder
                                    : AppColors.line,
                                width: isKitchen ? 2 : 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: isKitchen
                                    ? AppColors.kitchenBorder
                                    : AppColors.line,
                                width: isKitchen ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        if (_passwordError != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 16,
                                color: AppColors.chiliRed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _passwordError!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.chiliRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordSheet,
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Primary Login / Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: isKitchen ? 0 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: _handleLogin,
                            child: Text(
                              'Magpatuloy / Log in',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sign Up Link
                        Center(
                          child: TextButton(
                            onPressed: _showSignUpSheet,
                            child: RichText(
                              text: TextSpan(
                                text: 'Walang account? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.mutedBrown,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Mag-sign up',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.25,
      0,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
