import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import 'common_image.dart';

class SwipeableButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;
  final String buttonText;
  final double animationWidth;
  final String? iconPath;
  final Color backgroundColor;
  final Color textColor;
  final bool isShowIcon;
  final Duration loadingDuration;

  const SwipeableButton({
    super.key,
    required this.onSwipeComplete,
    required this.buttonText,
    required this.animationWidth,
    this.iconPath,
    this.isShowIcon=false,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.loadingDuration = const Duration(milliseconds: 2000),
  });

  @override
  State<SwipeableButton> createState() => _SwipeableButtonState();
}

class _SwipeableButtonState extends State<SwipeableButton>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _loadingController;
  double _slidePosition = 0;
  bool _isLoading = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: widget.loadingDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {

    _slideController.dispose();
    _loadingController.dispose();

    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isCompleted) return;

    setState(() {
      _slidePosition += details.delta.dx;
      _slidePosition = _slidePosition.clamp(0.0, widget.animationWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isCompleted) return;

     var threshold = widget.animationWidth;
    const minVelocity = 500.0;

    final velocityCheck = details.velocity.pixelsPerSecond.dx > minVelocity;
    final positionCheck = _slidePosition > threshold * 0.7;

    if (velocityCheck || positionCheck) {
      _completeSlide();
    } else {
      _resetSlide();
    }
  }

  void _completeSlide() {
    setState(() {
      _slidePosition = widget.animationWidth;
      _isLoading = true;
      _isCompleted = true;
    });

    _loadingController.forward().then((_) {
      _isLoading = false;
      _isCompleted = false;

      _slidePosition = 0;
      _resetSlide();
      _slideController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _loadingController = AnimationController(
        duration: widget.loadingDuration,
        vsync: this,
      );
      widget.onSwipeComplete();
    });
  }



  void _resetSlide() {
    _slideController.forward(from: 0.0).then((_) {
      setState(() {
        _slidePosition = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFDE8ED),
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background loading indicator
            if (_isLoading)
              ScaleTransition(
                scale: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: _loadingController, curve: Curves.easeOut),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),

            // Center content
            if (!_isLoading)
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(widget.isShowIcon)
                  CommonImage(
                    path:
                    'assets/image/material-symbols_menstrual-health-rounded.png',
                    height: 16.h,
                    width: 16.h,
                    color: AppColors.white,
                  ),
                  if(widget.isShowIcon)

                  SizedBox(width: 8.w),
                  Text(
                    widget.buttonText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: widget.textColor,
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              ),

            // Leading sliding arrow/icon
            Positioned(
              left: 4.w + _slidePosition,
              child: AnimatedOpacity(
                opacity: _isLoading ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: widget.iconPath != null
                    ? CommonImage(
                  path: widget.iconPath!,
                  height: 48.w,
                  width: 48.w,
                )
                    : Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
