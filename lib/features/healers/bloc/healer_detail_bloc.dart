import 'package:flutter_bloc/flutter_bloc.dart';
import 'healer_detail_event.dart';
import 'healer_detail_state.dart';
import '../data/healer_model.dart';

class HealerDetailBloc extends Bloc<HealerDetailEvent, HealerDetailState> {
  HealerDetailBloc() : super(HealerDetailInitial()) {
    on<LoadHealerDetail>(_onLoadHealerDetail);

    on<ChangeTab>((event, emit) {
      if (state is HealerDetailLoaded) {
        emit(
          (state as HealerDetailLoaded).copyWith(activeTabIndex: event.index),
        );
      }
    });

    on<SelectDate>((event, emit) {
      if (state is HealerDetailLoaded) {
        emit((state as HealerDetailLoaded).copyWith(selectedDate: event.date));
      }
    });

    on<SelectTimeCategory>((event, emit) {
      if (state is HealerDetailLoaded) {
        emit(
          (state as HealerDetailLoaded).copyWith(
            selectedTimeCategory: event.category,
          ),
        );
      }
    });

    on<SelectTime>((event, emit) {
      if (state is HealerDetailLoaded) {
        emit((state as HealerDetailLoaded).copyWith(selectedTime: event.time));
      }
    });

    on<NavigateWeek>((event, emit) {
      if (state is HealerDetailLoaded) {
        final loaded = state as HealerDetailLoaded;
        final currentFocused =
            loaded.focusedDate ?? loaded.selectedDate ?? DateTime.now();
        emit(
          loaded.copyWith(
            focusedDate: currentFocused.add(Duration(days: event.weeks * 7)),
          ),
        );
      }
    });
  }

  void _onLoadHealerDetail(
    LoadHealerDetail event,
    Emitter<HealerDetailState> emit,
  ) async {
    emit(HealerDetailLoading());

    try {
      // Mocking API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (event.healerId == '1') {
        final defaultDate = DateTime(2026, 10, 25);
        const healer = HealerModel(
          id: '1',
          name: 'Dr. William',
          imageUrl:
              'assets/image/primage.png', // Temporary, ideally a healer portrait
          specialization: 'Astrologer',
          experienceYears: 11,
          rating: 4.89,
          reviewsCount: 59,
          isAvailableNow: true,
          feesPerMin: 120, // Displayed as /Session in UI
          availability: [
            HealerAvailability(day: 'Mon', periods: ['Morning', 'Evening'], date: 'Mar 01', isAvailable: true),
            HealerAvailability(day: 'Tue', periods: ['Afternoon'], date: 'Mar 01', isAvailable: true),
            HealerAvailability(day: 'Wed', periods: ['Morning', 'Afternoon'], date: 'Mar 01', isAvailable: true),
          ],
          description:
              'A dedicated learning space designed to help individuals understand healing practices, energy balance, and holistic well-being.',
          about:
              'Dr. William is a dedicated astrologer with years of experience in treating various skin, hair, and nail conditions. Known for her ...',
          services: HealerServices(
            oneToOne: HealingService(
              type: 'One-to-One Healing',
              callPrice: 500,
              videoPrice: 700,
              chatPrice: 300,
            ),
            group: HealingService(
              type: 'Group Healing',
              callPrice: 300,
              videoPrice: 500,
              chatPrice: 200,
            ),
          ),
          education: [
            HealerEducation(
              title: 'Healing Certificate',
              imagePath: 'assets/image/Layer 1 2.png',
            ),
            HealerEducation(
              title: 'Reiki Certificate',
              imagePath: 'assets/image/Layer 1 2.png',
            ),
            HealerEducation(
              title: 'Healer Certificate',
              imagePath: 'assets/image/Layer 2 4.png',
            ),
            HealerEducation(
              title: 'Holistic Healing Degree',
              imagePath: 'assets/image/Layer 3 2.png',
            ),
          ],
          experienceDetails: [
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore',
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore',
          ],
          reviews: [
            HealerReview(
              id: 'rev1',
              userName: 'Emma',
              userImageUrl: 'assets/image/primage.png',
              comment:
                  'We were only sad that our session ended so soon. The healing experience was truly calming and supportive. We hope to book again ..',
              rating: 4.89,
              date: '3 weeks ago',
            ),
            HealerReview(
              id: 'rev2',
              userName: 'John',
              userImageUrl: 'assets/image/primage.png',
              comment:
                  'The session was very helpful. I felt much better after the healing.',
              rating: 4.89,
              date: '1 month ago',
            ),
          ],
        );

        emit(
          HealerDetailLoaded(
            healer: healer,
            selectedDate: defaultDate,
            focusedDate: defaultDate,
            selectedTimeCategory: 'Morning',
            selectedTime: '11:00 AM', // Mock default selected time
          ),
        );
      } else {
        emit(const HealerDetailError('Healer not found'));
      }
    } catch (e) {
      emit(HealerDetailError(e.toString()));
    }
  }
}
