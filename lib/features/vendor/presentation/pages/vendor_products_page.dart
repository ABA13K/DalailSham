import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/option_sheet.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../domain/entities/vendor_product.dart';
import '../../domain/entities/vendor_product_query.dart';
import '../../domain/repositories/vendor_product_repository.dart';
import '../cubit/vendor_products_cubit.dart';
import 'vendor_product_form_page.dart';

/// `GET /vendor/products` — what the signed-in vendor sells, narrowed by the
/// words typed, the category chosen and the approval state asked for.
class VendorProductsPage extends StatefulWidget {
  const VendorProductsPage({super.key});

  @override
  State<VendorProductsPage> createState() => _VendorProductsPageState();
}

class _VendorProductsPageState extends State<VendorProductsPage> {
  static const _debounce = Duration(milliseconds: 300);

  late final VendorProductsCubit _cubit;
  final TextEditingController _controller = TextEditingController();
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _cubit = VendorProductsCubit(getIt<VendorProductRepository>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The language the list is asked for lives in an inherited widget, which
    // only has a value once the first build is under way.
    if (_started) return;
    _started = true;
    _cubit.load(Localizations.localeOf(context).languageCode);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  /// Waits for a pause in typing, so a fast typist does not search per letter.
  void _onChanged(String value) {
    setState(() {});
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      if (mounted) _cubit.search(value);
    });
  }

  void _openForm([VendorProduct? product]) {
    _timer?.cancel();
    context.push(
      '/vendor/products/form',
      extra: VendorProductFormArgs(cubit: _cubit, product: product),
    );
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
            key: const ValueKey('products-search-field'),
            controller: _controller,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: (value) {
              _timer?.cancel();
              _cubit.search(value);
            },
            decoration: InputDecoration(
              hintText: l10n.productsSearchHint,
              isDense: true,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      key: const ValueKey('products-search-clear'),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _timer?.cancel();
                        _controller.clear();
                        _cubit.search('');
                        setState(() {});
                      },
                    ),
            ),
          ),
          bottom: const _ProductsFilterBar(),
        ),
        body: CenteredContent(
          child: BlocBuilder<VendorProductsCubit, VendorProductsState>(
            builder: (context, state) => switch (state.status) {
              VendorProductsStatus.initial || VendorProductsStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              VendorProductsStatus.failure => _ProductsMessage(
                message: l10n.placesError,
                action: FilledButton.icon(
                  key: const ValueKey('products-retry'),
                  onPressed: () =>
                      _cubit.load(Localizations.localeOf(context).languageCode),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              VendorProductsStatus.ready =>
                state.products.isEmpty
                    ? _ProductsMessage(
                        icon: state.hasFilters
                            ? Icons.search_off_rounded
                            : Icons.inventory_2_outlined,
                        message: state.hasFilters
                            ? l10n.searchEmpty
                            : l10n.productsEmpty,
                      )
                    : _ProductList(
                        state: state,
                        locale: Localizations.localeOf(context).languageCode,
                        onEdit: _openForm,
                      ),
            },
          ),
        ),
        floatingActionButton:
            BlocBuilder<VendorProductsCubit, VendorProductsState>(
              builder: (context, state) =>
                  state.status == VendorProductsStatus.ready && !state.isBusy
                  ? FloatingActionButton.extended(
                      key: const ValueKey('product-add'),
                      onPressed: () => _openForm(),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.addProduct),
                    )
                  : const SizedBox.shrink(),
            ),
      ),
    );
  }
}

/// The two filters the listing takes, each showing what is chosen, and the
/// button that clears them together with the words in the field.
class _ProductsFilterBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ProductsFilterBar();

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VendorProductsCubit>();

    return BlocBuilder<VendorProductsCubit, VendorProductsState>(
      builder: (context, state) {
        final approval = state.approval;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              FilterChip(
                key: const ValueKey('filter-product-category'),
                label: Text(state.categoryName ?? l10n.filterCategory),
                avatar: const Icon(Icons.category_outlined, size: 18),
                selected: state.categoryId != null,
                showCheckmark: false,
                onSelected: (_) async {
                  final option = await showOptionSheet<ExploreCategory>(
                    context,
                    title: l10n.chooseCategory,
                    label: (category) => category.name,
                    load: (locale, query) async {
                      final result = await getIt<VendorProductRepository>()
                          .categories(locale: locale, query: query);
                      return result.fold(
                        (_) => const <ExploreCategory>[],
                        (categories) => categories,
                      );
                    },
                  );
                  if (option != null) {
                    await cubit.chooseCategory(
                      id: option.id,
                      name: option.name,
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                key: const ValueKey('filter-product-status'),
                tooltip: l10n.filterStatus,
                initialValue: approval?.wire,
                onSelected: (value) => cubit.chooseApproval(
                  value == _anyStatus
                      ? null
                      : VendorProductStatus.values.firstWhere(
                          (candidate) => candidate.wire == value,
                        ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(value: _anyStatus, child: Text(l10n.statusAny)),
                  for (final status in VendorProductStatus.values)
                    PopupMenuItem(
                      value: status.wire,
                      child: Text(_statusLabel(context, status)),
                    ),
                ],
                child: _FilterButton(
                  icon: Icons.verified_outlined,
                  label: approval == null
                      ? l10n.filterStatus
                      : _statusLabel(context, approval),
                ),
              ),
              if (state.hasFilters) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  key: const ValueKey('products-clear-filters'),
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

const _anyStatus = 'any';

String _statusLabel(BuildContext context, VendorProductStatus status) {
  final l10n = AppLocalizations.of(context);
  return switch (status) {
    VendorProductStatus.pending => l10n.statusPending,
    VendorProductStatus.approved => l10n.statusApproved,
    VendorProductStatus.rejected => l10n.statusRejected,
  };
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

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.state,
    required this.locale,
    required this.onEdit,
  });

  final VendorProductsState state;
  final String locale;
  final void Function(VendorProduct product) onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<VendorProductsCubit>();
    final products = state.products;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            l10n.productsIntro,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: products.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index >= products.length) {
                return FilledButton.tonalIcon(
                  key: const ValueKey('products-load-more'),
                  onPressed: state.isLoadingMore ? null : cubit.loadMore,
                  icon: state.isLoadingMore
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more_rounded),
                  label: Text(l10n.loadMore),
                );
              }
              return _ProductRow(
                product: products[index],
                locale: locale,
                isBusy: state.isBusy,
                onEdit: onEdit,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.locale,
    required this.isBusy,
    required this.onEdit,
  });

  final VendorProduct product;
  final String locale;
  final bool isBusy;
  final void Function(VendorProduct product) onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final price = NumberFormat.decimalPattern(locale).format(product.price);

    final flags = <String>[
      if (!product.isApproved) l10n.productPendingApproval,
      if (!product.isActive) l10n.productHidden,
      if (!product.isAvailable) l10n.productUnavailable,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        key: ValueKey('product-row-${product.id}'),
        enabled: !isBusy,
        onTap: () => onEdit(product),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: SizedBox(
          height: 56,
          width: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: product.imageUrl == null
                ? ColoredBox(
                    color: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.local_bar_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )
                : Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
          ),
        ),
        title: Text(
          product.nameIn(locale),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              [
                if (product.categoryName != null) product.categoryName!,
                if (product.quantity != null)
                  '${l10n.quantityLabel}: ${product.quantity}',
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (flags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final flag in flags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        flag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        trailing: Text(
          '$price ${l10n.currencySyp}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProductsMessage extends StatelessWidget {
  const _ProductsMessage({required this.message, this.icon, this.action});

  final String message;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
          if (icon != null) const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
