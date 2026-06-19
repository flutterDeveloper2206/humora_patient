import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:humora_patient/features/auth/presentation/pages/signup_otp_screen.dart';
import '../features/splash/presentation/pages/splash_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/otp_screen.dart';
import '../features/auth/presentation/pages/finish_signup_screen.dart';
import '../features/language/presentation/pages/language_selection_screen.dart';
import '../features/expertise/presentation/pages/primary_expertise_screen.dart';
import '../features/specialization/presentation/pages/specialization_selection_screen.dart';
import '../features/notifications/presentation/pages/notification_permission_screen.dart';
import '../features/notifications/presentation/pages/notification_inbox_screen.dart';
import '../features/security_number/presentation/pages/security_number_screen.dart';
import '../common/screens/common_success_screen.dart';
import '../features/healing_sessions/presentation/pages/healing_sessions_screen.dart';
import '../features/sessions/presentation/pages/sessions_screen.dart';
import '../features/welcome/presentation/pages/welcome_page.dart';
import '../features/permissions/presentation/pages/permissions_screen.dart';
import '../features/healing_focus/presentation/pages/healing_focus_screen.dart';
import '../features/healers/presentation/pages/healer_list_screen.dart';
import '../features/healers/presentation/pages/healer_detail_screen.dart';
import '../features/agora/presentation/models/call_route_args.dart';
import '../features/agora/presentation/widgets/call_missing_args_screen.dart';
import '../features/video_call/presentation/pages/video_call_screen.dart';
import '../features/chat/presentation/models/chat_session_args.dart';
import '../features/chat/presentation/pages/chat_session_page.dart';
import '../features/chat/presentation/pages/chat_screen.dart';
import '../features/voice_call/presentation/pages/voice_call_screen.dart';
import '../features/group_session/presentation/pages/group_session_screen.dart';
import '../features/payment/presentation/pages/payment_method_screen.dart';
import '../features/wallet/presentation/pages/wallet_screen.dart';
import '../features/receipt/presentation/pages/receipt_screen.dart';
import '../features/receipt/presentation/models/receipt_args.dart';
import '../features/scheduled_sessions/presentation/pages/scheduled_sessions_screen.dart';
import '../features/live_counselling_session/presentation/pages/live_counselling_session_screen.dart';
import '../features/live_consultation/presentation/models/live_consultation_args.dart';
import '../features/live_consultation/presentation/pages/live_history_screen.dart';
import '../features/live_consultation/presentation/pages/live_request_waiting_screen.dart';
import '../features/live_consultation/presentation/pages/live_session_summary_screen.dart';
import '../features/live_consultation/data/models/live_models.dart';
import '../features/my_sessions/presentation/pages/my_sessions_screen.dart';
import '../features/my_sessions/presentation/pages/my_session_detail_screen.dart';
import '../features/appointment_reminder/presentation/pages/appointment_reminder_screen.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/home/presentation/pages/edit_profile_screen.dart';
import '../features/home/data/models/user_profile_model.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    // initialLocation: '/location-picker',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => EditProfileScreen(
          initialProfile: state.extra as UserProfileModel?,
        ),
      ),
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
        path: '/notifications',
        builder: (context, state) => const NotificationInboxScreen(),
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
        builder: (context, state) {
          final args = state.extra as CallRouteArgs?;
          if (args == null) {
            return const CallMissingArgsScreen(title: 'Video call unavailable');
          }
          return VideoCallScreen(args: args);
        },
      ),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(
        path: '/chat/with/:otherPartyUserId',
        builder: (context, state) {
          final otherPartyUserId =
              state.pathParameters['otherPartyUserId'] ?? '';
          final args = state.extra as ChatSessionArgs?;
          return ChatSessionPage(
            bookingId: '',
            args: args?.copyWith(
              otherPartyUserId: otherPartyUserId,
              bookingId: '',
            ) ??
                ChatSessionArgs(otherPartyUserId: otherPartyUserId),
          );
        },
      ),
      GoRoute(
        path: '/chat/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final args = state.extra as ChatSessionArgs?;
          return ChatSessionPage(
            bookingId: bookingId,
            args: args,
          );
        },
      ),
      GoRoute(
        path: '/voice-call',
        builder: (context, state) {
          final args = state.extra as CallRouteArgs?;
          if (args == null) {
            return const CallMissingArgsScreen(title: 'Voice call unavailable');
          }
          return VoiceCallScreen(args: args);
        },
      ),
      GoRoute(
        path: '/group-session',
        builder: (context, state) {
          final args = state.extra as CallRouteArgs?;
          if (args == null) {
            return const CallMissingArgsScreen(
              title: 'Group session unavailable',
            );
          }
          return GroupSessionScreen(args: args);
        },
      ),
      GoRoute(
        path: '/payment-method',
        builder: (context, state) => const PaymentMethodScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) {
          final openTopUp = state.uri.queryParameters['topUp'] == 'true';
          return WalletScreen(openTopUpOnLoad: openTopUp);
        },
      ),
      GoRoute(
        path: '/receipt',
        builder: (context, state) => ReceiptScreen(
          args: state.extra as ReceiptArgs?,
        ),
      ),
      GoRoute(
        path: '/scheduled-sessions',
        builder: (context, state) => const ScheduledSessionsScreen(),
      ),
      GoRoute(
        path: '/my-sessions',
        builder: (context, state) => const MySessionsScreen(),
      ),
      GoRoute(
        path: '/my-session/:bookingId',
        builder: (context, state) => MySessionDetailScreen(
          bookingId: state.pathParameters['bookingId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/live-counselling-session',
        builder: (context, state) => LiveCounsellingSessionScreen(
          consultationArgs: state.extra as LiveConsultationArgs?,
        ),
      ),
      GoRoute(
        path: '/live-request-waiting',
        builder: (context, state) {
          final args = state.extra as LiveConsultationArgs?;
          if (args == null) {
            return const Scaffold(
              body: Center(child: Text('Live request details missing')),
            );
          }
          return LiveRequestWaitingScreen(args: args);
        },
      ),
      GoRoute(
        path: '/live-session-summary',
        builder: (context, state) {
          final summary = state.extra as SessionEndedSummary?;
          if (summary == null) {
            return const Scaffold(
              body: Center(child: Text('Session summary unavailable')),
            );
          }
          return LiveSessionSummaryScreen(summary: summary);
        },
      ),
      GoRoute(
        path: '/live-history',
        builder: (context, state) => const LiveHistoryScreen(),
      ),
    ],
  );
}
