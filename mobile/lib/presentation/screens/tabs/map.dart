import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

import '/config/constants.dart';
import '/core/utils/asset.dart';
import '/l10n/app_localizations.dart';
import '/presentation/providers/post.dart';
import '../../utils.dart';
import '../../widgets/fade_in.dart';
import '../post_details.dart';

class MapTab extends ConsumerStatefulWidget {
  const MapTab({super.key});

  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  final _mapController = MapController();
  final _distance = Distance(calculator: Haversine());
  bool _isSearching = false;
  LatLng _searchLocation = LatLng(33.5138, 36.2765);
  LatLng _currentLocation = LatLng(33.5138, 36.2765);

  void _moveHandler(MapCamera camera) {
    final distance = _distance.as(.Kilometer, _currentLocation, camera.center);

    if (distance < 5) {
      if (ref.read(postProvider).filteredPagination?.hasMore ?? false) {
        ref
            .read(postProvider.notifier)
            .filterPosts(
              userLatitude: _currentLocation.latitude,
              userLongitude: _currentLocation.longitude,
            );
      }
    } else {
      _currentLocation = camera.center;
      ref
          .read(postProvider.notifier)
          .filterPosts(
            userLatitude: _currentLocation.latitude,
            userLongitude: _currentLocation.longitude,
            refresh: distance > 5,
          );
    }
  }

  void _moveToLocation() {
    _mapController.move(_searchLocation, 18);
    _mapController.rotate(0);
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    List<Location> locations;

    locations = await ref.read(getLocations(query).future);

    setState(() {
      _isSearching = false;
    });

    if (locations.isEmpty) return;

    _searchLocation = LatLng(
      locations.first.latitude,
      locations.first.longitude,
    );

    _moveToLocation();

    await ref
        .read(postProvider.notifier)
        .filterPosts(
          userLatitude: _searchLocation.latitude,
          userLongitude: _searchLocation.longitude,
          radius: 5,
        );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _debouncer.run(() => _search(_searchController.text.trim()));
    });
    Future.microtask(() {
      ref
          .read(postProvider.notifier)
          .filterPosts(
            userLatitude: _currentLocation.latitude,
            userLongitude: _currentLocation.longitude,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final posts = ref.watch(postProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.map)),
      body: Padding(
        padding: const .only(top: 12, right: 12, left: 12),
        child: Column(
          spacing: 8,
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: loc.search,
                prefixIcon: Padding(
                  padding: .all(8),
                  child: HugeIcon(icon: HugeIcons.strokeRoundedSearch01),
                ),
                suffix: _isSearching
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        constraints: BoxConstraints.expand(
                          width: 12,
                          height: 12,
                        ),
                      )
                    : null,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: .circular(16),
                  border: Border.all(color: ColorScheme.of(context).outline),
                ),
                child: ClipRRect(
                  borderRadius: .circular(16),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 18,
                      minZoom: 15,
                      onPositionChanged: (camera, _) =>
                          _debouncer.run(() => _moveHandler(camera)),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: appId,
                      ),
                      MarkerLayer(
                        alignment: .topCenter,
                        rotate: true,
                        markers: [
                          if (posts.filteredPosts?.isNotEmpty ?? false)
                            ...posts.filteredPosts!.map(
                              (post) => Marker(
                                point: LatLng(post.latitude, post.longitude),
                                width: 84,
                                height: 92,
                                alignment: .topCenter,
                                child: FadeIn(
                                  duration: .new(milliseconds: 700),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetailsScreen(
                                                postId: post.id,
                                              ),
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryFixedVariant,
                                              borderRadius: .circular(40),
                                            ),
                                            padding: .all(2),
                                            child: CircleAvatar(
                                              radius: 38,
                                              foregroundImage:
                                                  CachedNetworkImageProvider(
                                                    AssetUtil.getThumbnail(
                                                      post.photos[0].filePath,
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
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryFixedVariant,
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
                            point: _searchLocation,
                            child: Icon(
                              Icons.location_pin,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryFixedVariant,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      RichAttributionWidget(
                        showFlutterMapAttribution: false,
                        attributions: [
                          TextSourceAttribution('OpenStreetMap contributors'),
                        ],
                      ),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        start: 0,
                        child: Padding(
                          padding: const .all(4.0),
                          child: IconButton(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedCenterFocus,
                            ),
                            onPressed: _moveToLocation,
                          ),
                        ),
                      ),
                      if (posts.isLoading)
                        Positioned.directional(
                          textDirection: Directionality.of(context),
                          end: 0,
                          child: Padding(
                            padding: const .all(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              constraints: BoxConstraints.expand(
                                width: 18,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
