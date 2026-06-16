import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../common/utils/safe_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/datasource/live_api_service.dart';

class LiveHistoryScreen extends StatefulWidget {
  const LiveHistoryScreen({super.key});

  @override
  State<LiveHistoryScreen> createState() => _LiveHistoryScreenState();
}

class _LiveHistoryScreenState extends State<LiveHistoryScreen> {
  final LiveApiService _api = LiveApiService();
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.getHistory();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    try {
      return DateFormat('MMM d, yyyy · h:mm a')
          .format(DateTime.parse(value.toString()).toLocal());
    } catch (_) {
      return value.toString();
    }
  }

  String _consultationLabel(int type) => switch (type) {
        0 => 'Chat',
        1 => 'Audio',
        2 => 'Video',
        _ => 'Session',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 28.sp),
          onPressed: () => safePop(context),
        ),
        title: Text(
          'Live session history',
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(32.w),
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppColors.textHint),
          SizedBox(height: 16.h),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          Center(
            child: TextButton(
              onPressed: _load,
              child: Text(
                'Retry',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(32.w),
        children: [
          SizedBox(height: 80.h),
          Icon(Icons.history, size: 56.sp, color: AppColors.textHint),
          SizedBox(height: 16.h),
          Text(
            'No live sessions yet',
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'On-demand live consultations will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      itemCount: _items.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = _items[index];
        final type = (item['consultationType'] as num?)?.toInt() ?? 0;
        final healerName =
            item['healerName']?.toString() ?? item['otherPartyName']?.toString() ?? 'Healer';
        final amount = (item['totalAmountCharged'] as num?)?.toDouble() ?? 0;
        final minutes = (item['billedMinutes'] as num?)?.toInt() ?? 0;
        final endedAt = item['endedAt'] ?? item['startedAt'];

        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      healerName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLite,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _consultationLabel(type),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                _formatDate(endedAt),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '$minutes min · ₹${amount.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
