import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/screens/edit_profile.dart';
import 'package:homio/presentation/screens/login.dart';
import 'package:homio/presentation/utils.dart';
import 'package:homio/presentation/widgets/section_title.dart';
import 'package:hugeicons/hugeicons.dart';

import '/core/providers/auth.dart';
import '/core/providers/language.dart';
import '/core/providers/theme.dart';
import '/l10n/app_localizations.dart';

Future<void> _handleLogout(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations loc,
) async {
  await ref.read(authProvider.notifier).logout();

  if (!context.mounted) return;

  if (ref.read(authProvider).status != .error) {
    final nav = Navigator.of(context);
    while (nav.canPop()) {
      nav.pop();
    }
    await nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (_) => false,
    );
  } else {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (ref.read(authProvider).error!.type) {
          .networkError => loc.noInternetConnection,
          _ => loc.anErrorOccurred,
        }),
      ),
    );
  }
}

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final authStatus = ref.watch(authStatusProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings), animateColor: true),
      body: Padding(
        padding: const .all(12),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: .stretch,
              children: [
                SectionTitle(
                  title: loc.profile,
                  icon: HugeIcons.strokeRoundedUser03,
                ),
                if (currentUser != null && currentUser.role == .tenant)
                  SwitchListTile(
                    title: Text(loc.becomeHost),
                    value: currentUser.requestingHost,
                    onChanged: currentUser.requestingHost
                        ? null
                        : (value) async {
                            await showBlockingLoadingUntil(
                              context,
                              action: ref.read(authProvider.notifier).beHost,
                              onCompleted: (result) {
                                if (ref.read(authProvider).status == .error) {
                                  switch (ref.read(authProvider).error!.type) {
                                    case .networkError:
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.networkError),
                                        ),
                                      );
                                    case _:
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(loc.anErrorOccurred),
                                        ),
                                      );
                                  }
                                }
                              },
                            );
                          },
                  ),
                Row(
                  spacing: 8,
                  children: [
                    if (authStatus == .authenticated)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(),
                              ),
                            );
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit01,
                            size: 18,
                          ),
                          label: Text(loc.editProfile),
                        ),
                      ),
                    if (authStatus == .unauthenticated ||
                        authStatus == .initial)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (_) => false,
                            );
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedLogin01,
                            size: 18,
                          ),
                          label: Text(loc.login),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(loc.logout),
                                content: Text(loc.logoutConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(loc.cancel),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        _handleLogout(context, ref, loc),
                                    child: Text(loc.logout),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedLogout01,
                            size: 18,
                          ),
                          label: Text(loc.logout),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorScheme.of(context).error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: .stretch,
              children: [
                SectionTitle(
                  title: loc.theme,
                  icon: HugeIcons.strokeRoundedPaintBoard,
                ),
                SegmentedButton<ThemeMode>(
                  segments: <ButtonSegment<ThemeMode>>[
                    .new(value: .light, label: Text(loc.light)),
                    .new(value: .dark, label: Text(loc.dark)),
                    .new(value: .system, label: Text(loc.system)),
                  ],
                  selected: {currentTheme},
                  onSelectionChanged: (newSelection) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
            Column(
              crossAxisAlignment: .stretch,
              children: [
                SectionTitle(
                  title: loc.language,
                  icon: HugeIcons.strokeRoundedGlobe02,
                ),
                SegmentedButton<LanguageCode?>(
                  segments: [
                    .new(value: LanguageCode.en, label: Text(loc.english)),
                    .new(value: LanguageCode.ar, label: Text(loc.arabic)),
                    .new(value: null, label: Text(loc.system)),
                  ],
                  selected: {language},
                  onSelectionChanged: (newSelection) {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(newSelection.first);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
