import 'package:flutter/material.dart';
import 'package:homio/l10n/app_localizations.dart';
import 'package:remixicon/remixicon.dart';

class Search extends StatelessWidget {
  const Search({super.key, required this.onFilter, this.noFilters = false});

  final Function() onFilter;
  final bool noFilters;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(10),
      ),
      child: Row(
        spacing: 5,
        children: [
          SizedBox(width: 5),
          Icon(Icons.search, color: color, size: 25),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: loc.search,
                hintStyle: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: .bold,
                ),
                border: .none,
              ),
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: onFilter,
                icon: Icon(Remix.filter_2_fill, color: color, size: 25),
              ),
              if (!noFilters)
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  top: 8,
                  end: 8,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ColorScheme.of(context).primary,
                      borderRadius: .circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
