import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../bloc/wallet_bloc.dart';
import '../../bloc/wallet_event.dart';
import '../../bloc/wallet_state.dart';
import '../widgets/add_money_sheet.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_balance_card.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletBloc()..add(const WalletLoadRequested()),
      child: const WalletView(),
    );
  }
}

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (_scrollController.position.pixels >= max - 120) {
      context.read<WalletBloc>().add(const WalletLoadMoreTransactions());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listenWhen: (prev, curr) =>
          prev.error != curr.error ||
          prev.topUpSuccessMessage != curr.topUpSuccessMessage,
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          CommonFlushbar.error(context, state.error!);
        }
        if (state.topUpSuccessMessage != null) {
          CommonFlushbar.success(context, state.topUpSuccessMessage!);
        }
      },
      builder: (context, state) {
        final symbol = state.balance.displaySymbol;
        final isBusy = state.isLoading && state.transactions.isEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FBFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.black, size: 28.sp),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'My Wallet',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
            actions: [
              IconButton(
                onPressed: state.isLoading
                    ? null
                    : () => context
                        .read<WalletBloc>()
                        .add(const WalletLoadRequested()),
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<WalletBloc>().add(const WalletLoadRequested());
              await context.read<WalletBloc>().stream.firstWhere(
                    (s) => !s.isLoading,
                  );
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                SliverToBoxAdapter(
                  child: isBusy
                      ? const _WalletBalanceCardSkeleton()
                      : WalletBalanceCard(
                          balance: state.balance,
                          isLoading: false,
                        ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _AddMoneyButton(
                      isLoading: state.isTopUpInProgress ||
                          state.isRefreshingAfterPayment,
                      onTap: () => AddMoneySheet.show(context, symbol),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 28.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction history',
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                        if (state.totalCount > 0)
                          Text(
                            '${state.transactions.length} of ${state.totalCount}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                if (isBusy)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => AutoSkeleton(
                          enabled: true,
                          child: Container(
                            height: 72.h,
                            margin: EdgeInsets.only(bottom: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                        childCount: 5,
                      ),
                    ),
                  )
                else if (state.transactions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyTransactions(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.transactions.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return TransactionTile(
                            item: state.transactions[index],
                            index: index,
                          );
                        },
                        childCount: state.transactions.length +
                            (state.isLoadingMore ? 1 : 0),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AddMoneyButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _AddMoneyButton({required this.onTap, required this.isLoading});

  @override
  State<_AddMoneyButton> createState() => _AddMoneyButtonState();
}

class _AddMoneyButtonState extends State<_AddMoneyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
    )..value = 1.0;
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            color: AppColors.darkButton,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkButton.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else ...[
                Icon(Icons.add_circle_outline, color: Colors.white, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  'Add money',
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48.sp,
            color: AppColors.textHint,
          ),
          SizedBox(height: 12.h),
          Text(
            'No transactions yet',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Top up your wallet to get started',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBalanceCardSkeleton extends StatelessWidget {
  const _WalletBalanceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: AspectRatio(
        aspectRatio: 1.586,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 90.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.wifi, color: AppColors.surface, size: 22.sp),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 140.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: 220.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    Container(
                      width: 80.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(
                      width: 36.w,
                      height: 24.h,
                      child: Icon(Icons.circle, color: AppColors.surface),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
