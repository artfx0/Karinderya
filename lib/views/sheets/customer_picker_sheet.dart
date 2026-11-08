import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../theme/app_theme.dart';

class CustomerPickerSheet extends StatefulWidget {
  final KarinderyaController controller;

  const CustomerPickerSheet({super.key, required this.controller});

  @override
  State<CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<CustomerPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newCustomerController = TextEditingController();
  bool _isAddingNew = false;
  String? _newCustomerError;

  @override
  void dispose() {
    _searchController.dispose();
    _newCustomerController.dispose();
    super.dispose();
  }

  void _confirmUtang(String customerName) {
    final success = widget.controller.recordUtang(customerName);
    if (success) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context); // Close picker
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Order saved. Utang recorded para kay $customerName!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.leafGreen,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleAddNewCustomer() {
    final name = _newCustomerController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _newCustomerError = 'Paki-lagay po ang pangalan ng suki.';
      });
      return;
    }
    _confirmUtang(name);
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = widget.controller.kitchenMode;
    final query = _searchController.text.toLowerCase();
    final customers = widget.controller.customers.where(
      (c) => c.name.toLowerCase().contains(query),
    ).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 640,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
          width: isKitchen ? 2.5 : 1.0,
        ),
      ),
      child: Column(
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pumili ng Suki (Utang)',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Maghanap ng suki...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isKitchen ? Colors.white : AppColors.warmCream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.line),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Toggle Add New Customer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Listahan ng mga Suki',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: Icon(_isAddingNew ? Icons.close : Icons.person_add_alt_1, size: 18),
                label: Text(_isAddingNew ? 'Kanselahin' : '+ Bagong Suki'),
                onPressed: () {
                  setState(() {
                    _isAddingNew = !_isAddingNew;
                    _newCustomerError = null;
                  });
                },
              ),
            ],
          ),

          if (_isAddingNew) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warmCream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _newCustomerController,
                    decoration: InputDecoration(
                      hintText: 'Buong pangalan ng bagong suki...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (_newCustomerError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _newCustomerError!,
                      style: GoogleFonts.inter(color: AppColors.chiliRed, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _handleAddNewCustomer,
                      child: const Text('Ilista ang Utang'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Existing Customers List
          Expanded(
            child: customers.isEmpty
                ? Center(
                    child: Text(
                      'Walang suki na tumugma sa pangalan.',
                      style: GoogleFonts.inter(color: AppColors.mutedBrown),
                    ),
                  )
                : ListView.separated(
                    itemCount: customers.length,
                    separatorBuilder: (context, _) => const Divider(color: AppColors.line, height: 12),
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            customer.avatarInitials,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Kasalukuyang utang: ₱${customer.balance.toStringAsFixed(0)}'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () => _confirmUtang(customer.name),
                          child: const Text('Ilista'),
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
