import 'package:get/get.dart';
import 'package:metube/database/database.dart';

/// Persists video like/dislike for guests in local storage (GetStorage).
class GuestLikeStorage {
  static const _storageKey = 'guest_video_reactions';

  static bool get isGuest {
    final id = Database.loginUserId;
    return id == null ||
        id.toString().trim().isEmpty ||
        id.toString() == 'null';
  }

  static Map<String, String> _readAll() {
    final raw = Database.localStorage.read(_storageKey);
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return {};
  }

  static Future<void> _writeAll(Map<String, String> data) async {
    await Database.localStorage.write(_storageKey, data);
  }

  /// Returns `like`, `dislike`, or null.
  static String? getReaction(String videoId) {
    if (videoId.isEmpty) return null;
    return _readAll()[videoId];
  }

  static Future<void> saveReaction(String videoId, bool isLike) async {
    if (videoId.isEmpty) return;
    final data = _readAll();
    data[videoId] = isLike ? 'like' : 'dislike';
    await _writeAll(data);
  }

  /// Apply stored guest reaction to UI counters and flags.
  static void applyToUi({
    required String videoId,
    required RxBool isLike,
    required RxBool isDisLike,
    required RxMap customChanges,
  }) {
    if (!isGuest) return;

    final stored = getReaction(videoId);
    if (stored == null) return;

    if (stored == 'like' && !isLike.value) {
      if (isDisLike.value) {
        isDisLike.value = false;
        customChanges['disLike'] = _decrement(customChanges['disLike']);
      }
      isLike.value = true;
      customChanges['like'] = _increment(customChanges['like']);
    } else if (stored == 'dislike' && !isDisLike.value) {
      if (isLike.value) {
        isLike.value = false;
        customChanges['like'] = _decrement(customChanges['like']);
      }
      isDisLike.value = true;
      customChanges['disLike'] = _increment(customChanges['disLike']);
    }
  }

  static int _increment(dynamic value) {
    final n = int.tryParse(value?.toString() ?? '') ?? 0;
    return n + 1;
  }

  static int _decrement(dynamic value) {
    final n = int.tryParse(value?.toString() ?? '') ?? 0;
    return n > 0 ? n - 1 : 0;
  }
}
