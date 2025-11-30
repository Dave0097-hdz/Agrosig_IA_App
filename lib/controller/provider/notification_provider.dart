import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/fcm_services/fcm_services.dart';

final unreadCountProvider = StateProvider<int>((ref) => 0);

final notificationProvider = StateNotifierProvider<NotificationNotifier, int>((ref) {
  return NotificationNotifier(ref);
});

class NotificationNotifier extends StateNotifier<int> {
  final Ref ref;

  NotificationNotifier(this.ref) : super(0) {
    loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    try {
      final repository = FcmServices();
      final response = await repository.getUnreadCount();
      if (response.success) {
        state = response.unreadCount;
        ref.read(unreadCountProvider.notifier).state = response.unreadCount;
      } else {
        state = 0; // En caso de error, establecer en 0
      }
    } catch (e) {
      print('Error loading unread count: $e');
      state = 0;
    }
  }

  void decrementCount() {
    final newCount = state > 0 ? state - 1 : 0;
    state = newCount;
    ref.read(unreadCountProvider.notifier).state = newCount;
  }

  void resetCount() {
    state = 0;
    ref.read(unreadCountProvider.notifier).state = 0;
  }

  void incrementCount() {
    state = state + 1;
    ref.read(unreadCountProvider.notifier).state = state;
  }
}