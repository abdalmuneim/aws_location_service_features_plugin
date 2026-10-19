import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/core_labels.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/json_viewer.dart';
import '../../../../core/presentation/widgets/over_map.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/place_details_cubit.dart';
import 'place_icons.dart';
import 'place_labels.dart';

/// An action button in the place sheet, e.g. "Directions".
class PlaceAction {
  const PlaceAction({
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final void Function(Place place) onSelected;
}

/// Shows GetPlace details for [place] in a bottom sheet.
Future<void> showPlaceDetailsSheet(
  BuildContext context,
  Place place, {
  List<PlaceAction> actions = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => BlocProvider(
      create: (_) => PlaceDetailsCubit(sl(), place)..load(),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, controller) => OverMap(
          child: _PlaceDetailsBody(controller: controller, actions: actions),
        ),
      ),
    ),
  );
}

class _PlaceDetailsBody extends StatelessWidget {
  const _PlaceDetailsBody({required this.controller, required this.actions});

  final ScrollController controller;
  final List<PlaceAction> actions;

  @override
  Widget build(BuildContext context) {
    final units = context.select((SettingsCubit c) => c.state.units);
    return BlocBuilder<PlaceDetailsCubit, PlaceDetailsState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final p = state.place;
        final theme = Theme.of(context);
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(placeTypeIcon(p.placeType))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, style: theme.textTheme.titleLarge),
                      Text(
                        placeTypeLabel(l10n, p.placeType),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            LoadingBar(visible: state.status.isLoading),
            if (state.failure != null) FailureBanner(failure: state.failure!),
            if (p.categories.isNotEmpty || p.foodTypes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in p.categories)
                    Chip(
                      avatar: c.primary
                          ? const Icon(Icons.star, size: 16)
                          : null,
                      label: Text(c.displayName),
                    ),
                  for (final f in p.foodTypes)
                    Chip(
                      avatar: const Icon(Icons.restaurant_menu, size: 16),
                      label: Text(f),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in actions)
                  FilledButton.tonalIcon(
                    icon: Icon(a.icon),
                    label: Text(a.label),
                    onPressed: () {
                      Navigator.pop(context);
                      a.onSelected(p);
                    },
                  ),
                if (p.position != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.placeCopyCoordinates),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: p.position!.format(6)),
                      );
                      showSnack(context, l10n.placeCoordinatesCopied);
                    },
                  ),
              ],
            ),
            SectionTitle(l10n.placeAddress),
            if (p.address?.label != null) SelectableText(p.address!.label!),
            for (final (field, value)
                in p.address?.components ?? const <(AddressField, String)>[])
              _Row(field.localizedLabel(l10n), value),
            SectionTitle(l10n.placeLocation),
            if (p.position != null)
              _Row(l10n.placeCoordinates, Formatters.point(p.position, 6)),
            if (p.distance != null)
              _Row(
                l10n.commonDistance,
                Formatters.distance(l10n, p.distance, units),
              ),
            if (p.timeZone != null)
              _Row(
                l10n.placeTimeZone,
                '${p.timeZone!.name} (UTC${p.timeZone!.offset ?? ''})',
              ),
            if (p.accessPoints.isNotEmpty)
              _Row(l10n.placeAccessPoints, '${p.accessPoints.length}'),
            if (p.politicalView != null)
              _Row(
                l10n.commonPoliticalView,
                politicalViewName(l10n, p.politicalView!),
              ),
            if (!p.contacts.isEmpty) ...[
              SectionTitle(l10n.placeContact),
              for (final v in p.contacts.phones) _Row(l10n.placePhone, v),
              for (final v in p.contacts.websites) _Row(l10n.placeWebsite, v),
              for (final v in p.contacts.emails) _Row(l10n.placeEmail, v),
              for (final v in p.contacts.faxes) _Row(l10n.placeFax, v),
            ],
            if (p.openingHours.isNotEmpty) ...[
              SectionTitle(
                l10n.placeOpeningHours,
                trailing: switch (p.openingHours.first.openNow) {
                  true => Chip(label: Text(l10n.placeOpenNow)),
                  false => Chip(label: Text(l10n.placeClosed)),
                  null => null,
                },
              ),
              for (final h in p.openingHours)
                for (final line in h.display) Text(line),
            ],
            if (p.businessChains.isNotEmpty) ...[
              SectionTitle(l10n.placeBusinessChain),
              Text(p.businessChains.join(', ')),
            ],
            const SizedBox(height: 8),
            JsonViewer(data: p.raw, title: l10n.commonApiResponse('GetPlace')),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: SelectableText(value)),
      ],
    ),
  );
}
