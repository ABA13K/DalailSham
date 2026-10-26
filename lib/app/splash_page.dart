import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../l10n/generated/app_localizations.dart';

/// Branded launch screen shown on cold start; hands off to onboarding or home.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onboarding});

  static const duration = Duration(milliseconds: 1800);

  final OnboardingRepository onboarding;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashPage.duration,
  )
    ..addStatusListener(_handleStatus)
    ..forward();

  late final Animation<double> _markFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.35, curve: Curves.easeOut),
  );

  late final Animation<double> _markScale = Tween<double>(begin: 0.86, end: 1)
      .animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
  ));

  late final Animation<double> _halo = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.8, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic),
  );

  late final Animation<Offset> _textSlide =
      Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic),
    ),
  );

  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.15, 0.95, curve: Curves.easeInOut),
  );

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openNext();
    });
  }

  Future<void> _openNext() async {
    final completed = await widget.onboarding.hasCompleted();
    if (!mounted) return;
    context.go(completed ? '/' : '/onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.brand,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.brand, AppTheme.brandDeep],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _Glow(
              alignment: Alignment(-1.1, -0.9),
              size: 340,
              color: Color(0x1FFFFFFF),
            ),
            const _Glow(
              alignment: Alignment(1.2, 0.9),
              size: 400,
              color: Color(0x33001F1A),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _markFade,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: _SplashMark(halo: _halo),
                    ),
                  ),
                  const SizedBox(height: 36),
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          Text(
                            l10n.appTitle,
                            textAlign: TextAlign.center,
                            style: textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.appTagline,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  FadeTransition(
                    opacity: _textFade,
                    child: _ProgressBar(progress: _progress),
                  ),
                  const SizedBox(height: 44),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark({required this.halo});

  final Animation<double> halo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: halo,
        builder: (context, _) {
          final t = halo.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 132 + 60 * t,
                height: 132 + 60 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22 * (1 - t)),
                    width: 1.5,
                  ),
                ),
              ),
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          width: 128,
          height: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: Colors.white.withValues(alpha: 0.18)),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: progress.value.clamp(0.0, 1.0),
                  heightFactor: 1,
                  child: const ColoredBox(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
