import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../banners/domain/entities/banner_ad.dart';
import '../../../banners/presentation/cubit/banners_cubit.dart';

/// Auto-scrolling carousel of the live promotional banners.
class AdvertiseBar extends StatelessWidget {
  const AdvertiseBar({super.key});

  static const autoAdvance = Duration(seconds: 4);

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
      child: ShimmerBox(height: 104, borderRadius: 18),
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
    // Keep the strip as tall as its text needs when the system font grows.
    final contentHeight =
        12 +
        line(textTheme.labelSmall, fontSize: 10, height: 1.3) +
        2 +
        6 +
        line(textTheme.titleSmall, height: 1.35, maxLines: 2) +
        12;
    final adHeight = contentHeight + 4 > 104 ? contentHeight + 4 : 104.0;
    final banners = widget.banners;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
                    label: l10n.adLabel,
                  ),
                ),
              ),
            ),
          ),
          if (banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < banners.length; index++)
                  AnimatedContainer(
                    key: ValueKey('ad-dot-$index'),
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: index == _page
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
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
  const _BannerCard({required this.banner, required this.label});

  final BannerAd banner;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
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
                size: 40,
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
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                stops: const [0.25, 1],
                colors: [
                  const Color(0x00000000),
                  Colors.black.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  banner.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
