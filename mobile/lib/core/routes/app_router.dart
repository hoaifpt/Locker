import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locker_mobile/core/routes/injection.dart';
import '../../features/wallet/presentation/controllers/wallet_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/sign_up/presentation/pages/sign_up_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/food_order/presentation/pages/food_order_page.dart';
import '../../features/food_order/presentation/pages/food_cart_payment_page.dart';
import '../../features/wallet/presentation/pages/top_up_page.dart';
import '../../features/menu/presentation/pages/menu_page.dart';
import '../../features/payment_success/domain/entities/payment_success_info.dart';
import '../../features/payment_failed/domain/entities/payment_failed_info.dart';
import '../../features/payment_result/domain/entities/payment_result.dart';
import '../../features/payment_result/presentation/pages/payment_result_page.dart';
import '../../features/photo_confirmation/presentation/pages/photo_confirmation_page.dart';
import '../../features/send_success/domain/entities/send_success_info.dart';
import '../../features/send_success/presentation/pages/send_success_page.dart';
import '../../features/send_receive/presentation/pages/send_receive_page.dart';
import '../../features/send_receive/presentation/pages/payment_page.dart';
import '../../features/delivery/presentation/pages/send_receive_page.dart'
    as delivery;
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/locker/presentation/locker_screen.dart';
import '../../features/locker_detail/presentation/pages/locker_detail_page.dart';
import '../../features/locker_map/presentation/pages/locker_map_page.dart';
import '../../features/qr_scanner/presentation/pages/qr_scanner_page.dart';
import '../../features/qr_scanner/presentation/pages/scan_history_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/security_privacy/presentation/pages/security_privacy_page.dart';
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
    '/payment-success': (context) {
      final request =
          ModalRoute.of(context)?.settings.arguments as PaymentSuccessRequest?;
      return PaymentResultPage(
        request: PaymentResultRequest(
          status: PaymentResultStatus.success,
          amount: request?.paidAmount ?? 0,
          referenceCode:
              request?.transactionId ??
              request?.orderCode ??
              'Không có mã giao dịch',
          orderCode: request?.orderCode,
          paymentMethod: request?.paymentMethod,
          lockerHub: request?.lockerHub,
        ),
      );
    },
    '/payment-failed': (context) {
      final request =
          ModalRoute.of(context)?.settings.arguments as PaymentFailedRequest?;
      return PaymentResultPage(
        request: PaymentResultRequest(
          status: PaymentResultStatus.failed,
          amount: request?.amount ?? 0,
          referenceCode: request?.referenceCode ?? 'Chưa tạo mã giao dịch',
          paymentMethod: request?.paymentMethod,
          lockerHub: request?.lockerHub,
          message: request?.reason,
        ),
      );
    },
    '/payment-cancelled': (context) => PaymentResultPage(
      request: _paymentResultRequest(
        context,
        fallbackStatus: PaymentResultStatus.cancelled,
      ),
    ),
    '/payment-expired': (context) => PaymentResultPage(
      request: _paymentResultRequest(
        context,
        fallbackStatus: PaymentResultStatus.expired,
      ),
    ),
    '/payment-pending': (context) => PaymentResultPage(
      request: _paymentResultRequest(
        context,
        fallbackStatus: PaymentResultStatus.pending,
      ),
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
    '/security-privacy': (context) => const SecurityPrivacyPage(),
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

  static PaymentResultRequest _paymentResultRequest(
    BuildContext context, {
    required PaymentResultStatus fallbackStatus,
  }) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is PaymentResultRequest) return arguments;

    return PaymentResultRequest(
      status: fallbackStatus,
      amount: 0,
      referenceCode: 'Chưa có mã giao dịch',
    );
  }
}
