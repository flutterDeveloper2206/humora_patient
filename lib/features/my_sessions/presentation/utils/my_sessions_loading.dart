import '../bloc/my_session_detail_state.dart';
import '../bloc/my_sessions_state.dart';

extension MySessionsStateLoading on MySessionsState {
  bool get isBusy =>
      this is MySessionsInitial ||
      this is MySessionsLoading ||
      (this is MySessionsLoaded && (this as MySessionsLoaded).isRefreshing);
}

extension MySessionDetailStateLoading on MySessionDetailState {
  bool get isBusy =>
      this is MySessionDetailInitial ||
      this is MySessionDetailLoading ||
      (this is MySessionDetailLoaded &&
          ((this as MySessionDetailLoaded).isRefreshing ||
              (this as MySessionDetailLoaded).isCancelling));
}
