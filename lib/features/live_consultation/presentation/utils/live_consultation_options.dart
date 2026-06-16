import '../../../healers/data/models/healer_api_models.dart';
import '../../../live_counselling_session/data/models/live_counselling_session_model.dart';

class LiveConsultationOptions {
  LiveConsultationOptions._();

  static List<LiveCounsellingSessionModel> fromLiveCounselling(
    List<LiveCounsellingItem> items,
  ) {
    if (items.isEmpty) {
      return _fallbackOptions();
    }

    return items.asMap().entries.map((entry) {
      final item = entry.value;
      return LiveCounsellingSessionModel(
        id: entry.key + 1,
        image: _imageForType(item.consultationType),
        value: _labelForType(item.consultationType),
        price: item.pricePerMinute,
        consultationType: item.consultationType,
      );
    }).toList();
  }

  static List<LiveCounsellingSessionModel> _fallbackOptions() {
    return const [
      LiveCounsellingSessionModel(
        id: 1,
        image: 'assets/image/chatstart.png',
        value: 'Chat',
        price: 100,
        consultationType: 0,
      ),
      LiveCounsellingSessionModel(
        id: 2,
        image: 'assets/image/voicestart.png',
        value: 'Voice Call',
        price: 300,
        consultationType: 1,
      ),
      LiveCounsellingSessionModel(
        id: 3,
        image: 'assets/image/videostart.png',
        value: 'Video Call',
        price: 500,
        consultationType: 2,
      ),
    ];
  }

  static String _imageForType(int consultationType) => switch (consultationType) {
        0 => 'assets/image/chatstart.png',
        1 => 'assets/image/voicestart.png',
        2 => 'assets/image/videostart.png',
        _ => 'assets/image/chatstart.png',
      };

  static String _labelForType(int consultationType) => switch (consultationType) {
        0 => 'Chat',
        1 => 'Voice Call',
        2 => 'Video Call',
        _ => 'Session',
      };
}
