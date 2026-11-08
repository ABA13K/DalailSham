import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/presentation/token_cubit.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/option_sheet.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../categories/domain/usecases/get_category_page.dart';
import '../../../location/presentation/location_cubit.dart';
import '../../../regions/domain/entities/region.dart';
import '../../../regions/domain/usecases/get_region_page.dart';
import '../../domain/entities/service_sort.dart';
import '../../domain/usecases/search_services.dart';
import '../cubit/services_search_cubit.dart';
import '../widgets/services_result_list.dart';

const _anyRating = 'any';
const _ratingSteps = <double>[3, 4, 4.5];

/// `GET /services/search` and its signed-in twin — the words typed in the field
/// narrowed by category, region, order and minimum rating.
class ServicesSearchPage extends StatefulWidget {
  const ServicesSearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<ServicesSearchPage> createState() => _ServicesSearchPageState();
}

class _ServicesSearchPageState extends State<ServicesSearchPage> {
  static const _debounce = Duration(milliseconds: 300);

  late final ServicesSearchCubit _cubit;
  final TextEditingController _controller = TextEditingController();
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;
    _cubit = ServicesSearchCubit(getIt<SearchServices>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Coming from the home field carries words, so the first build already owes
    // the user a list.
    if (_started) return;
    _started = true;
    _run(_controller.text);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  /// The language, the gate and the location are read when the request is made,
  /// so a search started before signing in still asks as the signed-in user.
  Future<void> _run(String text) {
    final location = context.read<LocationCubit>().state;
    return _cubit.search(
      text,
      locale: Localizations.localeOf(context).languageCode,
      authenticated: context.read<TokenCubit>().state != null,
      userLat: location is LocationReady ? location.latitude : null,
      userLng: location is LocationReady ? location.longitude : null,
    );
  }

  /// Waits for a pause in typing, so a fast typist does not search per letter.
  void _onChanged(String value) {
    setState(() {});
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      if (mounted) _run(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: TextField(
            key: const ValueKey('search-field'),
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: (value) {
              _timer?.cancel();
              _run(value);
            },
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              isDense: true,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      key: const ValueKey('search-clear'),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _timer?.cancel();
                        _controller.clear();
                        _run('');
                        setState(() {});
                      },
                    ),
            ),
          ),
          bottom: const _FilterBar(),
        ),
        body: CenteredContent(
          child: BlocBuilder<ServicesSearchCubit, ServicesSearchState>(
            builder: (context, state) => switch (state.status) {
              ServicesSearchStatus.initial => ServicesMessage(
                icon: Icons.search_rounded,
                message: l10n.searchPrompt,
              ),
              ServicesSearchStatus.loading => const ServicesShimmer(),
              ServicesSearchStatus.failure => ServicesMessage(
                icon: Icons.cloud_off_rounded,
                message: l10n.placesError,
                action: FilledButton.icon(
                  key: const ValueKey('search-retry'),
                  onPressed: () => _run(state.text),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              ServicesSearchStatus.ready =>
                state.results.isEmpty
                    ? ServicesMessage(
                        icon: Icons.search_off_rounded,
                        message: l10n.searchEmpty,
                      )
                    : ServicesResultList(
                        services: state.results,
                        hasMore: state.hasMore,
                        isLoadingMore: state.isLoadingMore,
                        onLoadMore: () =>
                            context.read<ServicesSearchCubit>().loadMore(),
                      ),
            },
          ),
        ),
      ),
    );
  }
}

/// The four filters, each showing what is chosen, and the button that clears
/// them together.
class _FilterBar extends StatelessWidget implements PreferredSizeWidget {
  const _FilterBar();

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ServicesSearchCubit>();

