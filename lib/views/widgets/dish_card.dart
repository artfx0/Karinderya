import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../models/dish.dart';
import '../../theme/app_theme.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final KarinderyaController controller;

  const DishCard({
    super.key,
    required this.dish,
    required this.controller,
  });

  Color _getCategoryRingColor(DishCategory category) {
    switch (category) {
      case DishCategory.ulam:
        return AppColors.categoryUlam;
      case DishCategory.rice:
        return AppColors.categoryRice;
      case DishCategory.soup:
        return AppColors.categorySoup;
      case DishCategory.drinks:
        return AppColors.categoryDrinks;
      case DishCategory.all:
        return AppColors.primary;
    }
  }

  Color _getServingsBarColor(double ratio) {
    if (ratio > 0.5) return AppColors.leafGreen;
    if (ratio >= 0.25) return AppColors.mustard;
    return AppColors.chiliRed;
  }

  void _handleAddToCart(BuildContext context) {
    final success = controller.addToCart(dish);
    if (success) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${dish.name} idinagdag sa order!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.leafGreen,
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ubos na po ang ${dish.name}.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.chiliRed,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final isSoldOut = dish.isSoldOut;
    final ringColor = _getCategoryRingColor(dish.category);
    final ratio = dish.stockRatio;
    final barColor = _getServingsBarColor(ratio);

    // Cart quantity for this dish
    final cartItemIndex = controller.cart.indexWhere((item) => item.dish.id == dish.id);
    final cartQuantity = cartItemIndex >= 0 ? controller.cart[cartItemIndex].quantity : 0;

    return Opacity(
      opacity: isSoldOut ? 0.65 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
            width: isKitchen ? 2.5 : 1.0,
          ),
          boxShadow: isKitchen
              ? null
              : [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Category Ring Thumbnail + Category Tag Pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Thumbnail with Category Ring
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ringColor, width: 3),
                          color: AppColors.warmCream,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset(
                          dish.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ringColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                dish.category.name.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: ringColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Large Price
                            Text(
                              '₱${dish.price.toStringAsFixed(0)}',
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isKitchen ? AppColors.kitchenText : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dish Name
                  Text(
                    dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Servings Bar & Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isSoldOut ? '0 left' : '${dish.stock} left',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSoldOut ? AppColors.chiliRed : barColor,
                          ),
                        ),
                      ),
                      Text(
                        'Cap: ${dish.cap}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isKitchen ? AppColors.kitchenText : AppColors.mutedBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: isSoldOut ? 0.0 : ratio,
                      minHeight: 6,
                      backgroundColor: AppColors.line.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mark Available / Sold Out Pill Toggle
                  InkWell(
                    onTap: () => controller.toggleDishAvailability(dish.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSoldOut
                            ? AppColors.chiliRed.withValues(alpha: 0.1)
                            : AppColors.leafGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSoldOut
                              ? AppColors.chiliRed.withValues(alpha: 0.3)
                              : AppColors.leafGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSoldOut ? Icons.block : Icons.check,
                            size: 13,
                            color: isSoldOut ? AppColors.chiliRed : AppColors.leafGreen,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isSoldOut ? 'Available' : 'Sold Out',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSoldOut ? AppColors.chiliRed : AppColors.leafGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  // 56px Min Touch Add / Cart Stepper Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: isSoldOut
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.grey.shade600,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => _handleAddToCart(context),
                            child: Text(
                              'Sold Out',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            ),
                          )
                        : cartQuantity > 0
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, color: Colors.white, size: 22),
                                      onPressed: () => controller.updateCartQuantity(dish.id, -1),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$cartQuantity',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Colors.white, size: 22),
                                      onPressed: () => _handleAddToCart(context),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: isKitchen ? 0 : 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () => _handleAddToCart(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add, size: 20),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Add',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ],
              ),
            ),

            // Diagonal "Sold out na po!" Ribbon
            if (isSoldOut)
              Positioned(
                top: 14,
                right: -28,
                child: Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    color: AppColors.chiliRed,
                    alignment: Alignment.center,
                    child: Text(
                      'Sold out na po!',
                      style: GoogleFonts.fredoka(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
