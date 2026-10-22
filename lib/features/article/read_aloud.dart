import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:material_ui/material_ui.dart';

/// Whether an article is currently being read aloud.
enum PlaybackState { idle, speaking }

/// Drives text-to-speech for the "Listen" control. One engine for the app;
/// starting a new article stops the previous one.
class ReadAloudController extends Notifier<PlaybackState> {
  FlutterTts? _tts;

  @override
  PlaybackState build() {
    ref.onDispose(() => _tts?.stop());
    return PlaybackState.idle;
  }

  Future<FlutterTts> _engine() async {
    final existing = _tts;
    if (existing != null) return existing;
    final tts = FlutterTts();
    await tts.setLanguage('en-US');
    // Mobile completion handlers only fire once the whole utterance finishes
    // when this is set; it's a no-op on web.
    await tts.awaitSpeakCompletion(true);
    await tts.setSpeechRate(
      defaultTargetPlatform == TargetPlatform.iOS ? 0.5 : 0.52,
    );
    void markIdle() {
      if (ref.mounted) state = PlaybackState.idle;
    }

    tts
      ..setCompletionHandler(markIdle)
      ..setCancelHandler(markIdle)
      ..setErrorHandler((_) => markIdle());
    return _tts = tts;
  }

  /// Starts reading [text], or stops if already speaking.
  Future<void> toggle(String text) async {
    final tts = await _engine();
    if (state == PlaybackState.speaking) {
      await tts.stop();
      state = PlaybackState.idle;
      return;
    }
    if (text.trim().isEmpty) return;
    state = PlaybackState.speaking;
    await tts.speak(text);
  }

  Future<void> stop() async {
    await _tts?.stop();
    if (ref.mounted) state = PlaybackState.idle;
  }
}

final readAloudProvider =
    NotifierProvider<ReadAloudController, PlaybackState>(ReadAloudController.new);

/// Turns article HTML into a sentence-flowing string for the speech engine:
/// block tags become sentence breaks, remaining tags are dropped and the
/// common entities are decoded.
String spokenTextFromHtml(String html) {
  var text = html.replaceAll(
    RegExp(r'</(p|div|h[1-6]|li|blockquote|figcaption)>', caseSensitive: false),
    '. ',
  );
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '. ');
  text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
  text = text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&rsquo;', "'")
      .replaceAll('&nbsp;', ' ');
  // Collapse whitespace and tidy the sentence breaks the block tags created.
  text = text.replaceAll(RegExp(r'\s+'), ' ');
  text = text.replaceAll(RegExp(r'(\.\s*){2,}'), '. ');
  return text.trim();
}

/// AppBar control that reads the current article aloud.
class ListenButton extends ConsumerWidget {
  const ListenButton({super.key, required this.text});

  /// Full spoken text, or null while the article is still loading.
  final String? text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speaking = ref.watch(readAloudProvider) == PlaybackState.speaking;
    final enabled = text?.trim().isNotEmpty ?? false;
    return IconButton(
      isSelected: speaking,
      tooltip: speaking ? 'Stop reading' : 'Listen to this article',
      icon: Icon(speaking ? Icons.stop_rounded : Icons.volume_up_rounded),
      onPressed: enabled
          ? () => ref.read(readAloudProvider.notifier).toggle(text!)
          : null,
    );
  }
}
