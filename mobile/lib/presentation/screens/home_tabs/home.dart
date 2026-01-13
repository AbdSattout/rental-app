import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homio/data/repositories/post.dart';
import 'package:homio/presentation/screens/post_details.dart';
import 'package:homio/presentation/widgets/category_button.dart';
import 'package:homio/presentation/widgets/empty.dart';
import 'package:homio/presentation/widgets/search.dart';
import 'package:homio/presentation/widgets/section_title.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/providers/auth.dart';
import '../../../data/models/post.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/post.dart';
import '../../providers/profile.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/post_card.dart';
import '../../widgets/warning.dart';

class HomeSectionSkeletonizer extends StatelessWidget {
  const HomeSectionSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Skeletonizer(
      enabled: true,
      effect: PulseEffect(
        from: ColorScheme.of(context).secondary.withValues(alpha: 0.1),
        to: ColorScheme.of(context).secondary.withValues(alpha: 0.2),
      ),
      child: ListView(
        padding: .symmetric(horizontal: 20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const .all(8),
                child: Row(
                  spacing: 10,
                  children: [
                    Bone.circle(size: 18),
                    Text(loc.loading, style: TextTheme.of(context).labelLarge),
                  ],
                ),
              ),
              SingleChildScrollView(
                clipBehavior: .none,
                scrollDirection: .horizontal,
                child: Row(
                  spacing: 10,
                  children: List.generate(
                    3,
                    (_) =>
                        const SizedBox(width: 256, child: PostCardSkeleton()),
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

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final ScrollController _scrollController = ScrollController();

  PostType? _selectedType;

  double? _minPrice;
  double? _maxPrice;

  int? _minRooms;
  int? _maxRooms;

  int? _minBathrooms;
  int? _maxBathrooms;

  final List<String> _countOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10+',
  ];

  final List<String> _priceOptions = ['50', '100', '200', '300', '400', '500+'];

  Map<String, ({int min, int max})> get _countRanges => {
    '1': (min: 1, max: 1),
    '2': (min: 2, max: 2),
    '3': (min: 3, max: 3),
    '4': (min: 4, max: 4),
    '5': (min: 5, max: 5),
    '6': (min: 6, max: 6),
    '7': (min: 7, max: 7),
    '8': (min: 8, max: 8),
    '9': (min: 9, max: 9),
    '10+': (min: 10, max: 99),
  };

  Map<String, ({double min, double max})> get _priceRanges => {
    '50': (min: 0, max: 75),
    '100': (min: 75, max: 150),
    '200': (min: 150, max: 250),
    '300': (min: 250, max: 350),
    '400': (min: 350, max: 450),
    '500+': (min: 450, max: 999),
  };

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_noFilters) {
          ref.read(homepageFeedProvider.notifier).loadMore();
        } else {
          ref.read(filteredPostsProvider(_filter).notifier).loadMore();
        }
      }
    });
  }

  bool get _noFilters =>
      _selectedType == null &&
      _minPrice == null &&
      _maxPrice == null &&
      _minRooms == null &&
      _maxRooms == null &&
      _minBathrooms == null &&
      _maxBathrooms == null;

  PostFilter get _filter => PostFilter(
    type: _selectedType,
    minPrice: _minPrice,
    maxPrice: _maxPrice,
    minRooms: _minRooms,
    maxRooms: _maxRooms,
    minBathrooms: _minBathrooms,
    maxBathrooms: _maxBathrooms,
  );

  Future<void> _showFiltersDialog(AppLocalizations loc) async {
    String? rooms = _countRanges.entries
        .where((e) => e.value.min == _minRooms && e.value.max == _maxRooms)
        .map((e) => e.key)
        .firstOrNull;

    String? baths = _countRanges.entries
        .where(
          (e) => e.value.min == _minBathrooms && e.value.max == _maxBathrooms,
        )
        .map((e) => e.key)
        .firstOrNull;

    String? price = _priceRanges.entries
        .where((e) => e.value.min == _minPrice && e.value.max == _maxPrice)
        .map((e) => e.key)
        .firstOrNull;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.filter),
        content: Column(
          mainAxisSize: .min,
          spacing: 12,
          children: [
            DropdownButtonFormField(
              initialValue: rooms,
              decoration: InputDecoration(labelText: loc.rooms),
              items: _countOptions
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => rooms = v,
            ),
            DropdownButtonFormField(
              initialValue: baths,
              decoration: InputDecoration(labelText: loc.bath),
              items: _countOptions
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => baths = v,
            ),
            DropdownButtonFormField(
              initialValue: price,
              decoration: InputDecoration(labelText: loc.price),
              items: _priceOptions
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => price = v,
            ),
          ],
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
    );

    if (result == false) {
      setState(() {
        _minRooms = null;
        _maxRooms = null;
        _minBathrooms = null;
        _maxBathrooms = null;
        _minPrice = null;
        _maxPrice = null;
      });
    }

    if (result == true) {
      setState(() {
        if (rooms != null) {
          final r = _countRanges[rooms]!;
          _minRooms = r.min;
          _maxRooms = r.max;
        } else {
          _minRooms = null;
          _maxRooms = null;
        }

        if (baths != null) {
          final b = _countRanges[baths]!;
          _minBathrooms = b.min;
          _maxBathrooms = b.max;
        } else {
          _minBathrooms = null;
          _maxBathrooms = null;
        }

        if (price != null) {
          final p = _priceRanges[price]!;
          _minPrice = p.min;
          _maxPrice = p.max;
        } else {
          _minPrice = null;
          _maxPrice = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentProfileAsync = authState.isGuest
        ? null
        : ref.watch(getProfile);
    final loc = AppLocalizations.of(context)!;
    final posts = _noFilters
        ? ref.watch(homepageFeedProvider)
        : ref.watch(filteredPostsProvider(_filter));

    return RefreshIndicator(
      onRefresh: () async => _noFilters
          ? ref.invalidate(getHomepageFeed)
          : ref.invalidate(getFilteredPosts),
      child: Column(
        spacing: 20,
        crossAxisAlignment: .stretch,
        children: [
          Padding(
            padding: .symmetric(horizontal: 20),
            child: () {
              if (authState.isAuthenticated &&
                  authState.isApproved &&
                  currentProfileAsync != null) {
                return Skeletonizer(
                  enabled:
                      currentProfileAsync.isLoading ||
                      currentProfileAsync.asData?.value == null,
                  child: Padding(
                    padding: const .only(top: 72, bottom: 24),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          loc.hello(
                            currentProfileAsync.asData?.value.firstName
                                    .trim() ??
                                loc.guest,
                          ),
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(color: ColorScheme.of(context).primary),
                        ),
                        Text(
                          '${loc.welcome} 👋',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: ColorScheme.of(context).secondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!authState.isApproved) {
                return Warning(message: loc.approvalPending);
              } else if (!authState.isAuthenticated) {
                return Warning(message: loc.guestMode);
              }
            }(),
          ),

          Padding(
            padding: const .symmetric(horizontal: 20),
            child: Search(
              onFilter: () => _showFiltersDialog(loc),
              noFilters: _noFilters,
            ),
          ),

          SingleChildScrollView(
            scrollDirection: .horizontal,
            child: Padding(
              padding: const .symmetric(horizontal: 20),
              child: Row(
                spacing: 8,
                children: [
                  CategoryButton(
                    isSelected: _selectedType == PostType.house,
                    onTap: () {
                      setState(
                        () => _selectedType = (_selectedType == PostType.house
                            ? null
                            : PostType.house),
                      );
                    },
                    title: loc.typeHouse,
                  ),
                  CategoryButton(
                    isSelected: _selectedType == PostType.apartment,
                    onTap: () {
                      setState(
                        () =>
                            _selectedType = (_selectedType == PostType.apartment
                            ? null
                            : PostType.apartment),
                      );
                    },
                    title: loc.typeApartment,
                  ),
                  CategoryButton(
                    isSelected: _selectedType == PostType.villa,
                    onTap: () {
                      setState(
                        () => _selectedType = (_selectedType == PostType.villa
                            ? null
                            : PostType.villa),
                      );
                    },
                    title: loc.typeVilla,
                  ),
                  CategoryButton(
                    isSelected: _selectedType == PostType.office,
                    onTap: () {
                      setState(
                        () => _selectedType = (_selectedType == PostType.office
                            ? null
                            : PostType.office),
                      );
                    },
                    title: loc.typeOffice,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Builder(
              builder: (_) {
                if (posts.isLoading && !posts.hasError) {
                  return const HomeSectionSkeletonizer();
                }

                if (posts.hasError) {
                  final error = posts.error;
                  String message;
                  if (error is DioException && error.response == null) {
                    message = loc.noInternetConnection;
                  } else {
                    message = error.toString();
                  }

                  return ErrorRetry(
                    message: message,
                    onRetry: () async {
                      _noFilters
                          ? ref.invalidate(getHomepageFeed)
                          : ref.invalidate(getFilteredPosts);
                    },
                  );
                }

                if (posts.requireValue.$2.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: .symmetric(horizontal: 20),
                        physics: AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Empty(
                            message: loc.nothingHere,
                            icon: HugeIcons.strokeRoundedCrying,
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView(
                  padding: .symmetric(horizontal: 20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            SectionTitle(
                              title: loc.latestPosts,
                              icon: HugeIcons.strokeRoundedHouse01,
                            ),
                            if (posts.requireValue.$1.hasMore)
                              GestureDetector(
                                // TODO: show all posts
                                child: Text(
                                  loc.showAll,
                                  style: TextTheme.of(context).labelSmall
                                      ?.copyWith(
                                        color: ColorScheme.of(
                                          context,
                                        ).secondary,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        SingleChildScrollView(
                          clipBehavior: .none,
                          scrollDirection: .horizontal,
                          child: Row(
                            spacing: 10,
                            children: [
                              for (final post in posts.requireValue.$2)
                                SizedBox(
                                  width: 256,
                                  child: PostCard(
                                    post: post,
                                    flags: .new(
                                      showFavourite: !authState.isGuest,
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (c) => PostDetailsScreen(
                                          postId: post.id,
                                          flags: .new(
                                            showButtons: !authState.isGuest,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
