import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/presentation/widgets/section_title.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

import '/config/constants.dart';
import '/core/utils/asset.dart';
import '/data/models/post.dart';
import '/data/repositories/post.dart';
import '/l10n/app_localizations.dart';
import '/presentation/providers/post.dart';
import '/presentation/utils.dart';
import '/presentation/widgets/empty.dart';
import '/presentation/widgets/error_retry.dart';
import '/presentation/widgets/fade_in.dart';
import '/presentation/widgets/location_search.dart';
import '/presentation/widgets/posts_grid.dart';
import '../screens/post_details.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _mapController = MapController();
  final _distance = Distance(calculator: Haversine());
  final _debouncer = Debouncer(milliseconds: 500);

  PostType? _selectedType;
  double? _minPrice;
  double? _maxPrice;
  int? _minRooms;
  int? _maxRooms;
  int? _minBathrooms;
  int? _maxBathrooms;
  int? _minSpace;
  int? _maxSpace;

  LatLng? _searchLocation;
  LatLng _currentMapLocation = LatLng(33.5138, 36.2765);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_noCity) {
          ref.read(filteredPostsProvider(_filter).notifier).loadMore();
        }
      }
    });
  }

  void _moveHandler(MapCamera camera) {
    final distance = _distance.as(
      .Kilometer,
      _currentMapLocation,
      camera.center,
    );

    if (distance < 5) {
      if (ref.read(filteredPostsProvider(_filter)).hasError) {
        ref.invalidate(getFilteredPosts);
      }
      ref.read(filteredPostsProvider(_filter).notifier).loadMore();
    } else {
      setState(() {
        _currentMapLocation = camera.center;
      });
    }
  }

  void _moveToLocation() {
    _mapController.move(_searchLocation!, 18);
    _mapController.rotate(0);
  }

  void _onLocationSelected(LatLng location) {
    setState(() {
      _searchLocation = location;
      _currentMapLocation = location;
    });
    _moveToLocation();
  }

  void _clearCity() {
    setState(() {
      _searchLocation = null;
      _searchController.clear();
    });
  }

  bool get _noCity => _searchLocation == null;

  bool get _noFilters =>
      _selectedType == null &&
      _minPrice == null &&
      _maxPrice == null &&
      _minRooms == null &&
      _maxRooms == null &&
      _minBathrooms == null &&
      _maxBathrooms == null &&
      _minSpace == null &&
      _maxSpace == null;

  PostFilter get _filter => PostFilter(
    type: _selectedType,
    minPrice: _minPrice,
    maxPrice: _maxPrice,
    minRooms: _minRooms,
    maxRooms: _maxRooms,
    minBathrooms: _minBathrooms,
    maxBathrooms: _maxBathrooms,
    minSpace: _minSpace,
    maxSpace: _maxSpace,
    userLatitude: _searchLocation?.latitude,
    userLongitude: _searchLocation?.longitude,
    radius: _searchLocation != null ? 5 : null,
  );

  Future<void> _showFiltersDialog(AppLocalizations loc) async {
    PostType? selectedType = _selectedType;
    int? minRooms = _minRooms;
    int? maxRooms = _maxRooms;
    int? minBathrooms = _minBathrooms;
    int? maxBathrooms = _maxBathrooms;
    int? minSpace = _minSpace;
    int? maxSpace = _maxSpace;
    double? minPrice = _minPrice;
    double? maxPrice = _maxPrice;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(loc.filter),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: .min,
              spacing: 16,
              children: [
                Column(
                  spacing: 4,
                  children: [
                    SectionTitle(
                      title: loc.type,
                      icon: HugeIcons.strokeRoundedFilter,
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: _buildDialogTypeButton(
                            .house,
                            loc.typeHouse,
                            HugeIcons.strokeRoundedHouse03,
                            selectedType,
                            (type) => setDialogState(() {
                              selectedType = type == selectedType ? null : type;
                            }),
                          ),
                        ),
                        Expanded(
                          child: _buildDialogTypeButton(
                            .apartment,
                            loc.typeApartment,
                            HugeIcons.strokeRoundedHouse01,
                            selectedType,
                            (type) => setDialogState(() {
                              selectedType = type == selectedType ? null : type;
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: _buildDialogTypeButton(
                            .villa,
                            loc.typeVilla,
                            HugeIcons.strokeRoundedHouse04,
                            selectedType,
                            (type) => setDialogState(() {
                              selectedType = type == selectedType ? null : type;
                            }),
                          ),
                        ),
                        Expanded(
                          child: _buildDialogTypeButton(
                            .office,
                            loc.typeOffice,
                            HugeIcons.strokeRoundedOffice,
                            selectedType,
                            (type) => setDialogState(() {
                              selectedType = type == selectedType ? null : type;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildDialogSlider(
                  loc: loc,
                  label: loc.rooms,
                  icon: HugeIcons.strokeRoundedDoor01,
                  value: minRooms?.toDouble() ?? 0,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: (v) {
                    setDialogState(() {
                      minRooms = v.toInt() == 0 ? null : v.toInt();
                      maxRooms = v.toInt() == 0
                          ? null
                          : v.toInt() == 10
                          ? 99999
                          : v.toInt();
                    });
                  },
                ),
                _buildDialogSlider(
                  loc: loc,
                  label: loc.bath,
                  icon: HugeIcons.strokeRoundedBathtub01,
                  value: minBathrooms?.toDouble() ?? 0,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: (v) {
                    setDialogState(() {
                      minBathrooms = v.toInt() == 0 ? null : v.toInt();
                      maxBathrooms = v.toInt() == 0
                          ? null
                          : v.toInt() == 10
                          ? 99999
                          : v.toInt();
                    });
                  },
                ),
                _buildDialogSlider(
                  loc: loc,
                  label: loc.price,
                  icon: HugeIcons.strokeRoundedDollarSquare,
                  value: maxPrice != null ? min(maxPrice!, 1000) : 0,
                  min: 0,
                  max: 1000,
                  divisions: 10,
                  onChanged: (v) {
                    setDialogState(() {
                      minPrice = v == 0 ? null : 0.0;
                      maxPrice = v == 0
                          ? null
                          : v == 1000
                          ? 99999
                          : v;
                    });
                  },
                ),
                _buildDialogSlider(
                  loc: loc,
                  label: loc.space,
                  icon: HugeIcons.strokeRoundedSquareArrowDiagonal01,
                  value: maxSpace != null ? min(maxSpace!.toDouble(), 500) : 0,
                  min: 0,
                  max: 500,
                  divisions: 10,
                  onChanged: (v) {
                    setDialogState(() {
                      minSpace = v == 0 ? null : 0;
                      maxSpace = v == 0
                          ? null
                          : v == 500
                          ? 99999
                          : v.toInt();
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.clear),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _selectedType = selectedType;
        _minRooms = minRooms;
        _maxRooms = maxRooms;
        _minBathrooms = minBathrooms;
        _maxBathrooms = maxBathrooms;
        _minSpace = minSpace;
        _maxSpace = maxSpace;
        _minPrice = minPrice;
        _maxPrice = maxPrice;
      });
    } else if (result == false) {
      setState(() {
        _selectedType = null;
        _minRooms = null;
        _maxRooms = null;
        _minBathrooms = null;
        _maxBathrooms = null;
        _minSpace = null;
        _maxSpace = null;
        _minPrice = null;
        _maxPrice = null;
      });
    }
  }

  Widget _buildDialogTypeButton(
    PostType type,
    String label,
    List<List<dynamic>> icon,
    PostType? selectedType,
    Function(PostType) onTap,
  ) {
    final isSelected = selectedType == type;
    final bg = isSelected
        ? ColorScheme.of(context).primary
        : ColorScheme.of(context).surfaceBright;
    final color = isSelected
        ? ColorScheme.of(context).onPrimary
        : ColorScheme.of(context).onSecondaryContainer;

    return InkWell(
      onTap: () => onTap(type),
      child: Container(
        padding: const .symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: .circular(8)),
        child: Row(
          spacing: 8,
          children: [
            HugeIcon(icon: icon, color: color, size: 22),
            Text(
              label,
              style: TextTheme.of(context).labelSmall?.copyWith(color: color),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogSlider({
    required String label,
    required List<List<dynamic>> icon,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required Function(double) onChanged,
    required AppLocalizations loc,
  }) {
    String getDisplayValue() {
      if (value == 0) return loc.notSet;
      final intValue = value.toInt();
      if (max == intValue) return '$intValue+';
      return intValue.toString();
    }

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            SectionTitle(
              title: label,
              icon: icon,
              textStyle: TextTheme.of(context).labelMedium,
            ),
            Text(
              getDisplayValue(),
              style: TextTheme.of(
                context,
              ).labelMedium?.copyWith(color: ColorScheme.of(context).primary),
            ),
          ],
        ),
        Slider(
          padding: .symmetric(horizontal: 12, vertical: 4),
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: getDisplayValue(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final AsyncValue<(PaginationInfo, List<Post>)>? posts =
        (!_noCity || !_noFilters)
        ? ref.watch(filteredPostsProvider(_filter))
        : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 8,
          children: [
            Hero(
              tag: 'search_bar',
              child: Material(
                child: Padding(
                  padding: const .symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: LocationSearchField(
                          controller: _searchController,
                          onLocationSelected: _onLocationSelected,
                          onClear: _clearCity,
                        ),
                      ),
                      Stack(
                        alignment: .center,
                        children: [
                          IconButton(
                            onPressed: () => _showFiltersDialog(loc),
                            icon: Icon(Icons.filter_list),
                          ),
                          if (!_noFilters)
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
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 700),
                child:
                    _searchLocation == null ||
                        posts == null ||
                        (posts.value?.$2.isEmpty ?? true)
                    ? _buildGridView(posts, loc)
                    : _buildMapView(posts, loc),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(
    AsyncValue<(PaginationInfo, List<Post>)>? posts,
    AppLocalizations loc,
  ) {
    if (posts == null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const .symmetric(horizontal: 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: .new(minHeight: constraints.maxHeight),
              child: Empty(
                message: loc.nothingHere,
                icon: HugeIcons.strokeRoundedSearch01,
              ),
            ),
          );
        },
      );
    }

    if (posts.isLoading && !posts.hasError) {
      return Padding(
        padding: const .symmetric(horizontal: 20),
        child: const PostsGridSkeleton(),
      );
    }

    if (posts.hasError) {
      final error = posts.error;
      String message;
      if (error is DioException && error.response == null) {
        message = loc.noInternetConnection;
      } else {
        message = error.toString();
      }

      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(getFilteredPosts),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ErrorRetry(
              message: message,
              onRetry: () async => ref.invalidate(getFilteredPosts),
            ),
          ],
        ),
      );
    }

    if (posts.requireValue.$2.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(getFilteredPosts),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const .symmetric(horizontal: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: .new(minHeight: constraints.maxHeight),
                child: Empty(
                  message: loc.nothingHere,
                  icon: HugeIcons.strokeRoundedCrying,
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(getFilteredPosts),
      child: Padding(
        padding: .symmetric(horizontal: 20),
        child: PostsGrid(
          controller: _scrollController,
          hasMore: posts.requireValue.$1.hasMore,
          posts: posts.requireValue.$2,
          detailsFlags: const .new(showButtons: true, showHost: true),
        ),
      ),
    );
  }

  Widget _buildMapView(
    AsyncValue<(PaginationInfo, List<Post>)> posts,
    AppLocalizations loc,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(16),
        border: .all(color: ColorScheme.of(context).outline),
      ),
      margin: .symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: .circular(16),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _searchLocation!,
            initialZoom: 18,
            minZoom: 15,
            onPositionChanged: (camera, _) =>
                _debouncer.run(() => _moveHandler(camera)),
          ),
          children: [
            TileLayer(urlTemplate: osmUrlTemplate, userAgentPackageName: appId),
            MarkerLayer(
              alignment: .topCenter,
              rotate: true,
              markers: [
                if (posts.value != null && posts.value!.$2.isNotEmpty)
                  ...posts.value!.$2.map(
                    (post) => Marker(
                      point: LatLng(post.latitude, post.longitude),
                      width: 84,
                      height: 92,
                      alignment: .topCenter,
                      child: FadeIn(
                        duration: Duration(milliseconds: 700),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailsScreen(postId: post.id),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: .bottomCenter,
                            children: [
                              Positioned(
                                bottom: 12,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorScheme.of(
                                      context,
                                    ).onPrimaryFixedVariant,
                                    borderRadius: .circular(40),
                                  ),
                                  padding: .all(2),
                                  child: CircleAvatar(
                                    radius: 38,
                                    foregroundImage: CachedNetworkImageProvider(
                                      AssetUtil.getThumbnail(
                                        post.featured[0].filePath,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: ClipPath(
                                  clipper: PinClipper(),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryFixedVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            MarkerLayer(
              rotate: true,
              markers: [
                Marker(
                  alignment: .topCenter,
                  point: _searchLocation!,
                  child: Icon(
                    Icons.location_pin,
                    color: ColorScheme.of(context).onPrimaryFixedVariant,
                    size: 40,
                  ),
                ),
              ],
            ),
            RichAttributionWidget(
              showFlutterMapAttribution: false,
              attributions: [
                TextSourceAttribution(loc.openStreetMapContributors),
              ],
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 0,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedCenterFocus),
                  onPressed: _moveToLocation,
                ),
              ),
            ),
            if (posts.isLoading == true)
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: 0,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    constraints: BoxConstraints.expand(width: 18, height: 18),
                  ),
                ),
              )
            else if (posts.hasError == true)
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: 0,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancelCircle,
                    color: ColorScheme.of(context).error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }
}
