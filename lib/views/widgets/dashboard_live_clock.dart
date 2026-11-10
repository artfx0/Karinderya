import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Prominent real-time digital clock rendered inside the Owner Dashboard body.
/// Strictly displays hours and minutes (e.g., 10:45 AM) in Philippine Standard Time,
/// excluding any date or location text.
class DashboardLiveClock extends StatefulWidget {
  final bool isKitchen;

  const DashboardLiveClock({super.key, this.isKitchen = false});

  @override
  State<DashboardLiveClock> createState() => _DashboardLiveClockState();
}

class _DashboardLiveClockState extends State<DashboardLiveClock> {
  late Timer _timer;
  late DateTime _currentPst;

  @override
  void initState() {
    super.initState();
    _currentPst = _nowInPst();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentPst = _nowInPst();
        });
      }
    });
  }

  DateTime _nowInPst() {
    return DateTime.now().toUtc().add(const Duration(hours: 8));
  }

  String _formatHourMinute(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKitchen = widget.isKitchen;
    final timeString = _formatHourMinute(_currentPst);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isKitchen ? AppColors.kitchenSurface : AppColors.paperCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isKitchen ? AppColors.kitchenBorder : AppColors.line,
          width: isKitchen ? 2 : 1,
        ),
        boxShadow: isKitchen
            ? null
            : [
                BoxShadow(
                  color: AppColors.darkBrown.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.leafGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.leafGreen,
                ),
              ),
            ],
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                timeString,
                style: GoogleFonts.fredoka(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isKitchen ? AppColors.kitchenText : AppColors.darkBrown,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
