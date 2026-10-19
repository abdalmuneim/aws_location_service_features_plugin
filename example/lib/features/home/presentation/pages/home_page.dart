import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../cloud_tracking/presentation/pages/cloud_tracking_page.dart';
import '../../../geofencing/presentation/pages/geofences_page.dart';
import '../../../maps/presentation/pages/map_explorer_page.dart';
import '../../../maps/presentation/pages/static_map_page.dart';
import '../../../places/presentation/cubit/geocode_cubit.dart';
import '../../../places/presentation/pages/geocode_page.dart';
import '../../../places/presentation/pages/nearby_page.dart';
import '../../../places/presentation/pages/search_page.dart';
import '../../../routes/presentation/pages/directions_page.dart';
import '../../../routes/presentation/pages/isolines_page.dart';
import '../../../routes/presentation/pages/optimize_page.dart';
import '../../../routes/presentation/pages/route_matrix_page.dart';
import '../../../routes/presentation/pages/snap_to_roads_page.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../settings/presentation/widgets/language_selector.dart';
import '../../../tracking/presentation/pages/tracker_page.dart';

/// Text resolved in the current UI language.
typedef _Text = String Function(AppLocalizations l10n);

class _Feature {
  const _Feature(this.icon, this.title, this.apis, this.description, this.page);

  final IconData icon;
  final _Text title;

  /// AWS operation names; these stay in English.
  final _Text apis;
  final _Text description;
  final Widget Function() page;
}

class _Section {
  const _Section(this.title, this.icon, this.color, this.features);

  final _Text title;
  final IconData icon;
  final Color color;
  final List<_Feature> features;
}

final _sections = [
  _Section((l) => l.homeSectionMaps, Icons.map, const Color(0xFF1A73E8), [
    _Feature(
      Icons.explore,
      (l) => l.mapExplorerTitle,
      (_) => 'GetStyleDescriptor · tiles · glyphs · sprites',
      (l) => l.homeMapExplorerDescription,
      () => const MapExplorerPage(),
    ),
    _Feature(
      Icons.image,
      (l) => l.staticMapTitle,
      (_) => 'GetStaticMap',
      (l) => l.homeStaticMapDescription,
      () => const StaticMapPage(),
    ),
  ]),
  _Section((l) => l.homeSectionPlaces, Icons.place, const Color(0xFFE8710A), [
    _Feature(
      Icons.search,
      (l) => l.homeSearchTitle,
      (_) => 'SearchText · Suggest · Autocomplete · GetPlace',
      (l) => l.homeSearchDescription,
      () => const SearchPage(),
    ),
    _Feature(
      Icons.near_me,
      (l) => l.homeNearbyTitle,
      (_) => 'SearchNearby',
      (l) => l.homeNearbyDescription,
      () => const NearbyPage(),
    ),
    _Feature(
      Icons.home_work,
      (l) => l.homeGeocodeTitle,
      (_) => 'Geocode',
      (l) => l.homeGeocodeDescription,
      () => const GeocodePage(),
    ),
    _Feature(
      Icons.pin_drop,
      (l) => l.homeReverseGeocodeTitle,
      (_) => 'ReverseGeocode',
      (l) => l.homeReverseGeocodeDescription,
      () => const GeocodePage(initialMode: GeocodeMode.reverse),
    ),
  ]),
  _Section(
    (l) => l.homeSectionRoutes,
    Icons.alt_route,
    const Color(0xFF0F9D58),
    [
      _Feature(
        Icons.directions,
        (l) => l.directionsTitle,
        (_) => 'CalculateRoutes',
        (l) => l.homeDirectionsDescription,
        () => const DirectionsPage(),
      ),
      _Feature(
        Icons.blur_circular,
        (l) => l.isolinesTitle,
        (_) => 'CalculateIsolines',
        (l) => l.homeIsolinesDescription,
        () => const IsolinesPage(),
      ),
      _Feature(
        Icons.grid_on,
        (l) => l.routeMatrixTitle,
        (_) => 'CalculateRouteMatrix',
        (l) => l.homeRouteMatrixDescription,
        () => const RouteMatrixPage(),
      ),
      _Feature(
        Icons.auto_fix_high,
        (l) => l.optimizeTitle,
        (_) => 'OptimizeWaypoints',
        (l) => l.homeOptimizeDescription,
        () => const OptimizePage(),
      ),
      _Feature(
        Icons.timeline,
        (l) => l.snapTitle,
        (_) => 'SnapToRoads',
        (l) => l.homeSnapDescription,
        () => const SnapToRoadsPage(),
      ),
    ],
  ),
  _Section(
    (l) => l.homeSectionGeofencing,
    Icons.fence,
    const Color(0xFF7B1FA2),
    [
      _Feature(
        Icons.fence,
        (l) => l.geofencesTitle,
        (l) => l.homeGeofencesApis,
        (l) => l.homeGeofencesDescription,
        () => const GeofencesPage(),
      ),
      _Feature(
        Icons.track_changes,
        (l) => l.trackerTitle,
        (_) => 'GPS · SnapToRoads · ReverseGeocode',
        (l) => l.homeTrackerDescription,
        () => const TrackerPage(),
      ),
      _Feature(
        Icons.cloud_upload_outlined,
        (l) => l.cloudTrackingTitle,
        (_) => 'Mobile Tracking SDK · BatchUpdateDevicePosition',
        (l) => l.homeCloudTrackingDescription,
        () => const CloudTrackingPage(),
      ),
    ],
  ),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final region = context.select((SettingsCubit c) => c.state.region);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          const LanguageMenuButton(),
          IconButton(
            tooltip: context.l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      // Android lays out the first frame at zero width, and SliverGrid
      // asserts on a zero cross-axis extent; wait for real constraints.
      body: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth <= 0
            ? const SizedBox.shrink()
            : _content(context, region),
      ),
    );
  }

  Widget _content(BuildContext context, String region) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [AppTheme.seed, Color(0xFF37475A)],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amazon Location Service',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.homeHeroSubtitle,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              avatar: const Icon(Icons.public, size: 16),
                              label: Text(region),
                            ),
                            Chip(
                              avatar: const Icon(Icons.key, size: 16),
                              label: Text(l10n.commonApiKey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.travel_explore,
                    size: 64,
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ),
          ),
        ),
        for (final section in _sections) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Icon(section.icon, color: section.color, size: 20),
                  const SizedBox(width: 8),
                  Text(section.title(l10n), style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 148,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: section.features.length,
              itemBuilder: (context, i) => _FeatureCard(
                feature: section.features[i],
                color: section.color,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.color});

  final _Feature feature;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => feature.page()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.14),
                    child: Icon(feature.icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature.title(l10n),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                feature.apis(l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  feature.description(l10n),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
