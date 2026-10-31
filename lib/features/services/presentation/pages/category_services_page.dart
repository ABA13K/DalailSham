import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../location/presentation/location_cubit.dart';
import '../../domain/usecases/get_category_service_page.dart';
import '../cubit/category_services_cubit.dart';
import '../widgets/category_service_card.dart';

/// The services published inside one category, loaded page by page.
class CategoryServicesPage extends StatelessWidget {
  const CategoryServicesPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final location = context.read<LocationCubit>().state;
    final userLat = location is LocationReady ? location.latitude : null;
    final userLng = location is LocationReady ? location.longitude : null;

    void fetch(CategoryServicesCubit cubit) => cubit.load(
      categoryId: categoryId,
      locale: locale,
      userLat: userLat,
      userLng: userLng,
    );

    return BlocProvider(
      create: (_) {
        final cubit = CategoryServicesCubit(getIt<GetCategoryServicePage>());
        fetch(cubit);
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CenteredContent(
          child: BlocBuilder<CategoryServicesCubit, CategoryServicesState>(
            builder: (context, state) => switch (state.status) {
              CategoryServicesStatus.initial ||
              CategoryServicesStatus.loading => const _ServicesShimmer(),
              CategoryServicesStatus.failure => _ServicesMessage(
                icon: Icons.cloud_off_rounded,
                message: l10n.placesError,
                action: FilledButton.icon(
                  onPressed: () => fetch(context.read<CategoryServicesCubit>()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              CategoryServicesStatus.ready =>
                state.services.isEmpty
                    ? _ServicesMessage(
                        icon: Icons.storefront_outlined,
                        message: l10n.servicesEmpty,
                      )
                    : _ServicesList(state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.state});

  final CategoryServicesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverList.builder(
            itemCount: state.services.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CategoryServiceCard(service: state.services[index]),
            ),
          ),
        ),
        if (state.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: FilledButton.tonal(
                onPressed: state.isLoadingMore
                    ? null
                    : () => context.read<CategoryServicesCubit>().loadMore(),
                child: state.isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.loadMore),
              ),
            ),
          ),
      ],
    );
  }
}

class _ServicesShimmer extends StatelessWidget {
  const _ServicesShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const ShimmerBox(height: 84, borderRadius: 12),
    );
  }
}

class _ServicesMessage extends StatelessWidget {
  const _ServicesMessage({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
