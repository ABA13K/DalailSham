import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/service_product.dart';
import '../cubit/service_menu_cubit.dart';
import 'service_profile_shared.dart';

/// What the service sells: its categories as pills, then the products of the
/// picked one, page by page.
class ServiceMenuSection extends StatelessWidget {
  const ServiceMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ServiceMenuCubit, ServiceMenuState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ServiceSectionHeader(
            icon: Icons.restaurant_menu_rounded,
            title: l10n.sectionMenu,
            trailing: state.status == ServiceMenuStatus.ready
                ? Text(
                    l10n.productsCount(state.total),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (state.categories.isNotEmpty) ...[
            _CategoryPills(state: state),
            const SizedBox(height: 12),
          ],
          switch (state.status) {
            ServiceMenuStatus.initial ||
            ServiceMenuStatus.loading => const _MenuShimmer(),
            ServiceMenuStatus.failure => ServiceSectionMessage(
              icon: Icons.cloud_off_rounded,
              message: l10n.menuError,
              action: FilledButton.tonalIcon(
                onPressed: () => context.read<ServiceMenuCubit>().retry(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ),
            ServiceMenuStatus.ready => state.products.isEmpty
                ? ServiceSectionMessage(
                    icon: Icons.storefront_outlined,
                    message: l10n.productsEmpty,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final product in state.products) ...[
                        _ProductCard(product: product),
                        const SizedBox(height: 10),
                      ],
                      if (state.hasMore)
                        ServiceLoadMoreButton(
                          isLoading: state.isLoadingMore,
                          onPressed: () =>
                              context.read<ServiceMenuCubit>().loadMore(),
                        ),
                    ],
                  ),
          },
        ],
      ),
    );
  }
}

class _CategoryPills extends StatelessWidget {
  const _CategoryPills({required this.state});

  final ServiceMenuState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ServiceMenuCubit>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            key: const ValueKey('menu-category-all'),
            label: Text(l10n.categoryAll),
            selected: state.selectedCategory == null,
            onSelected: (_) => cubit.selectCategory(null),
          ),
          for (final category in state.categories) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              key: ValueKey('menu-category-${category.slug}'),
              label: Text('${category.name} · ${category.productsCount}'),
              selected: state.selectedCategory == category.slug,
              onSelected: (_) => cubit.selectCategory(category.slug),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ServiceProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final price = NumberFormat.decimalPattern(locale).format(product.price);
    final inStock = product.inStock;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 76,
                height: 76,
                child: Opacity(
                  opacity: inStock ? 1 : 0.45,
                  child: ServicePhoto(
                    url: product.imageUrl,
                    icon: Icons.local_cafe_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '$price ${l10n.currencySyp}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: inStock
                              ? const Color(0xFF1B8A5A).withValues(alpha: 0.12)
                              : scheme.errorContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          inStock ? l10n.availableLabel : l10n.outOfStock,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: inStock
                                ? const Color(0xFF1B8A5A)
                                : scheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuShimmer extends StatelessWidget {
  const _MenuShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerBox(height: 96, borderRadius: 16),
        SizedBox(height: 10),
        ShimmerBox(height: 96, borderRadius: 16),
        SizedBox(height: 10),
        ShimmerBox(height: 96, borderRadius: 16),
      ],
    );
  }
}