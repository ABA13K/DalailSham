import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/centered_content.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/onboarding_repository.dart';

/// Three-step first-run introduction shown before the places feed.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.repository});

  final OnboardingRepository repository;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _pageCount = 3;

  int _page = 0;
  bool _finishing = false;

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await widget.repository.markCompleted();
    if (!mounted) return;
    context.go('/');
  }

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
      return;
    }
    setState(() => _page++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      _SlideData(
        title: l10n.onboardingWelcomeTitle,
        body: l10n.onboardingWelcomeBody,
      ),
      _SlideData(
        title: l10n.onboardingExploreTitle,
        body: l10n.onboardingExploreBody,
      ),
      _SlideData(
        title: l10n.onboardingLocationTitle,
        body: l10n.onboardingLocationBody,
      ),
    ];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.brandDeep,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _Background(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AnimatedOpacity(
                      opacity: isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: isLast || _finishing,
                        child: TextButton(
                          onPressed: _finishing ? null : _finish,
                          child: Text(
                            l10n.onboardingSkip,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: CenteredContent(
                    maxWidth: 520,
                    child: _OnboardingCard(
                      title: slides[_page].title,
                      body: slides[_page].body,
                      pageKey: ValueKey(_page),
                      progress: (_page + 1) / _pageCount,
                      tooltip: isLast
                          ? l10n.onboardingStart
                          : l10n.onboardingNext,
                      onPressed: _finishing ? null : _next,
                    ),
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

class _SlideData {
  const _SlideData({required this.title, required this.body});

  final String title;
  final String body;
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/onboarding_scene.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x99031B3D), Color(0x33031B3D), Color(0xCC031226)],
              stops: [0, 0.4, 1],
            ),
          ),
        ),
      ],
    );
  }
}

/// Notched glass card with a progress ring and floating action button.
class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.title,
    required this.body,
    required this.pageKey,
    required this.progress,
    required this.tooltip,
    required this.onPressed,
  });

  static const _buttonBoxSize = 88.0;
  static const _notchRadius = 52.0;
  static const _cornerRadius = 28.0;

  final String title;
  final String body;
  final Key pageKey;
  final double progress;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: _buttonBoxSize / 2),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: const _BottomNotchClipper(
                notchRadius: _notchRadius,
                cornerRadius: _cornerRadius,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 34, 28, 76),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.bottomCenter,
                      children: [...previousChildren, ?currentChild],
                    ),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: pageKey,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: _buttonBoxSize,
          height: _buttonBoxSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 1.2,
                  color: Colors.white.withValues(alpha: 0.32),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 3.5,
                    strokeCap: StrokeCap.round,
                    color: AppTheme.brand,
                  ),
                ),
              ),
              Tooltip(
                message: tooltip,
                child: Material(
                  color: AppTheme.brand,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onPressed,
                    child: const SizedBox(
                      width: 68,
                      height: 68,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rounded corners with a smooth S-curve notch cut into the bottom edge.
class _BottomNotchClipper extends CustomClipper<Path> {
  const _BottomNotchClipper({this.notchRadius = 52, this.cornerRadius = 28});

  final double notchRadius;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final notchSpread = notchRadius * 1.45;
    final notchDepth = notchRadius * 0.95;

    path
      ..moveTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      )
      ..lineTo(centerX + notchSpread, size.height)
      ..cubicTo(
        centerX + notchSpread * 0.55,
        size.height,
        centerX + notchRadius * 0.85,
        size.height - notchDepth,
        centerX,
        size.height - notchDepth,
      )
      ..cubicTo(
        centerX - notchRadius * 0.85,
        size.height - notchDepth,
        centerX - notchSpread * 0.55,
        size.height,
        centerX - notchSpread,
        size.height,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_BottomNotchClipper oldClipper) =>
      oldClipper.notchRadius != notchRadius ||
      oldClipper.cornerRadius != cornerRadius;
}
