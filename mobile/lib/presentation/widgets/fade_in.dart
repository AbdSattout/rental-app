import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FadeIn extends ConsumerStatefulWidget {
  const FadeIn({
    super.key,
    required this.duration,
    required this.child,
    this.curve = Curves.easeInOut,
  });

  final Duration duration;
  final Widget child;
  final Curve curve;

  @override
  ConsumerState<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends ConsumerState<FadeIn> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    );
  }
}
