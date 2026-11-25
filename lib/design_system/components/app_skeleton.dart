import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// Bloco de carregamento com brilho animado (skeleton), no formato do
/// conteúdo que vai aparecer.
///
/// Se o aparelho pedir menos animações (acessibilidade), fica parado.
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.sm,
  });

  /// Círculo (avatar, ícone).
  const AppSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = 999;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  static const _base = AppColors.border;
  static const _highlight = AppColors.surface;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(widget.radius);
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // A faixa clara atravessa o bloco da esquerda para a direita.
          final t = _controller.value * 3 - 1;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: shape,
              gradient: LinearGradient(
                colors: const [_base, _highlight, _base],
                stops: [t - 0.3, t, t + 0.3].map(_clamp).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  static double _clamp(double v) => v.clamp(0.0, 1.0);
}

/// Card de carregamento: avatar opcional e algumas linhas de texto, com a
/// mesma borda e o mesmo espaço interno dos cards do app.
class SkeletonCard extends StatelessWidget {
  final bool showAvatar;
  final int lines;

  const SkeletonCard({super.key, this.showAvatar = true, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            if (showAvatar) ...[
              const AppSkeleton.circle(size: 56),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < lines; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    FractionallySizedBox(
                      // Linhas de tamanhos diferentes, como texto de verdade.
                      widthFactor: const [0.7, 0.45, 0.3, 0.55][i % 4],
                      child: AppSkeleton(height: i == 0 ? 16 : 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
