import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/healer_bloc.dart';
import '../bloc/healer_event.dart';
import '../bloc/healer_state.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import '../widgets/healer_card.dart';

class HealerListScreen extends StatelessWidget {
  const HealerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HealerBloc()..add(FetchHealersRequested()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 18.sp,
                ),
              ),
              title: Text("Healers List", style: AppTextStyles.titleMedium),
              centerTitle: false,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(0.5.h),
                child: Container(color: AppColors.divider, height: 0.5.h),
              ),
            ),
            body: Column(
              children: [
                // Search and Filter Bar
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: "Search here...",
                              hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textHint,
                                fontSize: 14.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                                size: 20.sp,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty || value.length >= 3) {
                                context.read<HealerBloc>().add(
                                  SearchHealersRequested(value),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      CommonImage(
                        path: 'assets/image/filter.png',
                        height: 30.h,
                        width: 30.h,
                      ),
                    ],
                  ),
                ),

                // Statistics and Sorting
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: BlocBuilder<HealerBloc, HealerState>(
                    builder: (context, state) {
                      int count = 0;
                      if (state is HealerLoaded) {
                        count = state.healers.length;
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "All Result ($count)",
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Availability",
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                                size: 18.sp,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.h), // Healer List
                Expanded(
                  child: BlocBuilder<HealerBloc, HealerState>(
                    builder: (context, state) {
                      if (state is HealerError) {
                        return Center(child: Text(state.message));
                      }

                      final isLoading = state is HealerLoading || state is HealerInitial;
                      final healers = (state is HealerLoaded)
                          ? state.healers
                          : List.generate(4, (_) => HealerModel.dummy());

                      return AutoSkeleton(
                        enabled: isLoading,
                        effect: const ShimmerEffect(
                          baseColor: Color(0xFFE0E0E0),
                          highlightColor: Color(0xFFF5F5F5),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: healers.length,
                          itemBuilder: (context, index) {
                            return HealerCard(
                              healer: healers[index],
                              onTap: isLoading
                                  ? () {}
                                  : () {
                                      context.push(
                                        '/healer-detail/${healers[index].id}',
                                      );
                                    },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
