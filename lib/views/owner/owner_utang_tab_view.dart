import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/customer.dart';
import '../../theme/app_theme.dart';

class OwnerUtangTabView extends StatefulWidget {
  final KarinderyaController controller;

  const OwnerUtangTabView({super.key, required this.controller});

  @override
  State<OwnerUtangTabView> createState() => _OwnerUtangTabViewState();
}

class _OwnerUtangTabViewState extends State<OwnerUtangTabView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.controller.ownerUtangSearchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDebtorSheet(BuildContext context) {
    final controller = widget.controller;
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final debtController = TextEditingController();
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
                  'Magdagdag ng Bagong May Utang',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: controller.kitchenMode ? AppColors.kitchenText : AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Pangalan (Name)',
                    hintText: 'Halimbawa: Mang Tomas',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: 'Contact Information (Phone / Address)',
                    hintText: 'Halimbawa: 0917-555-8899',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: debtController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Initial Debt Amount',
                    prefixText: '₱ ',
                    hintText: '0',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!, style: GoogleFonts.inter(color: AppColors.chiliRed, fontSize: 12)),
                ],
                const SizedBox(height: 18),

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
                      final contact = contactController.text.trim();
                      final initialDebt = double.tryParse(debtController.text.trim());

                      if (name.isEmpty || contact.isEmpty || initialDebt == null || initialDebt <= 0) {
                        setSheetState(() {
                          error = 'Paki-kumpleto ang pangalan, contact info, at wastong halaga ng utang.';
                        });
                        return;
                      }

                      controller.addDebtor(
                        name: name,
                        contactInfo: contact,
                        initialDebt: initialDebt,
                      );

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name idinagdag sa listahan ng may utang!'),
                          backgroundColor: AppColors.leafGreen,
                        ),
                      );
                    },
                    child: const Text('I-save ang Debtor'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettleDebtModal(BuildContext context, Customer customer) {
    final controller = widget.controller;
    final payController = TextEditingController(text: customer.balance.toStringAsFixed(0));
    String? error;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) {
          return AlertDialog(
            backgroundColor: controller.kitchenMode ? Colors.white : AppColors.paperCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Mag-record ng Bayad',
              style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suki: ${customer.name}',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (customer.contactInfo.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    customer.contactInfo,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Kasalukuyang Utang: ₱${customer.balance.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.chiliRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Halaga ng ibabayad ngayon:',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: payController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '₱ ',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: GoogleFonts.inter(color: AppColors.chiliRed, fontSize: 12)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Kanselahin'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.leafGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  final amount = double.tryParse(payController.text.trim());
                  if (amount == null || amount <= 0) {
                    setModalState(() => error = 'Paki-lagay po ang wastong halaga.');
                    return;
                  }

                  controller.settleCustomerDebt(customer.id, amount);
                  Navigator.pop(dialogCtx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Payment recorded. Salamat po!',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.leafGreen,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 76),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: const Text('I-record ang Bayad'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    // Strictly displays active debtors only (auto-clears settled debts where balance <= 0)
    final activeDebtors = controller.activeDebtors;
    final totalOutstanding = controller.customers.fold(0.0, (sum, c) => sum + c.balance);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: Text(
          'Add Debtor',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddDebtorSheet(context),
      ),
      body: Column(
        children: [
          // Total Outstanding Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenBorder : AppColors.darkBrown,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'TOTAL OUTSTANDING (UTANG)',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: AppColors.warmCream.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.leafGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Owner Access',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${totalOutstanding.toStringAsFixed(0)}',
                    style: GoogleFonts.fredoka(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmCream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pindutin ang sinumang suki upang mag-record ng buo o hulugang bayad.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.warmCream.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Real-Time Debtor Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: controller.setOwnerUtangSearchQuery,
              decoration: InputDecoration(
                hintText: 'Maghanap ng may utang o contact info...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.mutedBrown),
                suffixIcon: controller.ownerUtangSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          controller.setOwnerUtangSearchQuery('');
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

          // Active Customer Debts List (Zero settled profiles)
          Expanded(
            child: activeDebtors.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.ownerUtangSearchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.celebration,
                            color: controller.ownerUtangSearchQuery.isNotEmpty
                                ? AppColors.mutedBrown
                                : AppColors.leafGreen,
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.ownerUtangSearchQuery.isNotEmpty
                                ? 'Walang suking nahanap'
                                : 'Wala nang utang. Salamat po!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.ownerUtangSearchQuery.isNotEmpty
                                ? 'Subukang maglagay ng ibang pangalan sa search bar.'
                                : 'Lahat ng suki ay nakapagbayad na.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: AppColors.mutedBrown),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                    itemCount: activeDebtors.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final customer = activeDebtors[index];

                      return InkWell(
                        onTap: () => _showSettleDebtModal(context, customer),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                              width: isKitchen ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.chiliRed.withValues(alpha: 0.15),
                                    child: Text(
                                      customer.avatarInitials,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.chiliRed,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                                          ),
                                        ),
                                        if (customer.contactInfo.isNotEmpty)
                                          Text(
                                            customer.contactInfo,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.darkBrown.withValues(alpha: 0.75),
                                            ),
                                          ),
                                        Text(
                                          '${customer.openOrders} bukas na order • ${customer.date}',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₱${customer.balance.toStringAsFixed(0)}',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.chiliRed,
                                        ),
                                      ),
                                      Text(
                                        'Tap to pay',
                                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (customer.originalTotal > 0) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: customer.paymentProgress,
                                    minHeight: 6,
                                    backgroundColor: AppColors.line.withValues(alpha: 0.5),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
                                  ),
                                ),
                              ],
                            ],
                          ),
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
