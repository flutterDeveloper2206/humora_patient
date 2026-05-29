import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:humora_patient/features/wallet/data/models/wallet_models.dart';

class WalletBalanceCard extends StatefulWidget {
  final WalletBalanceResponse balance;
  final bool isLoading;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.isLoading,
  });

  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard>
    with SingleTickerProviderStateMixin {
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  late Ticker _smoothTicker;

  double _targetRotateX = 0;
  double _targetRotateY = 0;
  double _rotateX = 0;
  double _rotateY = 0;

  static const double _sensitivity = 0.013;
  static const double _maxTilt = 0.16;
  static const double _lerp = 0.14;

  @override
  void initState() {
    super.initState();
    _smoothTicker = createTicker(_onTick)..start();
    _accelerometerSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onAccelerometer);
  }

  void _onAccelerometer(AccelerometerEvent event) {
    if (widget.isLoading) {
      _targetRotateX = 0;
      _targetRotateY = 0;
      return;
    }
    // Portrait hold: x = left/right tilt, y = forward/back tilt
    _targetRotateY =
        (event.x * _sensitivity).clamp(-_maxTilt, _maxTilt);
    _targetRotateX =
        (-event.y * _sensitivity).clamp(-_maxTilt, _maxTilt);
  }

  void _onTick(Duration elapsed) {
    final nextX = _rotateX + (_targetRotateX - _rotateX) * _lerp;
    final nextY = _rotateY + (_targetRotateY - _rotateY) * _lerp;

    if ((nextX - _rotateX).abs() < 0.0001 && (nextY - _rotateY).abs() < 0.0001) {
      return;
    }

    setState(() {
      _rotateX = nextX;
      _rotateY = nextY;
    });
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    _smoothTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = widget.balance.displaySymbol;
    final available = widget.balance.availableBalance;
    final whole = available.truncate();
    final fraction =
        ((available - whole) * 100).round().toString().padLeft(2, '0');

    final offsetX = _rotateY * 22;
    final offsetY = _rotateX * 14;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Transform.translate(
        offset: Offset(offsetX, offsetY),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateX(widget.isLoading ? 0 : _rotateX)
            ..rotateY(widget.isLoading ? 0 : _rotateY),
          child: AspectRatio(
            aspectRatio: 1.586,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CardBackground(isLoading: widget.isLoading),
                  Padding(
                    padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HUMORA',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                fontSize: 13.sp,
                              ),
                            ),
                            Row(
                              children: [
                                const _ChipIcon(),
                                SizedBox(width: 10.w),
                                Icon(
                                  Icons.wifi,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  size: 22.sp,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'AVAILABLE BALANCE',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 1.2,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              symbol,
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              widget.isLoading ? '••••' : _formatWhole(whole),
                              style: AppTextStyles.h1.copyWith(
                                color: Colors.white,
                                fontSize: 36.sp,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (!widget.isLoading) ...[
                              Padding(
                                padding: EdgeInsets.only(bottom: 5.h),
                                child: Text(
                                  '.$fraction',
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CARD HOLDER',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 9.sp,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'MY WALLET',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'CURRENCY',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 9.sp,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  (widget.balance.currencyName ?? 'WALLET')
                                      .toUpperCase(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                            const _CardBrandMark(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatWhole(int whole) {
    final s = whole.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _CardBackground extends StatelessWidget {
  final bool isLoading;

  const _CardBackground({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLoading
              ? [const Color(0xFF3A3A3A), const Color(0xFF2A2A2A)]
              : [
                  const Color(0xFF1A1A2E),
                  const Color(0xFFE81848),
                  const Color(0xFFFF6B8A),
                ],
          stops: isLoading ? null : const [0.0, 0.45, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40.h,
            right: -30.w,
            child: _DecorCircle(
              size: 140.w,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: -50.h,
            left: -40.w,
            child: _DecorCircle(
              size: 160.w,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            top: 60.h,
            right: 40.w,
            child: _DecorCircle(
              size: 60.w,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  const _ChipIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 28.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (_) => Container(
            height: 1.2,
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            color: Colors.brown.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _CardBrandMark extends StatelessWidget {
  const _CardBrandMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36.w,
      height: 24.h,
      child: const Stack(
        children: [
          Positioned(left: 0, child: _BrandCircle(color: Color(0xFFEB001B))),
          Positioned(left: 14, child: _BrandCircle(color: Color(0xFFF79E1B))),
        ],
      ),
    );
  }
}

class _BrandCircle extends StatelessWidget {
  final Color color;

  const _BrandCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
    );
  }
}
