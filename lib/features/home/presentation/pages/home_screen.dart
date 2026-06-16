import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/chat/presentation/bloc/chat_inbox_bloc.dart';
import 'package:humora_patient/features/chat/presentation/bloc/chat_inbox_event.dart';
import 'package:humora_patient/features/chat/presentation/pages/chat_screen.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import 'package:humora_patient/features/home/presentation/bloc/home_bloc.dart';
import 'package:humora_patient/features/home/presentation/bloc/home_event.dart';
import 'package:humora_patient/features/home/presentation/bloc/home_state.dart';
import 'package:humora_patient/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:humora_patient/features/home/presentation/widgets/home_profile_tab.dart';
import 'package:humora_patient/features/home/presentation/widgets/home_tab_body.dart';
import 'package:humora_patient/features/live_consultation/data/datasource/live_hub_service.dart';
import 'package:humora_patient/core/utils/session_manager.dart';
import 'package:humora_patient/features/my_sessions/presentation/bloc/my_sessions_bloc.dart';
import 'package:humora_patient/features/my_sessions/presentation/bloc/my_sessions_event.dart';
import 'package:humora_patient/features/my_sessions/presentation/bloc/my_sessions_state.dart';
import 'package:humora_patient/features/my_sessions/presentation/pages/my_sessions_screen.dart';
import 'package:humora_patient/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:humora_patient/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:humora_patient/features/wallet/presentation/pages/wallet_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()..add(FetchHomeData())),
        BlocProvider(create: (_) => MySessionsBloc()),
        BlocProvider(create: (_) => WalletBloc()),
        BlocProvider(create: (_) => ChatInboxBloc()),
      ],
      child: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _currentIndex = 0;
  bool _walletRequested = false;
  bool _chatRequested = false;
  StreamSubscription<dynamic>? _liveStatusSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectLiveHub());
  }

  Future<void> _connectLiveHub() async {
    final token = await SessionManager.getToken();
    if (token == null || token.trim().isEmpty) {
      developer.log(
        'Home → skip live hub — no auth token yet',
        name: 'HomeScreen',
      );
      return;
    }

    // Let the session/token settle after navigation from login/splash.
    await Future.delayed(const Duration(milliseconds: 350));

    try {
      await LiveHubService.instance.connect();
      developer.log(
        'Home → live hub ready: '
        '${LiveHubService.connectionLabel(LiveHubService.instance.state)}',
        name: 'HomeScreen',
      );
      await _liveStatusSub?.cancel();
      _liveStatusSub =
          LiveHubService.instance.healerStatusChanged.listen((payload) {
        if (!mounted) return;
        context.read<HomeBloc>().add(
              UpdateHealerLiveStatus(
                healerId: payload.healerId,
                liveStatus: payload.newStatus,
              ),
            );
      });
    } catch (e) {
      developer.log(
        '❌ Home → live hub connect failed: $e',
        name: 'HomeScreen',
      );
      // Hub optional on home — healers still show REST liveStatus.
    }
  }

  @override
  void dispose() {
    _liveStatusSub?.cancel();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      final bloc = context.read<MySessionsBloc>();
      if (bloc.state is MySessionsInitial) {
        bloc.add(const LoadMySessions());
      }
    }
    if (index == 2 && !_walletRequested) {
      _walletRequested = true;
      context.read<WalletBloc>().add(const WalletLoadRequested());
    }
    if (index == 3 && !_chatRequested) {
      _chatRequested = true;
      context.read<ChatInboxBloc>().add(const LoadChatInbox());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeError) {
                      return Center(child: Text(state.message));
                    }
                    final isLoading =
                        state is HomeLoading || state is HomeInitial;
                    final continueHealing = (state is HomeLoaded)
                        ? state.continueHealingHealers
                        : List.generate(3, (_) => HealerModel.dummy());
                    final available = (state is HomeLoaded)
                        ? state.availableHealers
                        : List.generate(4, (_) => HealerModel.dummy());
                    return HomeTabBody(
                      isLoading: isLoading,
                      continueHealing: continueHealing,
                      available: available,
                    );
                  },
                ),
                const MySessionsView(embedded: true),
                const WalletView(embedded: true),
                const ChatView(embedded: true),
                const HomeProfileTab(),
              ],
            ),
          ),
          HomeBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
          ),
        ],
      ),
    );
  }
}
