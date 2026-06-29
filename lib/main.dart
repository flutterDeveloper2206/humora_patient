import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'core/constants/stripe_config.dart';
import 'core/layout/app_layout.dart';
import 'core/theme/app_theme.dart';
import 'core/network/app_hub_lifecycle.dart';
import 'core/network/connectivity_service.dart';
import 'core/network/signalr_logging.dart';
import 'core/incoming_call/callkit_incoming_service.dart';
import 'core/notifications/firebase_background_handler.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/session_reminder_coordinator.dart';
import 'features/incoming_call/presentation/coordinators/incoming_call_coordinator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'package:flutter/services.dart';
import 'dart:ui';

bool _isBenignDebugAssertion(Object error) {
  if (error is! AssertionError) return false;
  final message = error.toString();
  return message.contains('_pressedKeys.containsKey') ||
      message.contains('_idToSocketStatistic');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.init();
    await CallKitIncomingService.instance.init();
  }

  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.urlScheme = StripeConfig.urlScheme;
  await Stripe.instance.applySettings();

  ConnectivityService.instance.bindNavigatorKey(AppRouter.rootNavigatorKey);
  await ConnectivityService.instance.init();
  SignalRLogging.init(enabled: kDebugMode);
  // Intercept the low-level keyevent message channel to catch and suppress the framework desync assertion error
  SystemChannels.keyEvent.setMessageHandler((dynamic message) async {
    try {
      return await ServicesBinding.instance.keyEventManager.handleRawKeyMessage(message);
    } catch (e) {
      if (_isBenignDebugAssertion(e)) {
        return {'handled': true};
      }
      rethrow;
    }
  });

  // Suppress Flutter framework's keyboard state desync assertion bug globally
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;
    if (_isBenignDebugAssertion(exception)) {
      return;
    }
    originalOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (_isBenignDebugAssertion(error)) {
      return true;
    }
    return false;
  };

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AuthBloc())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Based on standard iPhone design
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AutoSkeletonConfig(
          data: const AutoSkeletonConfigData(
            baseColor: Color(0xFFE0E0E0),
            highlightColor: Color(0xFFF5F5F5),
          ),
          child: AppHubLifecycle(
            child: MaterialApp.router(
              title: 'Humora Patient',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              routerConfig: AppRouter.router,
              builder: (context, child) {
                return ListenableBuilder(
                  listenable: AppRouter.router.routeInformationProvider,
                  builder: (context, _) {
                    final routePath = AppRouter
                        .router.routeInformationProvider.value.uri.path;
                    final fullBleed = AppLayout.isFullBleedRoute(routePath);
                    final isHome = AppLayout.isHomeRoute(routePath);

                    final scaled = MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: AppLayout.clampTextScaler(
                          MediaQuery.textScalerOf(context),
                        ),
                      ),
                      child: child ?? const SizedBox.shrink(),
                    );

                    if (fullBleed || isHome) {
                      return IncomingCallCoordinator(
                        child: SessionReminderCoordinator(child: scaled),
                      );
                    }

                    return IncomingCallCoordinator(
                      child: SessionReminderCoordinator(
                        child: scaled
                        // SafeArea(
                        //   top: true,
                        //   bottom: !isHome,
                        //   left: true,
                        //   right: true,
                        //   child: scaled,
                        // ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
