import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../routes/presentation/pages/directions_page.dart';
import '../../../routes/presentation/pages/isolines_page.dart';
import '../pages/nearby_page.dart';
import 'place_details_sheet.dart';

/// Directions / Nearby / Reachable-area shortcuts for a place.
List<PlaceAction> placeActions(BuildContext context) {
  void push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  NamedLocation named(Place p) =>
      NamedLocation(point: p.position!, label: p.title);

  final l10n = context.l10n;
  return [
    PlaceAction(
      icon: Icons.directions,
      label: l10n.directionsTitle,
      onSelected: (p) => push(DirectionsPage(destination: named(p))),
    ),
    PlaceAction(
      icon: Icons.near_me,
      label: l10n.placeActionNearby,
      onSelected: (p) => push(NearbyPage(center: p.position)),
    ),
    PlaceAction(
      icon: Icons.blur_circular,
      label: l10n.placeActionReachableArea,
      onSelected: (p) => push(IsolinesPage(origin: named(p))),
    ),
  ];
}
