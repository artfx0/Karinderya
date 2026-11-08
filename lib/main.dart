import 'package:flutter/material.dart';
import 'controllers/karinderya_controller.dart';
import 'models/app_state.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_view.dart';
import 'views/owner/owner_dashboard_view.dart';
import 'views/payment/cash_payment_view.dart';
import 'views/splash/splash_view.dart';
import 'views/staff/staff_dashboard_view.dart';
import 'views/success/success_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KarinderyaApp());
}

class KarinderyaApp extends StatefulWidget {
  const KarinderyaApp({super.key});

  @override
  State<KarinderyaApp> createState() => _KarinderyaAppState();
}

class _KarinderyaAppState extends State<KarinderyaApp> {
  late final KarinderyaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = KarinderyaController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Karinderya',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(kitchenMode: _controller.kitchenMode),
          home: _buildCurrentScreen(),
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
    switch (_controller.screen) {
      case ScreenState.splash:
        return SplashView(controller: _controller);
      case ScreenState.login:
        return LoginView(controller: _controller);
      case ScreenState.staff:
        return StaffDashboardView(controller: _controller);
      case ScreenState.owner:
        return OwnerDashboardView(controller: _controller);
      case ScreenState.cashPayment:
        return CashPaymentView(controller: _controller);
      case ScreenState.success:
        return SuccessView(controller: _controller);
    }
  }
}
