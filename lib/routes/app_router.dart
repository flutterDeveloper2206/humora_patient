import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/features/auth/screens/reset_password_screen.dart';
import 'package:humora_patient/features/auth/screens/signup_otp_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/finish_signup_screen.dart';
import '../features/language/language_selection_screen.dart';
import '../features/expertise/screens/primary_expertise_screen.dart';
import '../features/specialization/specialization_selection_screen.dart';
import '../features/notifications/notification_permission_screen.dart';
import '../features/security_number/security_number_screen.dart';
import '../common/screens/common_success_screen.dart';
import '../features/healing_sessions/screens/healing_sessions_screen.dart';
import '../features/sessions/screens/sessions_screen.dart';
import '../features/welcome/presentation/pages/welcome_page.dart';
import '../features/permissions/presentation/pages/permissions_screen.dart';
import '../features/healing_focus/presentation/pages/healing_focus_screen.dart';
import '../features/healers/presentation/pages/healer_list_screen.dart';
import '../features/healers/presentation/pages/healer_detail_screen.dart';
import '../features/video_call/presentation/pages/video_call_screen.dart';
import '../features/chat/presentation/pages/chat_screen.dart';
import '../features/voice_call/presentation/pages/voice_call_screen.dart';
import '../features/group_session/presentation/pages/group_session_screen.dart';
import '../features/payment/presentation/pages/payment_method_screen.dart';
import '../features/wallet/presentation/pages/wallet_screen.dart';
import '../features/receipt/presentation/pages/receipt_screen.dart';
import '../features/scheduled_sessions/presentation/pages/scheduled_sessions_screen.dart';
import '../features/live_counselling_session/screens/live_counselling_session_screen.dart';
import '../features/appointment_reminder/presentation/pages/appointment_reminder_screen.dart';
import '../features/home/presentation/pages/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    // initialLocation: '/location-picker',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/appointment-reminder',
        builder: (context, state) => const AppointmentReminderScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) =>
            OtpScreen(destination: state.extra as String? ?? ""),
      ),
      GoRoute(
        path: '/signup-otp',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return SignupOtpScreen(
            mobile: data['mobile'] as String? ?? "",
            countryCode: data['countryCode'] as String? ?? "",
          );
        },
      ), GoRoute(
        path: '/reset-password',
        builder: (context, state) =>
            ResetPasswordScreen(),
      ),


      GoRoute(
        path: '/success',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return CommonSuccessScreen(
            imagePath:
                data?['imagePath'] ?? "assets/images/success_illustration.png",
            icon: data?['icon'] ?? "assets/images/right.png",
            title: data?['title'] ?? "Success!",
            subtitle: data?['subtitle'] ?? "",
            buttonText: data?['buttonText'] ?? "Continue",
            onButtonPressed: data?['onButtonPressed'] as VoidCallback? ?? () {},
          );
        },
      ),
      GoRoute(
        path: '/finish-signup',
        builder: (context, state) => const FinishSignupScreen(),
      ),

      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/primary-expertise',
        builder: (context, state) => const PrimaryExpertiseScreen(),
      ),
      GoRoute(
        path: '/specialization',
        builder: (context, state) => const SpecializationSelectionScreen(),
      ),


      GoRoute(
        path: '/notification-permission',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          final fromSignup = data?['fromSignup'] as bool? ?? false;
          return NotificationPermissionScreen(fromSignup: fromSignup);
        },
      ),

      GoRoute(
        path: '/security-number',
        builder: (context, state) => const SecurityNumberScreen(),
      ),


      GoRoute(
        path: '/healing-sessions',
        builder: (context, state) => const HealingSessionsScreen(),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const SessionsScreen(),
      ),
      GoRoute(
        path: '/permissions',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PermissionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          opaque: false,
          barrierColor: Colors.black.withOpacity(0.5),
        ),
      ),
      GoRoute(
        path: '/healing-focus',
        builder: (context, state) => const HealingFocusScreen(),
      ),
      GoRoute(
        path: '/healers-list',
        builder: (context, state) => const HealerListScreen(),
      ),
      GoRoute(
        path: '/healer-detail/:healerId',
        builder: (context, state) => HealerDetailScreen(
          healerId: state.pathParameters['healerId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/video-call',
        builder: (context, state) => const VideoCallScreen(),
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/voice-call',
        builder: (context, state) => const VoiceCallScreen(),
      ),
      GoRoute(
        path: '/group-session',
        builder: (context, state) => const GroupSessionScreen(),
      ),
      GoRoute(
        path: '/payment-method',
        builder: (context, state) => const PaymentMethodScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/receipt',
        builder: (context, state) => const ReceiptScreen(),
      ),
      GoRoute(
        path: '/scheduled-sessions',
        builder: (context, state) => const ScheduledSessionsScreen(),
      ),
      GoRoute(
        path: '/live-counselling-session',
        builder: (context, state) => const LiveCounsellingSessionScreen(),
      ),
    ],
  );
}
