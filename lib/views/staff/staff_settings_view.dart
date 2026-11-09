import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class StaffSettingsView extends StatefulWidget {
  final KarinderyaController controller;

  const StaffSettingsView({super.key, required this.controller});

  @override
  State<StaffSettingsView> createState() => _StaffSettingsViewState();
}

class _StaffSettingsViewState extends State<StaffSettingsView> {
  bool _soundHapticsEnabled = true;
  String _paperSize = '58mm'; // '58mm' or '80mm'

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: widget.controller.kitchenMode ? Colors.white : AppColors.paperCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Mag-log out?',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        content: Text(
          'Mabubura ang anumang hindi pa nakumpletong order sa cart at babalik sa login screen.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.mutedBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Kanselahin',
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
              Navigator.pop(dialogCtx);
              widget.controller.logout();
            },
            child: Text(
              'Oo, mag-log out',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final isKitchen = controller.kitchenMode;
    final isOwner = controller.role == UserRole.owner;
    final staffName = controller.currentStaffName;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cashier Profile Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      staffName.isNotEmpty ? staffName[0] : 'S',
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staffName,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOwner ? 'May-ari (Owner Mode Active)' : 'Staff Cashier • Terminal #01',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.mutedBrown),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'STAFF',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Settings Group
            Text(
              'MGA KAGUSTUHAN (PREFERENCES)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppColors.mutedBrown,
              ),
            ),
            const SizedBox(height: 10),

            Material(
              color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Kitchen Mode Switch
                  SwitchListTile(
                    title: Text(
                      'Kitchen Mode (Mataas na Contrast)',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                      ),
                    ),
                    subtitle: Text(
                      'Puting background at makakapal na linya para sa maliwanag na kusina.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                    ),
                    value: isKitchen,
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) => controller.toggleKitchenMode(),
                  ),
                  const Divider(color: AppColors.line, height: 1),

                  // Sound & Haptics Toggle
                  SwitchListTile(
                    title: Text(
                      'Tunog at Haptic Feedback',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                      ),
                    ),
                    subtitle: Text(
                      'Tumutunog kapag may idinagdag na ulam o nakumpletong bayad.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                    ),
                    value: _soundHapticsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _soundHapticsEnabled = val),
                  ),
                  const Divider(color: AppColors.line, height: 1),

                  // Thermal Printer Paper Size
                  ListTile(
                    title: Text(
                      'Lapad ng Thermal Receipt',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                      ),
                    ),
                    subtitle: Text(
                      'Pumili ayon sa Bluetooth thermal printer na nakakabit.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                    ),
                    trailing: DropdownButton<String>(
                      value: _paperSize,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: '58mm', child: Text('58mm (Standard)')),
                        DropdownMenuItem(value: '80mm', child: Text('80mm (Wide)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _paperSize = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Strict RBAC Information Notice (Staff View)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFFB78103), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Protektado ang Karinderya Data',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7A5400),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ang mga sumusunod ay eksklusibo sa Owner account:\n• Kabuuang Benta, Tubo, at Gastusin\n• Paglikha o Pagbura ng Staff\n• Pag-edit ng Presyo ng Ulam\n• Pag-backup at Pag-restore ng Data\n• Pag-void ng Order (nangangailangan ng PIN ng May-ari)',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            height: 1.4,
                            color: const Color(0xFF7A5400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // If logged in as Owner, offer switcher
            if (isOwner) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.dashboard_outlined),
                  label: Text(
                    'Lumipat sa Owner Dashboard',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => controller.setScreen(ScreenState.owner),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.chiliRed,
                  side: const BorderSide(color: AppColors.chiliRed, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout),
                label: Text(
                  'Mag-log out',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showLogoutConfirmDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
