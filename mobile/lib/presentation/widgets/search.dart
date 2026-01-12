import 'package:flutter/material.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:remixicon/remixicon.dart';

class Search extends StatelessWidget {
  const Search({super.key, required this.onFilter, this.noFilters = false});

  final VoidCallback onFilter;
  final bool noFilters;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return TextField(
      decoration: InputDecoration(
        hintText: loc.search,
        contentPadding: const .symmetric(vertical: 15),
        prefixIcon: Icon(Icons.search, size: 25),
        suffixIcon: Stack(
          alignment: .center,
          children: [
            IconButton(
              onPressed: onFilter,
              icon: Icon(Remix.filter_2_fill, size: 25),
            ),
            if (!noFilters)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: ColorScheme.of(context).primary,
                    shape: .circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
