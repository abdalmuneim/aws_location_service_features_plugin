import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import 'place_icons.dart';
import 'place_labels.dart';

/// A result row: index badge, title, category/address and distance.
class PlaceTile extends StatelessWidget {
  const PlaceTile({
    super.key,
    required this.place,
    this.index,
    this.onTap,
    this.trailing,
  });

  final Place place;
  final int? index;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final units = context.select((SettingsCubit c) => c.state.units);
    final scheme = Theme.of(context).colorScheme;
    final category =
        place.primaryCategory?.displayName ??
        placeTypeLabel(context.l10n, place.placeType);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: index == null
          ? CircleAvatar(child: Icon(placeTypeIcon(place.placeType)))
          : CircleAvatar(
              backgroundColor: scheme.tertiaryContainer,
              child: Text('${index! + 1}'),
            ),
      title: Text(place.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          category,
          if (place.address?.label != null) place.address!.label!,
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          trailing ??
          (place.distance == null
              ? null
              : Text(Formatters.distance(context.l10n, place.distance, units))),
      onTap: onTap,
    );
  }
}
