import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../models/dish.dart';
import '../../theme/app_theme.dart';

class MenuSetupView extends StatefulWidget {
  final KarinderyaController controller;

  const MenuSetupView({super.key, required this.controller});

  @override
  State<MenuSetupView> createState() => _MenuSetupViewState();
}

class _MenuSetupViewState extends State<MenuSetupView> {
  final TextEditingController _searchController = TextEditingController();

  static const List<({DishCategory category, String label})> _categories = [
    (category: DishCategory.ulam, label: 'Ulams'),
    (category: DishCategory.rice, label: 'Rice & Sides'),
    (category: DishCategory.soup, label: 'Soup'),
    (category: DishCategory.drinks, label: 'Drinks'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.controller.ownerMenuSearchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _categoryLabel(DishCategory cat) {
    for (final entry in _categories) {
      if (entry.category == cat) return entry.label;
    }
    return cat.name.toUpperCase();
  }

  String _sortLabel(OwnerMenuSortOption option) {
    switch (option) {
      case OwnerMenuSortOption.defaultOrder:
        return 'Default Order';
      case OwnerMenuSortOption.nameAZ:
        return 'Pangalan (A–Z)';
      case OwnerMenuSortOption.priceLowToHigh:
        return 'Presyo: Mababa–Mataas';
      case OwnerMenuSortOption.priceHighToLow:
        return 'Presyo: Mataas–Mababa';
      case OwnerMenuSortOption.stockLowToHigh:
        return 'Stock: Paubos Una';
      case OwnerMenuSortOption.stockHighToLow:
        return 'Stock: Pinakamarami';
    }
  }

  String _availabilityLabel(OwnerMenuAvailabilityFilter filter) {
    switch (filter) {
      case OwnerMenuAvailabilityFilter.all:
        return 'Lahat';
      case OwnerMenuAvailabilityFilter.availableOnly:
        return 'Available Lang';
      case OwnerMenuAvailabilityFilter.soldOutOnly:
        return 'Sold Out Lang';
    }
  }

  void _showFilterSortSheet(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: BoxDecoration(
              color: isKitchen ? Colors.white : AppColors.paperCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                width: isKitchen ? 2.5 : 1.0,
              ),
            ),
            child: SafeArea(
              top: false,
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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Ayusin at Salain (Sort & Filter)',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fredoka(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                      ),
                      if (controller.hasActiveOwnerMenuFilter)
                        TextButton(
                          onPressed: () {
                            controller.resetOwnerMenuFilters();
                            setSheetState(() {});
                          },
                          child: Text(
                            'I-reset',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Ayos ng Listahan (Sort By)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mutedBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: OwnerMenuSortOption.values.map((option) {
                      final isSelected = controller.ownerMenuSort == option;
                      return ChoiceChip(
                        label: Text(_sortLabel(option)),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.darkBrown,
                        ),
                        onSelected: (_) {
                          controller.setOwnerMenuSort(option);
                          setSheetState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Katayuan (Availability)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mutedBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: OwnerMenuAvailabilityFilter.values.map((filter) {
                      final isSelected = controller.ownerMenuAvailability == filter;
                      return ChoiceChip(
                        label: Text(_availabilityLabel(filter)),
                        selected: isSelected,
                        selectedColor: AppColors.brandOrange,
                        backgroundColor: isKitchen ? Colors.grey.shade100 : AppColors.warmCream,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.darkBrown,
                        ),
                        onSelected: (_) {
                          controller.setOwnerMenuAvailability(filter);
                          setSheetState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tapos na'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddDishDialog(BuildContext context) {
    final controller = widget.controller;
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final capController = TextEditingController(text: '15');
    DishCategory selectedCategory = controller.ownerMenuCategory;
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
                  items: _categories.map((entry) {
                    return DropdownMenuItem(
                      value: entry.category,
                      child: Text(entry.label),
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
                      controller.setOwnerMenuCategory(selectedCategory);

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name idinagdag sa ${_categoryLabel(selectedCategory)}!'),
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
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final allDishes = controller.dishes;
    final visibleDishes = controller.filteredOwnerDishes;
    final activeCategory = controller.ownerMenuCategory;
    final hasActiveFilter = controller.hasActiveOwnerMenuFilter;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Top Action Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Menu Setup (${allDishes.length} items)',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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

          // Persistent Search Bar + Filter Icon above Menu Categories
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: controller.setOwnerMenuSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Maghanap ng ulam, kanin, sabaw, o inumin...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.mutedBrown),
                      suffixIcon: controller.ownerMenuSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                controller.setOwnerMenuSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
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
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      color: hasActiveFilter
                          ? AppColors.primary.withValues(alpha: 0.14)
                          : (isKitchen ? AppColors.kitchenSurface : AppColors.paperCard),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: hasActiveFilter
                              ? AppColors.primary
                              : (isKitchen ? AppColors.kitchenBorder : AppColors.line),
                          width: isKitchen ? 2 : 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: hasActiveFilter ? AppColors.primary : AppColors.darkBrown,
                        ),
                        tooltip: 'Sort & Filter Menu',
                        onPressed: () => _showFilterSortSheet(context),
                      ),
                    ),
                    if (hasActiveFilter)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Strictly Categorized Tab / Segmented Layout: Ulams, Rice & Sides, Soup, Drinks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((entry) {
                  final isSelected = activeCategory == entry.category;
                  final count = controller.getOwnerDishCountForCategory(entry.category);

                  return ChoiceChip(
                    label: Text('${entry.label} ($count)'),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isKitchen ? AppColors.kitchenBorder : AppColors.line),
                      width: isKitchen ? 2 : 1,
                    ),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isKitchen ? AppColors.kitchenText : AppColors.darkBrown),
                    ),
                    onSelected: (_) => controller.setOwnerMenuCategory(entry.category),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Dish Configuration List for Selected Category
          Expanded(
            child: visibleDishes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: SvgPicture.asset('assets/rice-cooker.svg'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Walang nahanap sa ${_categoryLabel(activeCategory)}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.ownerMenuSearchQuery.isNotEmpty || hasActiveFilter
                                ? 'Subukang baguhin ang search o filter sa itaas.'
                                : 'Pindutin ang "Magdagdag" para maglagay ng item sa kategoryang ito.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: visibleDishes.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final dish = visibleDishes[index];

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
                                        '₱${dish.price.toStringAsFixed(0)} • ${_categoryLabel(dish.category)}',
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
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                // Servings Left Stepper
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Stock: ',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: () => controller.updateDishStock(dish.id, dish.stock - 1),
                                    ),
                                    Text(
                                      '${dish.stock}',
                                      style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () => controller.updateDishStock(dish.id, dish.stock + 1),
                                    ),
                                  ],
                                ),

                                // Cooked Today (Cap) Stepper
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Cap: ',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: () => controller.updateDishCap(dish.id, dish.cap - 1),
                                    ),
                                    Text(
                                      '${dish.cap}',
                                      style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
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
