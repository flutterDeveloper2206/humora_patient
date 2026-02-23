import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/finish_signup_screen.dart';
import '../features/language/language_selection_screen.dart';
import '../features/expertise/screens/primary_expertise_screen.dart';
import '../features/specialization/specialization_selection_screen.dart';
import '../features/certificates/certificate_selection_screen.dart';
import '../features/documentation/screens/documentation_screen.dart';
import '../features/agreement/screens/agreement_screen.dart';
import '../features/notifications/notification_permission_screen.dart';
import '../features/bank_account/screens/bank_selection_screen.dart';
import '../features/bank_account/screens/bank_details_screen.dart';
import '../features/bank_account/models/bank_model.dart';
import '../features/experience_qualifications/experience_qualifications_screen.dart';
import '../features/certifications/certifications_screen.dart';
import '../features/security_number/security_number_screen.dart';
import '../features/live_counselling/screens/live_counselling_screen.dart';
import '../common/screens/common_success_screen.dart';
import '../features/healing_sessions/screens/healing_sessions_screen.dart';
import '../features/sessions/screens/sessions_screen.dart';
import '../features/welcome/presentation/pages/welcome_page.dart';
import '../features/permissions/presentation/pages/permissions_screen.dart';
import '../features/healing_focus/presentation/pages/healing_focus_screen.dart';
import '../features/healers/presentation/pages/healer_list_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    // initialLocation: '/location-picker',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) =>
            OtpScreen(destination: state.extra as String? ?? ""),
      ),

      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
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
        path: '/certificates',
        builder: (context, state) => const CertificateSelectionScreen(),
      ),
      GoRoute(
        path: '/documentation',
        builder: (context, state) => const DocumentationScreen(),
      ),
      GoRoute(
        path: '/agreement',
        builder: (context, state) => const AgreementScreen(),
      ),
      GoRoute(
        path: '/notification-permission',
        builder: (context, state) => const NotificationPermissionScreen(),
      ),
      GoRoute(
        path: '/bank-selection',
        builder: (context, state) => const BankSelectionScreen(),
      ),
      GoRoute(
        path: '/bank-details',
        builder: (context, state) {
          final bank = state.extra as BankModel;
          return BankDetailsScreen(bank: bank);
        },
      ),
      GoRoute(
        path: '/security-number',
        builder: (context, state) => const SecurityNumberScreen(),
      ),
      GoRoute(
        path: '/experience-qualifications',
        builder: (context, state) => const ExperienceQualificationsScreen(),
      ),
      GoRoute(
        path: '/certifications',
        builder: (context, state) => const CertificationsScreen(),
      ),
      GoRoute(
        path: '/live-counselling',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LiveCounsellingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          opaque: false,
          barrierColor: Colors.black.withOpacity(0.5),
        ),
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
    ],
  );
}
