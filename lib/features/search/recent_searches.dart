import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/models/json_converters.dart';
import '../../core/api/providers.dart';

/// The reader's last few searches, kept on the device.
class RecentSearchesNotifier extends Notifier<List<String>> {
  static const _key = 'recent_searches';
  static const _max = 6;

  @override
  List<String> build() {
    final raw = ref.read(appStoresProvider).settings.read(_key);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      return decoded is List
          ? [
              for (final item in decoded)
                if (coerceJsonString(item) case final q when q.isNotEmpty) q,
            ]
          : const [];
    } on FormatException {
      return const [];
    }
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    state = [
      q,
      ...state.where((s) => s.toLowerCase() != q.toLowerCase()),
    ].take(_max).toList();
    await _persist();
  }

  Future<void> clear() async {
    state = const [];
    await _persist();
  }

  Future<void> _persist() =>
      ref.read(appStoresProvider).settings.write(_key, jsonEncode(state));
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
      RecentSearchesNotifier.new,
    );
