import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models/models.dart';
import '../../core/api/news_repository.dart';
import '../../core/api/providers.dart';
import '../../core/theme/theme.dart';

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// Loose sanity check; the server is the real validator.
bool isPlausibleEmail(String value) => _emailPattern.hasMatch(value.trim());

enum _Status { idle, sending, done, failed }

/// "Stay briefed" newsletter sign-up, posting to `/api/subscribe`.
class SubscribeCard extends ConsumerStatefulWidget {
  const SubscribeCard({
    super.key,
    required this.overline,
    required this.heading,
    required this.description,
  });

  /// Uses the site config copy (or the website's defaults).
  factory SubscribeCard.fromConfig(SiteConfig? config, {Key? key}) {
    final c = config ?? const SiteConfig();
    return SubscribeCard(
      key: key,
      overline: c.subscribeOverline,
      heading: c.subscribeHeading,
      description: c.subscribeDescription,
    );
  }

  final String overline;
  final String heading;
  final String description;

  @override
  ConsumerState<SubscribeCard> createState() => _SubscribeCardState();
}

class _SubscribeCardState extends ConsumerState<SubscribeCard> {
  final _email = TextEditingController();
  _Status _status = _Status.idle;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!isPlausibleEmail(email)) {
      setState(() {
        _status = _Status.failed;
        _message = 'Enter a valid email address.';
      });
      return;
    }
    setState(() {
      _status = _Status.sending;
      _message = null;
    });
    try {
      final result = await ref.read(newsRepositoryProvider).subscribe(email);
      if (!mounted) return;
      _email.clear();
      setState(() {
        _status = _Status.done;
        _message = result == SubscribeResult.alreadySubscribed
            ? "You're already subscribed!"
            : 'Welcome aboard. Your first briefing arrives next month.';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _Status.failed;
        _message = e.kind == ApiErrorKind.offline
            ? e.userMessage
            : "We couldn't sign you up just now. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final news = context.news;
    final sending = _status == _Status.sending;

    final field = TextField(
      controller: _email,
      enabled: !sending,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.send,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      enableSuggestions: false,
      onSubmitted: (_) => _submit(),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: const InputDecoration(
        hintText: 'your@email.com',
        labelText: 'Email address',
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
    final button = FilledButton(
      onPressed: sending ? null : _submit,
      child: sending
          ? SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: p.inkMuted,
                semanticsLabel: 'Subscribing',
              ),
            )
          : const Text('SUBSCRIBE', semanticsLabel: 'Subscribe'),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        border: Border(top: BorderSide(color: p.accentFill, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        child: Column(
          children: [
            Text(
              widget.overline.toUpperCase(),
              semanticsLabel: widget.overline,
              textAlign: TextAlign.center,
              style: news.sectionLabel.copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(
                widget.heading,
                textAlign: TextAlign.center,
                style: news.headlineL,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: news.summary.copyWith(color: p.inkMuted),
            ),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textScale =
                      MediaQuery.textScalerOf(context).scale(14) / 14;
                  if (constraints.maxWidth < 330 || textScale > 1.3) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [field, const SizedBox(height: 8), button],
                    );
                  }
                  // IntrinsicHeight lets the button match the field's height.
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: field),
                        button,
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: news.meta.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _status == _Status.failed ? p.accent : p.ink,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
