import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../../core/api/models/models.dart';
import '../../core/api/providers.dart';
import '../../core/auth/google_auth.dart';
import '../../core/auth/google_signin_button.dart';
import '../../core/auth/reader_account.dart';
import '../../core/router/navigation.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/links.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/brand.dart';
import '../../shared/widgets/list_rows.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/subscribe_card.dart';

/// "1.0.0 (1)", or null if the platform can't say.
final appVersionProvider = FutureProvider<String?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } on Object {
    return null;
  }
});

/// CMS pages that aren't meant for the About list.
const _hiddenPageSlugs = {'home-page'};

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listenForTabReselect(ref, 3, _scroll);
    final pages = ref.watch(pagesProvider);
    final site = ref.watch(siteConfigProvider).value;
    final version = ref.watch(appVersionProvider).value;
    final news = context.news;

    final aboutRows = switch (pages) {
      AsyncValue(:final value?) => [
        for (final page in value)
          if (!_hiddenPageSlugs.contains(page.slug))
            NavRow(
              title: page.title.isEmpty ? page.slug : page.title,
              subtitle: page.subtitle,
              onTap: () => context.openPage(page.slug),
            ),
      ],
      AsyncValue(:final error?) => [
        NavRow(
          title: 'Couldn’t load pages',
          subtitle: error is ApiException
              ? error.userMessage
              : 'Tap to try again.',
          icon: Icons.refresh_rounded,
          onTap: () => ref.invalidate(pagesProvider),
        ),
      ],
      _ => [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: const Column(
            children: [
              SkeletonLine(height: 18),
              SizedBox(height: 14),
              SkeletonLine(height: 18, widthFactor: 0.7),
            ],
          ),
        ),
      ],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          ContentWidth(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 28),
                const Center(child: Lockup(logoSize: 36, wordmarkSize: 21)),
                const SizedBox(height: 8),
                const Tagline(),
                const GroupLabel('Account'),
                const _SignInSection(),
                const GroupLabel('About The Utah View'),
                ...aboutRows,
                const GroupLabel('Newsletter'),
              ],
            ),
          ),
          SubscribeCard.fromConfig(site),
          ContentWidth(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NavRow(
                  title: 'Unsubscribe',
                  subtitle: 'Stop receiving the monthly briefing',
                  serif: false,
                  onTap: () => _showUnsubscribe(context, ref),
                ),
                const GroupLabel('Reading'),
                const _TextSizeSetting(),
                const _AppearanceSetting(),
                const GroupLabel('App'),
                NavRow(
                  title: 'Visit theutahview.com',
                  serif: false,
                  icon: Icons.open_in_new_rounded,
                  onTap: () => openExternalUrl(ApiConfig.siteUrl),
                ),
                NavRow(
                  title: 'Licenses',
                  subtitle: 'Fonts and open-source software',
                  serif: false,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'The Utah View',
                    applicationVersion: version,
                    applicationIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: UtvLogo(size: 48),
                    ),
                  ),
                ),
                if (kDebugMode)
                  NavRow(
                    title: 'Design gallery',
                    subtitle: 'Debug builds only',
                    serif: false,
                    onTap: () => context.pushNamed(RouteNames.gallery),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.gutter,
                    28,
                    context.gutter,
                    0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        version == null ? 'The Utah View' : 'Version $version',
                        style: news.meta,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (site ?? const SiteConfig()).copyrightLine,
                        textAlign: TextAlign.center,
                        style: news.meta,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextSizeSetting extends ConsumerWidget {
  const _TextSizeSetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final news = context.news;
    final gutter = context.gutter;
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Article text size',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(settings.readingScaleLabel, style: news.meta),
            ],
          ),
          Row(
            children: [
              ExcludeSemantics(
                child: Text('A', style: news.headlineXS.copyWith(fontSize: 14)),
              ),
              Expanded(
                child: Slider(
                  value: settings.readingScaleIndex.toDouble(),
                  max: (AppSettings.readingScales.length - 1).toDouble(),
                  divisions: AppSettings.readingScales.length - 1,
                  label: settings.readingScaleLabel,
                  semanticFormatterCallback: (_) => settings.readingScaleLabel,
                  onChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .setReadingScaleIndex(v.round()),
                ),
              ),
              ExcludeSemantics(
                child: Text('A', style: news.headlineXS.copyWith(fontSize: 24)),
              ),
            ],
          ),
          ExcludeSemantics(
            child: Text(
              'The Utah View covers every region, every month.',
              style: news.body.copyWith(
                fontSize: news.body.fontSize! * settings.readingScale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSetting extends ConsumerWidget {
  const _AppearanceSetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final gutter = context.gutter;
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                ref.read(settingsProvider.notifier).setThemeMode(s.first),
          ),
        ],
      ),
    );
  }
}

