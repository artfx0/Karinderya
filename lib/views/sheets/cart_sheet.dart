import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import 'checkout_sheet.dart';

class CartSheet extends StatelessWidget {
  final KarinderyaController controller;

  const CartSheet({super.key, required this.controller});

  void _showCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: controller.kitchenMode ? Colors.white : AppColors.paperCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Itapon ang kasalukuyang order?',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        content: Text(
          'Mawawala ang lahat ng nilagay na pagkain sa order na ito.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Huwag itapon',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.darkBrown),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.chiliRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              controller.clearCart();
              Navigator.pop(dialogCtx);
              Navigator.pop(context); // Close cart sheet
            },
            child: Text(
              'Oo, itapon',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _openCheckoutSheet(BuildContext context) {
    Navigator.pop(context); // Close cart sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => CheckoutSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final tableTag = controller.activeOrderKind == OrderKind.takeout
        ? 'Takeout'
        : 'Table ${controller.activeTableNum} - Dine in';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 640,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
          width: isKitchen ? 2.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),

          // Sheet Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${controller.activeOrderNumber}',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                      ),
                    ),
                    Text(
                      tableTag,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Isara',
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.line, height: 20),

          // Items List or Empty State
          Expanded(
            child: controller.isCartEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: SvgPicture.asset('assets/empty-pot.svg'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Walang order pa. Magluto na!',
                            style: GoogleFonts.fredoka(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pumili ng mga masasarap na ulam sa menu.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.mutedBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: controller.cart.length,
                    separatorBuilder: (context, _) => const Divider(color: AppColors.line, height: 16),
                    itemBuilder: (context, index) {
                      final item = controller.cart[index];
                      final dish = item.dish;

                      return Row(
                        children: [
                          // Thumbnail
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.warmCream,
                              border: Border.all(color: AppColors.line),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset(dish.image),
                          ),
                          const SizedBox(width: 12),

                          // Name & Unit Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dish.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                  ),
                                ),
                                Text(
                                  '₱${dish.price.toStringAsFixed(0)} bawat isa',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.mutedBrown,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 48px Stepper Buttons
                          Container(
                            decoration: BoxDecoration(
                              color: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: () => controller.updateCartQuantity(dish.id, -1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '${item.quantity}',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () => controller.updateCartQuantity(dish.id, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Line Total
                          SizedBox(
                            width: 60,
                            child: Text(
                              '₱${item.lineTotal.toStringAsFixed(0)}',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isKitchen ? AppColors.kitchenText : AppColors.primary,
                              ),
                            ),
                          ),

                          // Trash Can
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.chiliRed, size: 20),
                            onPressed: () => controller.removeFromCart(dish.id),
                            tooltip: 'Tanggalin',
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Bottom Bar & Total
          if (!controller.isCartEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isKitchen ? Colors.white : AppColors.warmCream,
                border: Border(
                  top: BorderSide(
                    color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                    width: isKitchen ? 2 : 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kabuuan (${controller.cartItemCount} piraso):',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                        Text(
                          '₱${controller.cartTotal.toStringAsFixed(0)}',
                          style: GoogleFonts.fredoka(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Continue to Checkout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: isKitchen ? 0 : 2,
                        ),
                        onPressed: () => _openCheckoutSheet(context),
                        child: Text(
                          'Magpatuloy sa Checkout',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Cancel Order Text Button
                    TextButton(
                      onPressed: () => _showCancelOrderDialog(context),
                      child: Text(
                        'Kanselahin ang order',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.chiliRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
