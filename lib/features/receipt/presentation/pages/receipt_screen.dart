import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/receipt_bloc.dart';
import '../bloc/receipt_event.dart';
import '../bloc/receipt_state.dart';
import '../models/receipt_args.dart';
import '../widgets/receipt_card.dart';

class ReceiptScreen extends StatelessWidget {
  final ReceiptArgs? args;

  const ReceiptScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReceiptBloc()..add(LoadReceipt(args: args)),
      child: const ReceiptView(),
    );
  }
}

class ReceiptView extends StatefulWidget {
  const ReceiptView({super.key});

  @override
  State<ReceiptView> createState() => _ReceiptViewState();
}

class _ReceiptViewState extends State<ReceiptView> {
  final GlobalKey _receiptCaptureKey = GlobalKey();
  bool _isDownloading = false;

  Future<void> _downloadReceipt(ReceiptState state) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final boundary =
          _receiptCaptureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Receipt view is not ready yet.');
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to render receipt image.');
      }
      final bytes = byteData.buffer.asUint8List();
      final file = await _saveToLocalFile(bytes, state.receiptId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt downloaded: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<File> _saveToLocalFile(Uint8List bytes, String receiptId) async {
    final filename = _safeReceiptFilename(receiptId);
    final downloadsDir = await getDownloadsDirectory();
    final directory =
        downloadsDir ??
        await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    return file.writeAsBytes(bytes, flush: true);
  }

  String _safeReceiptFilename(String receiptId) {
    final cleaned = receiptId
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return 'receipt_${cleaned.isEmpty ? DateTime.now().millisecondsSinceEpoch : cleaned}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: 25.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'E-Receipt',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<ReceiptBloc, ReceiptState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 10.h,
                  ),
                  child: RepaintBoundary(
                    key: _receiptCaptureKey,
                    child: ReceiptCard(
                      healerName: state.healerName,
                      healerRole: state.healerRole,
                      healerImage: state.healerImage,
                      startTime: state.startTime,
                      endTime: state.endTime,
                      duration: state.duration,
                      date: state.date,
                      mode: state.mode,
                      healingType: state.healingType,
                      sessionType: state.sessionType,
                      totalAmount: state.totalAmount,
                      receiptId: state.receiptId,
                    ),
                  ),
                ),
              ),
              _buildBottomButtons(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, ReceiptState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isDownloading ? null : () => _downloadReceipt(state),
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _isDownloading ? 'Downloading...' : 'Download',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(
    '/success',
    extra: {
    'imagePath': 'assets/image/paid.png',
    'icon': 'assets/images/right.png',
    'title': "Thank You!",
      'buttonText': "Got it!",

      'subtitle': "Your session payment has been\ncompleted successfully. We look\nforward to serving you.",
    'onButtonPressed': () => context.go('/home')
                ,
    },),
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Text(
                    'Continue',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
