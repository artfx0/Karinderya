import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/karinderya_controller.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class AccountTabView extends StatelessWidget {
  final KarinderyaController controller;

  const AccountTabView({super.key, required this.controller});

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: controller.kitchenMode ? Colors.white : AppColors.paperCard,
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
              controller.logout();
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
    final isKitchen = controller.kitchenMode;
    final isOwner = controller.role == UserRole.owner;
    final name = isOwner ? 'Aling Nena' : 'Ana Reyes';
    final roleTag = isOwner ? 'May-ari (Owner)' : 'Staff Cashier';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          children: [
            // Profile Card
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
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      isOwner ? 'AN' : 'AR',
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      roleTag,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings Section
            Container(
              decoration: BoxDecoration(
                color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
                  width: isKitchen ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Kitchen Mode Switch Tile
                  SwitchListTile(
                    title: Text(
                      'Kitchen Mode (Mataas na Contrast)',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                      ),
                    ),
                    subtitle: Text(
                      'Puting background, mas makakapal na borders para sa maliwanag na sikat ng araw at masebong mga daliri.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                    ),
                    value: isKitchen,
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) => controller.toggleKitchenMode(),
                  ),

                  // If user is Owner, allow switching to Owner dashboard
                  if (isOwner) ...[
                    const Divider(color: AppColors.line, height: 1),
                    ListTile(
                      leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary),
                      title: Text(
                        'Lumipat sa Owner Dashboard',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      subtitle: Text(
                        'Tingnan ang Sales, Menu Setup, at Utang Settlement.',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedBrown),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
                      onTap: () => controller.setScreen(ScreenState.owner),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.chiliRed,
                  side: const BorderSide(color: AppColors.chiliRed, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                icon: const Icon(Icons.logout),
                label: Text(
                  'Mag-log out',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
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
