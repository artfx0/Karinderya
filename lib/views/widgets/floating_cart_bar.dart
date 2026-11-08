import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import '../sheets/cart_sheet.dart';

class FloatingCartBar extends StatefulWidget {
  final KarinderyaController controller;

  const FloatingCartBar({super.key, required this.controller});

  @override
  State<FloatingCartBar> createState() => _FloatingCartBarState();
}

class _FloatingCartBarState extends State<FloatingCartBar> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant FloatingCartBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCount = widget.controller.cartItemCount;
    if (newCount > _prevCount) {
      _bounceController.forward().then((_) => _bounceController.reverse());
    }
    _prevCount = newCount;
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => CartSheet(controller: widget.controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (controller.isCartEmpty) return const SizedBox.shrink();

    final isKitchen = controller.kitchenMode;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final tableTag = controller.activeOrderKind == OrderKind.takeout
        ? 'Takeout'
        : 'Table ${controller.activeTableNum}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ScaleTransition(
            scale: reduceMotion ? const AlwaysStoppedAnimation(1.0) : _scaleAnimation,
            child: Material(
              color: isKitchen ? AppColors.kitchenBorder : AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              elevation: isKitchen ? 0 : 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.35),
              child: InkWell(
                onTap: _openCartSheet,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Cart Item Count Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${controller.cartItemCount}',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Order Summary Tag
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View active order',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$tableTag • #${controller.activeOrderNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Big Total Price
                      Text(
                        '₱${controller.cartTotal.toStringAsFixed(0)}',
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
