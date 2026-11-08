import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../banners/domain/entities/banner_ad.dart';
import '../../../banners/presentation/cubit/banners_cubit.dart';

/// Auto-scrolling carousel of the live promotional banners, drawn as the hero
/// card at the top of the home feed.
class AdvertiseBar extends StatelessWidget {
  const AdvertiseBar({super.key});

  static const autoAdvance = Duration(seconds: 4);
  static const heroHeight = 168.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannersCubit, BannersState>(
      builder: (context, state) {
        if (state is BannersInitial || state is BannersLoading) {
          return const _BannerBarShimmer();
        }
        if (state is! BannersReady || state.banners.isEmpty) {
          return const SizedBox.shrink();
        }
        return _BannerCarousel(
          key: ValueKey(state.banners),
          banners: state.banners,
        );
      },
    );
  }
}

class _BannerBarShimmer extends StatelessWidget {
  const _BannerBarShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ShimmerBox(height: AdvertiseBar.heroHeight, borderRadius: 20),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({super.key, required this.banners});

  final List<BannerAd> banners;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  static const _slideDuration = Duration(milliseconds: 450);

  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(AdvertiseBar.autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: _slideDuration,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final textScaler = MediaQuery.textScalerOf(context);
    double line(
      TextStyle? style, {
      double? fontSize,
      double? height,
      int maxLines = 1,
    }) =>
        textScaler.scale(fontSize ?? style?.fontSize ?? 14) *
        (height ?? style?.height ?? 1.2) *
        maxLines;

    // Keep the card as tall as its text needs when the system font grows.
    final contentHeight =
        32 +
        line(textTheme.bodySmall, fontSize: 12, height: 1.3) +
        4 +
        line(textTheme.headlineSmall, fontSize: 24, height: 1.25, maxLines: 2) +
        6 +
        line(textTheme.labelMedium, fontSize: 12, height: 1.3);
    final adHeight = contentHeight + 4 > AdvertiseBar.heroHeight
        ? contentHeight + 4
        : AdvertiseBar.heroHeight;
    final banners = widget.banners;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Column(
        children: [
          SizedBox(
            height: adHeight,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _timer?.cancel();
                } else if (notification is ScrollEndNotification) {
                  _startAutoPlay();
                }
                return false;
              },
              child: PageView.builder(
                controller: _controller,
                itemCount: banners.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _BannerCard(
                    banner: banners[index],
                    subtitle: l10n.adLabel,
                  ),
                ),
              ),
            ),
          ),
          if (banners.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < banners.length; index++)
                  AnimatedContainer(
                    key: ValueKey('ad-dot-$index'),
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: index == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: index == _page
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.banner,
    required this.subtitle,
  });

  final BannerAd banner;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // Optional: If banner.text contains multiple lines separated by '\n',
    // split it into [subtitle, title, cta] or fall back to defaults.
    final lines = banner.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final topText = lines.length >= 2 ? lines[0] : subtitle;
    final mainTitle = lines.length >= 2 ? lines[1] : banner.text;
    final bottomCta = lines.length >= 3 ? lines[2] : null;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [scheme.primary, scheme.primaryContainer],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.campaign_rounded,
                size: 56,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
          if (banner.imageUrl != null)
            Image.network(
              banner.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
          // Directional gradient: darkens the start side (Right in RTL) and bottom
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                stops: const [0.0, 0.55, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [
                  const Color(0x00000000),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  topText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mainTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                if (bottomCta != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          bottomCta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}