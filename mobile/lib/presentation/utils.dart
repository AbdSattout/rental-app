import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

String priceLabel(double price) {
  // remove .00
  if ((price % 1) == 0) {
    return '\$${price.toInt()}';
  }
  return '\$${price.toStringAsFixed(2)}';
}

class PinClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w / 2, h);
    path.quadraticBezierTo(0, h * 0.65, 0, h * 0.35);
    path.arcToPoint(
      Offset(w, h * 0.35),
      radius: Radius.circular(w / 2),
      clockwise: false,
    );
    path.quadraticBezierTo(w, h * 0.65, w / 2, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

final getLocations = FutureProvider.family<List<Location>, String>((
  ref,
  query,
) async {
  return await locationFromAddress(query);
});

Future<void> showBlockingLoadingUntil<T>(
  BuildContext context, {
  required Future<T> Function() action,
  void Function(T result)? onCompleted,
}) async {
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: .all(48),
              decoration: BoxDecoration(
                borderRadius: .circular(16),
                color: ColorScheme.of(context).surface,
              ),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
  final result = await action();
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
    onCompleted?.call(result);
  }
}
