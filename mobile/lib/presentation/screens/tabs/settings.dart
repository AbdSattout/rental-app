import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/screens/edit_profile.dart';
import 'package:homio/presentation/screens/loading.dart';
import 'package:homio/presentation/utils.dart';
import 'package:homio/presentation/widgets/section_title.dart';
import 'package:hugeicons/hugeicons.dart';

import '/core/providers/auth.dart';
import '/core/providers/language.dart';
import '/core/providers/theme.dart';
import '/l10n/app_localizations.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings), animateColor: true),
      body: Padding(
        padding: const .all(12),
        child: ListView(
          children: [
            if (currentUser != null && currentUser.role != .guest)
              Column(
                crossAxisAlignment: .stretch,
                children: [
                  SectionTitle(
                    title: loc.profile,
                    icon: HugeIcons.strokeRoundedUser03,
                  ),
                  if (currentUser.role == .tenant)
                    SwitchListTile(
                      title: Text(loc.becomeHost),
                      value: currentUser.requestingHost,
                      onChanged: currentUser.requestingHost
                          ? null
                          : (value) async {
                              await showBlockingLoadingUntil(
                                context,
                                action: () async {
                                  await ref
                                      .read(authProvider.notifier)
                                      .beHost();
                                },
                              );
                            },
                    ),
                  Row(
                    spacing: 8,
                    children: [
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
                                    onPressed: () async {
                                      await ref
                                          .read(authProvider.notifier)
                                          .logout();
                                      if (context.mounted) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoadingScreen(),
                                          ),
                                          (_) => false,
                                        );
                                      }
                                    },
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
