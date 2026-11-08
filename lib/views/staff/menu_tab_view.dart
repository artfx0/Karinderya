import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/dish_card.dart';

class MenuTabView extends StatefulWidget {
  final KarinderyaController controller;

  const MenuTabView({super.key, required this.controller});

  @override
  State<MenuTabView> createState() => _MenuTabViewState();
}

class _MenuTabViewState extends State<MenuTabView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.controller.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Simulate refreshing menu data
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {});
    }
  }

  String _getCategoryTitle(DishCategory category) {
    switch (category) {
      case DishCategory.all:
        return 'All dishes';
      case DishCategory.ulam:
        return 'Ulam';
      case DishCategory.rice:
        return 'Rice & sides';
      case DishCategory.soup:
        return 'Soup';
      case DishCategory.drinks:
        return 'Drinks';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final dishes = controller.filteredDishes;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // Search & Filter Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => controller.setSearchQuery(val),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Maghanap ng ulam, kanin, o inumin...',
                      hintStyle: GoogleFonts.inter(color: AppColors.mutedBrown),
                      prefixIcon: const Icon(Icons.search, color: AppColors.mutedBrown),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.mutedBrown),
                              onPressed: () {
                                _searchController.clear();
                                controller.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isKitchen ? Colors.white : AppColors.paperCard,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                          width: isKitchen ? 2 : 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                          width: isKitchen ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: DishCategory.values.map((cat) {
                        final isSelected = controller.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_getCategoryTitle(cat)),
                            selected: isSelected,
                            onSelected: (_) => controller.setSelectedCategory(cat),
                            backgroundColor: isKitchen ? Colors.white : AppColors.paperCard,
                            selectedColor: AppColors.primary,
                            labelStyle: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isKitchen ? AppColors.kitchenText : AppColors.darkBrown),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isKitchen ? AppColors.kitchenBorder : AppColors.line),
                                width: isKitchen ? 2 : 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // "Today's Menu" Title & Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Menu",
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${dishes.length} ${dishes.length == 1 ? "dish" : "dishes"}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Dishes Grid or Empty State
          if (dishes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: SvgPicture.asset(
                          controller.searchQuery.isNotEmpty ? 'assets/empty-pot.svg' : 'assets/rice-cooker.svg',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.isNotEmpty
                            ? 'Wala po kaming nahanap.'
                            : 'Wala pang menu ngayon.',
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.searchQuery.isNotEmpty
                            ? 'Subukang mag-search ng ibang pangalan ng ulam.'
                            : 'Magdagdag ng mga ulam mula sa Menu Setup.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.mutedBrown,
                        ),
                      ),
                      if (controller.searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            controller.setSearchQuery('');
                          },
                          child: const Text('I-clear ang Search'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // bottom clearance for floating cart
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.crossAxisExtent > 700 ? 4 : 2;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dish = dishes[index];
                        return DishCard(
                          dish: dish,
                          controller: controller,
                        );
                      },
                      childCount: dishes.length,
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
