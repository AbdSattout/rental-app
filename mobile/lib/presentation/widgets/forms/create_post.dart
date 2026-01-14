import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '/core/utils/asset.dart';
import '../../../config/constants.dart';
import '../../../data/models/post.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/post.dart';
import '../../screens/post_details.dart';
import '../../utils.dart';
import '../../widgets/section_title.dart';
import '../../widgets/warning.dart';
import '../location_search.dart';

class CreatePostForm extends ConsumerStatefulWidget {
  final Post? post;

  const CreatePostForm({super.key, this.post});

  @override
  ConsumerState<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends ConsumerState<CreatePostForm> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();
  final _pageController = PageController();
  final _locationController = TextEditingController();
  PostType? _type;
  double? _space;
  int? _rooms;
  int? _bathrooms;
  double? _price;
  LatLng? _location;
  List<File> _featured = [];
  List<File> _gallery = [];

  void _onLocationSelected(LatLng location) {
    setState(() {
      _location = location;
    });
    _mapController.move(location, 18);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos(bool isFeatured) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      limit: isFeatured ? 3 : 5,
      maxHeight: 1024,
      maxWidth: 1024,
    );

    for (final picked in pickedFiles) {
      if (await picked.length() > 2 * 1024 * 1024) {
        if (!mounted) return;
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.imageTooLarge)));
        return;
      }

      if (picked.mimeType != null &&
          picked.mimeType != 'image/jpeg' &&
          picked.mimeType != 'image/png') {
        if (!mounted) return;
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.invalidImageType)));
        return;
      }
    }

    if (pickedFiles.isNotEmpty) {
      setState(() {
        // manually limiting on unsupported platforms
        if (isFeatured) {
          _featured = pickedFiles.map((f) => File(f.path)).toList();
          if (_featured.length > 3) {
            _featured.removeRange(3, _featured.length);
          }
        } else {
          _gallery = pickedFiles.map((f) => File(f.path)).toList();
          if (_gallery.length > 5) {
            _gallery.removeRange(5, _gallery.length);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final post = widget.post;
    _type ??= post?.type;
    _location ??= post == null
        ? LatLng(33.5138, 36.2765)
        : LatLng(post.latitude, post.longitude);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    SectionTitle(
                      title: loc.featured,
                      icon: HugeIcons.strokeRoundedAiImage,
                    ),
                    InkWell(
                      onTap: () => _pickPhotos(true),
                      borderRadius: .circular(18),
                      child: Padding(
                        padding: const .all(8.0),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedImageAdd01,
                          size: 18,
                          color: ColorScheme.of(context).primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_featured.isNotEmpty || post != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: .circular(16),
                        border: Border.all(
                          color: ColorScheme.of(context).outline,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PageView(
                          scrollBehavior: MouseScroll(),
                          scrollDirection: .horizontal,
                          controller: _pageController,

                          children: _featured.isEmpty
                              ? post!.featured.map((photo) {
                                  return CachedNetworkImage(
                                    imageUrl: AssetUtil.getAssetUrl(
                                      photo.filePath,
                                    ),
                                    fit: BoxFit.cover,
                                  );
                                }).toList()
                              : _featured.map((photo) {
                                  return Image.file(
                                    photo,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                  )
                else
                  Warning(variant: .info, message: loc.selectAtLeastOnePhoto),
              ],
            ),

            if ((_featured.isNotEmpty && _featured.length > 1) ||
                (_featured.isEmpty && post != null && post.featured.length > 1))
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _featured.isNotEmpty
                      ? _featured.length
                      : post!.featured.length,
                  onDotClicked: (index) {
                    _pageController.animateToPage(
                      index,
                      duration: .new(seconds: 1),
                      curve: Curves.easeOutExpo,
                    );
                  },
                ),
              ),

            Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    SectionTitle(
                      title: loc.gallery,
                      icon: HugeIcons.strokeRoundedImage01,
                    ),
                    InkWell(
                      onTap: () => _pickPhotos(false),
                      borderRadius: .circular(18),
                      child: Padding(
                        padding: const .all(8.0),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedImageAdd01,
                          size: 18,
                          color: ColorScheme.of(context).primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_gallery.isNotEmpty || post != null)
                  SingleChildScrollView(
                    scrollDirection: .horizontal,
                    child: Row(
                      spacing: 8,
                      children: _gallery.isEmpty
                          ? post!.gallery.map((photo) {
                              return Card(
                                margin: .all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: .circular(18),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: CachedNetworkImage(
                                  width: 80,
                                  height: 80,
                                  imageUrl: AssetUtil.getAssetUrl(
                                    photo.filePath,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList()
                          : _gallery.map((photo) {
                              return Card(
                                margin: .all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: .circular(18),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.file(
                                  photo,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                    ),
                  )
                else
                  Warning(variant: .info, message: loc.selectAtLeastOnePhoto),
              ],
            ),

            Column(
              children: [
                SectionTitle(
                  title: loc.postDetails,
                  icon: HugeIcons.strokeRoundedInformationCircle,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    spacing: 8,
                    children: [
                      DropdownButtonFormField<PostType>(
                        initialValue: _type,
                        items: [
                          DropdownMenuItem(
                            value: .house,
                            child: Text(loc.typeHouse),
                          ),
                          DropdownMenuItem(
                            value: .apartment,
                            child: Text(loc.typeApartment),
                          ),
                          DropdownMenuItem(
                            value: .villa,
                            child: Text(loc.typeVilla),
                          ),
                          DropdownMenuItem(
                            value: .office,
                            child: Text(loc.typeOffice),
                          ),
                        ],
                        validator: (v) => v == null ? loc.required : null,
                        onChanged: (v) => setState(() {
                          _type = v ?? .apartment;
                        }),
                        onSaved: (v) => _type = v ?? .apartment,
                        decoration: InputDecoration(labelText: loc.type),
                      ),
                      TextFormField(
                        keyboardType: .number,
                        decoration: InputDecoration(labelText: loc.space),
                        validator: (v) =>
                            v?.isEmpty == true ? loc.required : null,
                        onSaved: (v) => _space = double.tryParse(v ?? ''),
                        initialValue: post?.space.toString(),
                      ),
                      TextFormField(
                        keyboardType: .number,
                        decoration: InputDecoration(labelText: loc.rooms),
                        validator: (v) =>
                            v?.isEmpty == true ? loc.required : null,
                        onSaved: (v) => _rooms = int.tryParse(v ?? ''),
                        initialValue: post?.rooms.toString(),
                      ),
                      TextFormField(
                        keyboardType: .number,
                        decoration: InputDecoration(labelText: loc.bath),
                        validator: (v) =>
                            v?.isEmpty == true ? loc.required : null,
                        onSaved: (v) => _bathrooms = int.tryParse(v ?? ''),
                        initialValue: post?.bathrooms.toString(),
                      ),
                      TextFormField(
                        keyboardType: .number,
                        decoration: InputDecoration(labelText: loc.price),
                        validator: (v) =>
                            v?.isEmpty == true ? loc.required : null,
                        onSaved: (v) => _price = double.tryParse(v ?? ''),
                        initialValue: post?.price.toString(),
                      ),
                      LocationSearchField(
                        controller: _locationController,
                        onLocationSelected: _onLocationSelected,
                      ),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: .circular(16),
                            border: .all(
                              color: ColorScheme.of(context).outline,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: .circular(16),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _location!,
                                initialZoom: 15,
                                onPositionChanged: (camera, _) {
                                  setState(() {
                                    _location = camera.center;
                                  });
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: osmUrlTemplate,
                                  userAgentPackageName: appId,
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      alignment: .topCenter,
                                      point: _location!,
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
                                    TextSourceAttribution(
                                      loc.openStreetMapContributors,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: .end,
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(loc.cancel),
                          ),
                          FilledButton(
                            onPressed: _submit,
                            child: Text(
                              post != null
                                  ? loc.editApartment
                                  : loc.publishApartment,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    final post = widget.post;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_featured.isEmpty && post == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.selectAtLeastOnePhoto)));
      return;
    }

    _formKey.currentState?.save();

    if (_space == null ||
        _rooms == null ||
        _bathrooms == null ||
        _price == null ||
        _type == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.error)));
      return;
    }

    final featured = <MultipartFile>[];
    for (int i = 0; i < _featured.length; i++) {
      final image = _featured[i];
      final bytes = await image.readAsBytes();
      final filename = image.path.split('/').last;
      featured.add(MultipartFile.fromBytes(bytes, filename: filename));
    }

    final gallery = <MultipartFile>[];
    for (int i = 0; i < _gallery.length; i++) {
      final image = _gallery[i];
      final bytes = await image.readAsBytes();
      final filename = image.path.split('/').last;
      gallery.add(MultipartFile.fromBytes(bytes, filename: filename));
    }

    if (mounted) {
      await showBlockingLoadingUntil(
        context,
        action: () async {
          return switch (post == null) {
            true => await createPost(
              ref,
              type: _type!,
              space: _space!,
              rooms: _rooms!,
              bathrooms: _bathrooms!,
              price: _price!,
              latitude: _location!.latitude,
              longitude: _location!.longitude,
              featured: featured,
              gallery: gallery,
            ),
            false => await updatePost(
              ref,
              postId: post!.id,
              type: _type!,
              space: _space!,
              rooms: _rooms!,
              bathrooms: _bathrooms!,
              price: _price!,
              latitude: _location!.latitude,
              longitude: _location!.longitude,
              featured: featured,
              gallery: gallery,
            ),
          };
        },
        onCompleted: (result) {
          // success
          if (result == null) {
            // TODO: navigate to the post
            Navigator.of(context).pop();
            ref.invalidate(getOwnPosts);
            return;
          }

          final message = switch (result.type) {
            PostError.networkError => loc.networkError,
            PostError.badRequest => (loc.checkYourRequest),
            _ => result.message,
          };

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    }
  }
}
