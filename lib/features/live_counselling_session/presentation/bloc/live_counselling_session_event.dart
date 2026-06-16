import 'package:equatable/equatable.dart';

import '../../../healers/data/models/healer_api_models.dart';

abstract class LiveCounsellingSessionEvent extends Equatable {
  const LiveCounsellingSessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadLiveCounsellingSessionOptions extends LiveCounsellingSessionEvent {
  final List<LiveCounsellingItem> liveCounselling;

  const LoadLiveCounsellingSessionOptions(this.liveCounselling);

  @override
  List<Object?> get props => [liveCounselling];
}

class SelectLiveCounsellingSession extends LiveCounsellingSessionEvent {
  final int sessionId;

  const SelectLiveCounsellingSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
