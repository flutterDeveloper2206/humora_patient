import '../../../healers/data/models/healer_api_models.dart';
import '../models/live_consultation_args.dart';

/// Remembers healer display info when a patient joins the live waitlist.
class LiveWaitlistCache {
  LiveWaitlistCache._();
  static final LiveWaitlistCache instance = LiveWaitlistCache._();

  final Map<String, LiveConsultationArgs> _byHealerId = {};

  void remember(LiveConsultationArgs args) {
    if (args.healerId.isEmpty) return;
    _byHealerId[args.healerId] = args;
  }

  LiveConsultationArgs? argsFor(String healerId) => _byHealerId[healerId];

  LiveConsultationArgs consultationArgsForTurn({
    required String healerId,
    required int consultationType,
  }) {
    final cached = _byHealerId[healerId];
    if (cached != null) {
      return cached.copyWith(consultationType: consultationType);
    }
    return LiveConsultationArgs(
      healerId: healerId,
      healerName: 'Healer',
      healerImage: '',
      consultationType: consultationType,
      liveCounselling: const <LiveCounsellingItem>[],
    );
  }

  void forget(String healerId) => _byHealerId.remove(healerId);
}