    return BlocBuilder<ServicesSearchCubit, ServicesSearchState>(
      builder: (context, state) {
        final sort = state.sort;
        final minRating = state.minRating;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              FilterChip(
                key: const ValueKey('filter-category'),
                label: Text(state.categoryName ?? l10n.filterCategory),
                avatar: const Icon(Icons.category_outlined, size: 18),
                selected: state.categoryId != null,
                showCheckmark: false,
                onSelected: (_) async {
                  final option = await showOptionSheet<ExploreCategory>(
                    context,
                    title: l10n.chooseCategory,
                    label: (category) => category.name,
                    load: _categories,
                  );
                  if (option != null) {
                    await cubit.chooseCategory(option.id, option.name);
                  }
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                key: const ValueKey('filter-region'),
                label: Text(state.regionName ?? l10n.filterRegion),
                avatar: const Icon(Icons.place_outlined, size: 18),
                selected: state.regionId != null,
                showCheckmark: false,
                onSelected: (_) async {
                  final option = await showOptionSheet<Region>(
                    context,
                    title: l10n.chooseRegion,
                    label: (region) => region.name,
                    load: _regions,
                  );
                  if (option != null) {
                    await cubit.chooseRegion(option.id, option.name);
                  }
                },
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                key: const ValueKey('filter-sort'),
                tooltip: l10n.filterSort,
                initialValue: sort?.wire,
                onSelected: (value) => cubit.chooseSort(
                  ServiceSort.values.firstWhere(
                    (candidate) => candidate.wire == value,
                  ),
                ),
                itemBuilder: (context) => [
                  for (final option in ServiceSort.values)
                    PopupMenuItem(
                      value: option.wire,
                      child: Text(_sortLabel(context, option)),
                    ),
                ],
                child: _FilterButton(
                  icon: Icons.sort_rounded,
                  label: sort == null
                      ? l10n.filterSort
                      : _sortLabel(context, sort),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                key: const ValueKey('filter-rating'),
                tooltip: l10n.filterRating,
                initialValue: minRating?.toString(),
                onSelected: (value) => cubit.chooseMinRating(
                  value == _anyRating ? null : double.parse(value),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(value: _anyRating, child: Text(l10n.ratingAny)),
                  for (final rating in _ratingSteps)
                    PopupMenuItem(
                      value: rating.toString(),
                      child: Text('${rating.toStringAsFixed(1)}+'),
                    ),
                ],
                child: _FilterButton(
                  icon: Icons.star_rounded,
                  label: minRating == null
                      ? l10n.filterRating
                      : '${minRating.toStringAsFixed(1)}+',
                ),
              ),
              if (state.hasFilters) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  key: const ValueKey('search-clear-filters'),
                  onPressed: cubit.clearFilters,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                  label: Text(l10n.clearFilters),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

String _sortLabel(BuildContext context, ServiceSort sort) {
  final l10n = AppLocalizations.of(context);
  return switch (sort) {
    ServiceSort.latest => l10n.sortLatest,
    ServiceSort.rating => l10n.sortTopRated,
    ServiceSort.distance => l10n.sortNearest,
  };
}

/// The public pick lists carry no search parameter, so the words typed in the
/// sheet narrow the first page the endpoint returns.
Future<List<ExploreCategory>> _categories(String locale, String? query) async {
  final result = await getIt<GetCategoryPage>().call(
    CategoryPageParams(locale: locale),
  );
  return result.fold(
    (_) => <ExploreCategory>[],
    (page) => _matching(page.categories, query, (category) => category.name),
  );
}

Future<List<Region>> _regions(String locale, String? query) async {
  final result = await getIt<GetRegionPage>().call(
    RegionPageParams(locale: locale),
  );
  return result.fold(
    (_) => <Region>[],
    (page) => _matching(page.regions, query, (region) => region.name),
  );
}

List<T> _matching<T>(
  List<T> options,
  String? query,
  String Function(T option) name,
) {
  if (query == null || query.isEmpty) return options;
  final needle = query.toLowerCase();
  return [
    for (final option in options)
      if (name(option).toLowerCase().contains(needle)) option,
  ];
}
