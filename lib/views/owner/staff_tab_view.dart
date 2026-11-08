import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../models/staff_member.dart';
import '../../theme/app_theme.dart';

class StaffTabView extends StatelessWidget {
  final KarinderyaController controller;

  const StaffTabView({super.key, required this.controller});

  void _showAddStaffSheet(BuildContext context) {
    final nameController = TextEditingController();
    UserRole selectedRole = UserRole.staff;
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
                  'Magdagdag ng Kawani (Add Staff)',
                  style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Buong Pangalan (Full Name)',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Tungkulin (Role)',
                    filled: true,
                    fillColor: AppColors.warmCream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: const [
                    DropdownMenuItem(value: UserRole.staff, child: Text('Staff Cashier')),
                    DropdownMenuItem(value: UserRole.owner, child: Text('May-ari (Owner)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => selectedRole = val);
                    }
                  },
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
                      if (name.isEmpty) {
                        setSheetState(() => error = 'Paki-lagay po ang buong pangalan.');
                        return;
                      }

                      controller.addStaff(
                        StaffMember(
                          id: 'staff-${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          role: selectedRole,
                          onShift: true,
                        ),
                      );

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name naidagdag sa listahan ng kawani!'),
                          backgroundColor: AppColors.leafGreen,
                        ),
                      );
                    },
                    child: const Text('I-save ang Kawani'),
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
    final staffList = controller.staff;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mga Kawani (${staffList.length})',
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
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add Staff'),
                  onPressed: () => _showAddStaffSheet(context),
                ),
              ],
            ),
          ),

          // Staff Cards List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: staffList.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = staffList[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                      width: isKitchen ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: member.role == UserRole.owner
                            ? AppColors.brandOrange.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          member.avatarInitials,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: member.role == UserRole.owner ? AppColors.brandOrange : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: member.role == UserRole.owner
                                    ? AppColors.brandOrange.withValues(alpha: 0.1)
                                    : AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                member.role == UserRole.owner ? 'MAY-ARI (OWNER)' : 'STAFF CASHIER',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: member.role == UserRole.owner ? AppColors.brandOrange : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: member.onShift
                                  ? AppColors.leafGreen.withValues(alpha: 0.12)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              member.onShift ? 'On shift' : 'Off shift',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: member.onShift ? AppColors.leafGreen : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Switch(
                            value: member.onShift,
                            activeTrackColor: AppColors.leafGreen,
                            onChanged: (_) => controller.toggleStaffShift(member.id),
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
