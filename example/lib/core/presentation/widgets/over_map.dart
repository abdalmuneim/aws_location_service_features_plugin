import 'package:flutter/widgets.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Wrap Flutter UI drawn on top of a map with this.
///
/// On the web the map is an HTML element, and without it clicks and drags
/// on overlapping widgets would also reach the map. Elsewhere it is a no-op.
class OverMap extends StatelessWidget {
  const OverMap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => PointerInterceptor(child: child);
}
