import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum WarningVariant { warning, error, info }

class Warning extends StatelessWidget {
  final String message;
  final String? title;
  final WarningVariant variant;

  const Warning({
    super.key,
    required this.message,
    this.title,
    this.variant = WarningVariant.warning,
  });

  Color bg(BuildContext context) {
    switch (variant) {
      case .warning:
        return ColorScheme.of(context).errorContainer;
      case .error:
        return ColorScheme.of(context).tertiaryContainer;
      case .info:
        return ColorScheme.of(context).secondaryContainer;
    }
  }

  Color color(BuildContext context) {
    switch (variant) {
      case .warning:
        return ColorScheme.of(context).onErrorContainer;
      case .error:
        return ColorScheme.of(context).onTertiaryContainer;
      case .info:
        return ColorScheme.of(context).onSecondaryContainer;
    }
  }

  dynamic icon(BuildContext context) {
    switch (variant) {
      case .warning:
        return HugeIcons.strokeRoundedAlertCircle;
      case .error:
        return HugeIcons.strokeRoundedCancelCircle;
      case .info:
        return HugeIcons.strokeRoundedInformationCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        spacing: 12,
        children: [
          HugeIcon(icon: icon(context), color: color(context), size: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: color(context)),
                  ),
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: color(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
