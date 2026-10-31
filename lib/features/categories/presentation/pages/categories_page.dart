import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/usecases/get_category_page.dart';
import '../cubit/all_categories_cubit.dart';
import '../widgets/explore_category_card.dart';

/// Full list of categories, loaded page by page.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return BlocProvider(
      create: (_) => AllCategoriesCubit(getIt<GetCategoryPage>())..load(locale),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.exploreCategories,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CenteredContent(
          child: BlocBuilder<AllCategoriesCubit, AllCategoriesState>(
            builder: (context, state) => switch (state.status) {
              AllCategoriesStatus.initial ||
              AllCategoriesStatus.loading => const _CategoriesShimmer(),
              AllCategoriesStatus.failure => _CategoriesMessage(
                icon: Icons.cloud_off_rounded,
                message: l10n.placesError,
                action: FilledButton.icon(
                  onPressed: () =>
                      context.read<AllCategoriesCubit>().load(locale),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              AllCategoriesStatus.ready =>
                state.categories.isEmpty
                    ? _CategoriesMessage(
                        icon: Icons.category_outlined,
                        message: l10n.categoriesEmpty,
                      )
                    : _CategoriesGrid(state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.state});

  final AllCategoriesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 150,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.categories.length,
            itemBuilder: (context, index) =>
                ExploreCategoryCard(category: state.categories[index]),
          ),
        ),
        if (state.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: FilledButton.tonal(
                onPressed: state.isLoadingMore
                    ? null
                    : () => context.read<AllCategoriesCubit>().loadMore(),
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

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 150,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (_, _) => const ShimmerBox(borderRadius: 18),
          ),
        ),
      ],
    );
  }
}

class _CategoriesMessage extends StatelessWidget {
  const _CategoriesMessage({
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
