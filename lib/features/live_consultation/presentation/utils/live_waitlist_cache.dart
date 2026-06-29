import '../../../healers/data/models/healer_api_models.dart';
import '../models/live_consultation_args.dart';

/// Remembers healer display info when a patient joins the live waitlist.
class LiveWaitlistCache {
  LiveWaitlistCache._();
  static final LiveWaitlistCache instance = LiveWaitlistCache._();

  final Map<String, LiveConsultationArgs> _byHealerId = {};
  final Map<String, int> _consultationTypeByBookingId = {};

  /// Messages the patient typed while a live chat request is still pending
  /// (healer offline / not yet accepted). Persisted here so they survive
  /// leaving + reopening the pending screen and are delivered once the
  /// healer accepts (comes online).
  final Map<String, List<String>> _pendingDraftsByHealerId = {};

  void remember(LiveConsultationArgs args) {
    if (args.healerId.isEmpty) return;
    _byHealerId[args.healerId] = args;
  }

  void rememberDrafts(String healerId, List<String> drafts) {
    if (healerId.isEmpty) return;
    if (drafts.isEmpty) {
      _pendingDraftsByHealerId.remove(healerId);
      return;
    }
    _pendingDraftsByHealerId[healerId] = List<String>.from(drafts);
  }

  List<String> draftsFor(String healerId) =>
      List<String>.from(_pendingDraftsByHealerId[healerId] ?? const <String>[]);

  void forgetDrafts(String healerId) {
    _pendingDraftsByHealerId.remove(healerId);
  }

  void rememberBookingType(String bookingId, int consultationType) {
    if (bookingId.isEmpty) return;
    _consultationTypeByBookingId[bookingId] = consultationType;
  }

  int? consultationTypeForBooking(String bookingId) =>
      _consultationTypeByBookingId[bookingId];

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

  void forget(String healerId) {
    _byHealerId.remove(healerId);
  }

  void forgetBooking(String bookingId) =>
      _consultationTypeByBookingId.remove(bookingId);
}
