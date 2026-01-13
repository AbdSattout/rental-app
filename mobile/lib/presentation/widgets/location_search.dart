import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

import '../../../l10n/app_localizations.dart';
import '../utils.dart';

class LocationSearchField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(LatLng)? onLocationSelected;
  final Function()? onClear;
  final String? labelText;
  final bool disabled;

  const LocationSearchField({
    super.key,
    required this.controller,
    this.onLocationSelected,
    this.onClear,
    this.labelText,
    this.disabled = false,
  });

  @override
  ConsumerState<LocationSearchField> createState() =>
      _LocationSearchFieldState();
}

class _LocationSearchFieldState extends ConsumerState<LocationSearchField> {
  final _debouncer = Debouncer(milliseconds: 500);
  bool _isSearching = false;
  String _query = '';

  void _search(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    List<Location> locations;

    try {
      locations = await ref.read(getLocations(query).future);
    } catch (_) {
      ref.invalidate(getLocations(query));
      locations = [];
    }

    setState(() {
      _isSearching = false;
    });

    if (locations.isEmpty) return;

    final location = LatLng(
      locations.first.latitude,
      locations.first.longitude,
    );

    widget.onLocationSelected?.call(location);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.text.trim().isEmpty) widget.onClear?.call();
      _debouncer.run(() {
        setState(() {
          _query = widget.controller.text.trim();
        });
        _search(_query);
      });
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return TextFormField(
      controller: widget.controller,
      enabled: !widget.disabled,
      autofocus: true,
      decoration: InputDecoration(
        hintText: widget.labelText ?? loc.search,
        prefixIcon: Padding(
          padding: .all(8),
          child: Icon(Icons.search, size: 25),
        ),
        suffix: _isSearching && !ref.read(getLocations(_query)).hasError
            ? CircularProgressIndicator(
                strokeWidth: 2,
                constraints: BoxConstraints.expand(width: 12, height: 12),
              )
            : _query.isNotEmpty && ref.read(getLocations(_query)).hasError
            ? HugeIcon(
                icon: HugeIcons.strokeRoundedCancelCircle,
                size: 14,
                color: ColorScheme.of(context).error,
              )
            : null,
      ),
    );
  }
}
