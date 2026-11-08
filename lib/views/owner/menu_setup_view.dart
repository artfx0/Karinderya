import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../models/dish.dart';
import '../../theme/app_theme.dart';

class MenuSetupView extends StatelessWidget {
  final KarinderyaController controller;

  const MenuSetupView({super.key, required this.controller});

  void _showAddDishDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final capController = TextEditingController(text: '15');
    DishCategory selectedCategory = DishCategory.ulam;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: controller.kitchenMode ? Colors.white : AppColors.paperCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: controller.kitchenMode ? AppColors.kitchenBorder : AppColors.line,
                width: controller.kitchenMode ? 2.5 : 1.0,
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
                Text(
                  'Magdagdag ng Bagong Ulam / Produkto',
                  style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Pangalan ng Ulam (Dish Name)',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Presyo (₱)',
                          filled: true,
                          fillColor: AppColors.warmCream,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: capController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cooked Today (Cap)',
                          filled: true,
                          fillColor: AppColors.warmCream,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<DishCategory>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategorya (Category)',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: [
                    DishCategory.ulam,
                    DishCategory.rice,
                    DishCategory.soup,
                    DishCategory.drinks,
                  ].map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => selectedCategory = val);
                    }
                  },
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: GoogleFonts.inter(color: AppColors.chiliRed, fontSize: 12)),
                ],
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final price = double.tryParse(priceController.text.trim());
                      final cap = int.tryParse(capController.text.trim()) ?? 15;

                      if (name.isEmpty || price == null || price <= 0) {
                        setSheetState(() {
                          error = 'Paki-kumpleto po ang tamang pangalan at presyo.';
                        });
                        return;
                      }

                      controller.addDish(
                        Dish(
                          id: 'dish-${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          price: price,
                          category: selectedCategory,
                          stock: cap,
                          cap: cap,
                          image: 'assets/adobo.svg',
                          isAvailable: true,
                        ),
                      );

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name idinagdag sa menu!'),
                          backgroundColor: AppColors.leafGreen,
                        ),
                      );
                    },
                    child: const Text('I-save ang Ulam'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = controller.kitchenMode;
    final dishes = controller.dishes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: dishes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: SvgPicture.asset('assets/rice-cooker.svg'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wala pang menu ngayon.',
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Magdagdag ng mga lulutuing ulam sa ibaba.',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedBrown),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddDishDialog(context),
                    child: const Text('+ Magdagdag ng Ulam'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menu Setup (${dishes.length} ulam)',
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Magdagdag'),
                        onPressed: () => _showAddDishDialog(context),
                      ),
                    ],
                  ),
                ),

                // Dish Configuration List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: dishes.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final dish = dishes[index];

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                            width: isKitchen ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.warmCream,
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: SvgPicture.asset(dish.image),
                                ),
                                const SizedBox(width: 12),
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
                                        '₱${dish.price.toStringAsFixed(0)} • ${dish.category.name.toUpperCase()}',
                                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                                      ),
                                    ],
                                  ),
                                ),
                                // Available / Sold Out Toggle
                                Switch(
                                  value: dish.isAvailable,
                                  activeTrackColor: AppColors.primary,
                                  onChanged: (_) => controller.toggleDishAvailability(dish.id),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.line, height: 20),

                            // Servings Steppers Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Servings Left Stepper
                                Row(
                                  children: [
                                    Text(
                                      'Stock: ',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: () => controller.updateDishStock(dish.id, dish.stock - 1),
                                    ),
                                    Text(
                                      '${dish.stock}',
                                      style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () => controller.updateDishStock(dish.id, dish.stock + 1),
                                    ),
                                  ],
                                ),

                                // Cooked Today (Cap) Stepper
                                Row(
                                  children: [
                                    Text(
                                      'Cap: ',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: () => controller.updateDishCap(dish.id, dish.cap - 1),
                                    ),
                                    Text(
                                      '${dish.cap}',
                                      style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () => controller.updateDishCap(dish.id, dish.cap + 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
