import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locker_mobile/core/routes/injection.dart';
import '../../features/wallet/presentation/controllers/wallet_cubit.dart';
import '../../features/wallet/presentation/controllers/wallet_state.dart';
import '../../features/wallet/widgets/wallet_transactions_section.dart';
import '../../features/wallet/data/wallet_repository.dart';
import '../../features/wallet/domain/services/payment_realtime_service.dart';
import '../../features/wallet/domain/usecases/get_wallet_overview_usecase.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/sign_up/presentation/pages/sign_up_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/food_order/presentation/pages/food_order_page.dart';
import '../../features/food_order/presentation/pages/food_cart_payment_page.dart';
import '../../features/wallet/presentation/pages/top_up_page.dart';
import '../../features/menu/presentation/pages/menu_page.dart';
import '../../features/payment_success/domain/entities/payment_success_info.dart';
import '../../features/payment_success/presentation/pages/payment_success_page.dart';
import '../../features/payment_failed/domain/entities/payment_failed_info.dart';
import '../../features/payment_failed/presentation/pages/payment_failed_page.dart';
import '../../features/photo_confirmation/presentation/pages/photo_confirmation_page.dart';
import '../../features/send_success/domain/entities/send_success_info.dart';
import '../../features/send_success/presentation/pages/send_success_page.dart';
import '../../features/send_receive/presentation/pages/send_receive_page.dart';
import '../../features/send_receive/presentation/pages/payment_page.dart';
import '../../features/delivery/presentation/pages/send_receive_page.dart'
    as delivery;
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/wallet/presentation/pages/wallet_transactions_page.dart';
import '../../features/locker/presentation/locker_screen.dart';
import '../../features/locker_detail/presentation/pages/locker_detail_page.dart';
import '../../features/locker_map/presentation/pages/locker_map_page.dart';
import '../../features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import '../../features/qr_scanner/presentation/pages/scan_history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/personal_info/presentation/pages/personal_info_page.dart';
import '../../features/change_password/presentation/pages/change_password_page.dart';
import '../../features/change_password/presentation/pages/forgot_password_page.dart';
import '../../features/change_password/presentation/pages/reset_password_page.dart';
import '../../features/change_password/presentation/controllers/forgot_password_cubit.dart';
import '../../features/feedback/presentation/pages/feedback_page.dart';

// Create a single instance to share between forgot and reset password pages
final _forgotPasswordCubit = getIt<ForgotPasswordCubit>();

class AppRouter {
  static const initialRoute = '/login';

  static Map<String, WidgetBuilder> get routes => {
    '/login': (context) => const LoginPage(),
    '/sign-up': (context) => const SignUpPage(),
    '/home': (context) => const HomePage(),
    '/profile': (context) => const ProfilePage(),
    '/wallet': (context) => const WalletPage(),
    '/wallet/transactions': (context) {
      final walletCubit =
          ModalRoute.of(context)?.settings.arguments as WalletCubit?;
      if (walletCubit != null) return WalletTransactionsPage(cubit: walletCubit);
      // Fallback for deep-link / hot reload — build a fresh cubit so the
      // user can still browse their history.
      final repo = WalletRepository();
      return BlocProvider(
        create: (_) => WalletCubit(
          getWalletOverview: GetWalletOverviewUseCase(repository: repo),
          walletRepository: repo,
          realtimeService: getIt<IPaymentRealtimeService>(),
        )..load(),
        child: const _FallbackTransactionsPage(),
      );
    },
    '/top-up': (context) {
      final walletCubit =
          ModalRoute.of(context)?.settings.arguments as WalletCubit?;
      return walletCubit != null
          ? BlocProvider.value(value: walletCubit, child: const TopUpPage())
          : const TopUpPage(); // Or a fallback/error widget
    },
    '/orders': (context) => const OrdersPage(),
    '/send-receive': (context) => const SendReceivePage(),
    '/delivery': (context) => const delivery.SendReceivePage(),
    '/payment': (context) => PaymentPage(
      orderData:
          (ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?) ??
          {},
    ),
    '/food-order': (context) => const FoodOrderPage(),
    '/food-cart-payment': (context) => EBoxFoodCartPayment(
      initialData:
          ModalRoute.of(context)?.settings.arguments as FoodCartPaymentArgs?,
    ),
    '/payment-success': (context) => PaymentSuccessPage(
      request:
          ModalRoute.of(context)?.settings.arguments as PaymentSuccessRequest?,
    ),
    '/payment-failed': (context) => PaymentFailedPage(
      request:
          ModalRoute.of(context)?.settings.arguments as PaymentFailedRequest?,
    ),
    '/send-success': (context) => SendSuccessPage(
      request:
          ModalRoute.of(context)?.settings.arguments as SendSuccessRequest?,
    ),
    '/photo-confirmation': (context) => PhotoConfirmationPage(
      lockerId: ModalRoute.of(context)?.settings.arguments as String?,
    ),
    '/menu': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      return MenuPage(
        restaurantId: args['restaurantId'] as String?,
        restaurantName: args['restaurantName'] as String?,
      );
    },
    '/lockers': (context) => const LockerScreen(),
    '/locker-map': (context) => const LockerMapPage(),
    '/locker-detail': (context) => LockerDetailPage(
      lockerId: ModalRoute.of(context)!.settings.arguments as String,
    ),
    '/qr-scanner': (context) => const QrScannerPage(),
    '/scan-history': (context) => const ScanHistoryPage(),
    '/settings': (context) => const SettingsPage(),
    '/feedback': (context) => const FeedbackPage(),
    '/notifications': (context) => const NotificationPage(),
    '/personal-info': (context) => const PersonalInfoPage(),
    '/change-password': (context) => const ChangePasswordPage(),
    '/forgot-password': (context) => BlocProvider.value(
      value: _forgotPasswordCubit..resetState(),
      child: const ForgotPasswordPage(),
    ),
    '/reset-password': (context) => BlocProvider.value(
      value: _forgotPasswordCubit,
      child: const ResetPasswordPage(),
    ),
  };
}

/// Renders the transactions list using the nearest BlocProvider — used
/// when the route is opened without an explicit cubit argument (e.g. via
/// deep-link or hot reload).
class _FallbackTransactionsPage extends StatefulWidget {
  const _FallbackTransactionsPage();

  @override
  State<_FallbackTransactionsPage> createState() =>
      _FallbackTransactionsPageState();
}

class _FallbackTransactionsPageState extends State<_FallbackTransactionsPage> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F8),
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Lịch sử giao dịch',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            final transactions = state.overview?.transactions ?? [];
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: WalletTransactionsSection(
                transactions: transactions,
                statusFilter: _statusFilter,
                onStatusFilterChanged: (v) =>
                    setState(() => _statusFilter = v),
                onViewAll: () {},
                onRefresh: () async {
                  await context.read<WalletCubit>().load();
                },
                isLoading: state.isLoading,
              ),
            );
          },
        ),
      ),
    );
  }
}