Future<void> _showUnsubscribe(BuildContext context, WidgetRef ref) async {
  final email = await showDialog<String>(
    context: context,
    builder: (context) => const _UnsubscribeDialog(),
  );
  if (email == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(newsRepositoryProvider).unsubscribe(email);
    messenger.showSnackBar(
      const SnackBar(content: Text('You’ve been unsubscribed.')),
    );
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.userMessage)));
  }
}

class _UnsubscribeDialog extends StatefulWidget {
  const _UnsubscribeDialog();

  @override
  State<_UnsubscribeDialog> createState() => _UnsubscribeDialogState();
}

class _UnsubscribeDialogState extends State<_UnsubscribeDialog> {
  final _email = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _email.text.trim();
    if (!isPlausibleEmail(value)) {
      setState(() => _error = 'Enter the email you subscribed with.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unsubscribe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('We’ll stop sending the monthly briefing to:'),
          const SizedBox(height: 14),
          TextField(
            controller: _email,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'your@email.com',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Unsubscribe')),
      ],
    );
  }
}

/// Account section: email/password sign-up & login (first-party), plus Google
/// sign-in. Signed in -> shows who you are with a sign-out. Degrades cleanly if
/// a path is unavailable.
class _SignInSection extends ConsumerStatefulWidget {
  const _SignInSection();

  @override
  ConsumerState<_SignInSection> createState() => _SignInSectionState();
}

class _SignInSectionState extends ConsumerState<_SignInSection> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _signup = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final ctl = ref.read(readerAccountProvider.notifier);
    final err = _signup
        ? await ctl.signUp(_email.text.trim(), _password.text, _name.text.trim())
        : await ctl.logIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reader = ref.watch(readerAccountProvider);
    final google = ref.watch(authControllerProvider).value;
    final gutter = context.gutter;

    if (reader != null) {
      return NavRow(
        title: 'Sign out',
        subtitle: reader.email,
        serif: false,
        icon: Icons.logout_rounded,
        onTap: () => ref.read(readerAccountProvider.notifier).logOut(),
      );
    }
    if (google != null) {
      return NavRow(
        title: 'Sign out',
        subtitle: google.email,
        serif: false,
        icon: Icons.logout_rounded,
        onTap: () => ref.read(authControllerProvider.notifier).signOut(),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_signup) _field(_name, 'Name', TextInputType.name),
          _field(_email, 'Email', TextInputType.emailAddress),
          _field(_password, 'Password', TextInputType.visiblePassword, obscure: true),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: context.palette.accent, fontSize: 13),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_signup ? 'Create account' : 'Log in'),
          ),
          TextButton(
            onPressed: _busy ? null : () => setState(() {
              _signup = !_signup;
              _error = null;
            }),
            child: Text(_signup
                ? 'Have an account? Log in'
                : 'New here? Create an account'),
          ),
          const SizedBox(height: 4),
          if (kIsWeb)
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(height: 44, width: 240, child: googleSignInButton()),
            )
          else
            OutlinedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).signIn(),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Continue with Google'),
            ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, TextInputType type,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: c,
        keyboardType: type,
        obscureText: obscure,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _busy ? null : _submit(),
      ),
    );
  }
}
