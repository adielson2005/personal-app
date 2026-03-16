import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/theme.dart';

// Widget de ícone de categoria: usa imagem personalizada em assets/icons/
// Mapeie aqui o slug → nome exato do arquivo que você colocou na pasta.
// Se o slug não estiver no mapa ou o arquivo não existir, usa o ícone vetorial como fallback.
class CategoryIcon extends StatelessWidget {
  final String slug;
  final double size;

  static const Map<String, String> _fileNames = {
    'peito':   'Peito1.png',
    'costas':  'Costa1.png',
    'abdomen': 'Abdômen1.png',
    'gluteo':  'Glúteo1.png',
    'ombro':   'Ombro1.png',
    // Adicione aqui os demais quando tiver os arquivos:
    // 'perna':   'Perna1.png',
    // 'biceps':  'Biceps1.png',
    // 'triceps': 'Triceps1.png',
    // 'cardio':  'Cardio1.png',
    // 'outro':   'Outro1.png',
  };

  // Ajuste fino por categoria para imagens que tenham margem interna desigual.
  // Se necessário, ajuste os valores para algo como Alignment(0.05, -0.08).
  static const Map<String, Alignment> _customAlignments = {
    'peito':   Alignment.center,
    'costas':  Alignment.center,
    'abdomen': Alignment(0.0, -0.4),
    'gluteo':  Alignment.center,
    'ombro':   Alignment.center,
  };

  const CategoryIcon({super.key, required this.slug, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final slugKey = slug.toLowerCase();
    final fileName = _fileNames[slugKey];
    final imageAlignment = _customAlignments[slugKey] ?? Alignment.center;
    if (fileName == null) {
      return MinimalIcon(slug: slug, size: size);
    }
    return ClipOval(
      child: Image.asset(
        'assets/icons/$fileName',
        width: size,
        height: size,
        fit: BoxFit.cover,
        alignment: imageAlignment,
        errorBuilder: (context, error, stackTrace) {
          return MinimalIcon(slug: slug, size: size);
        },
      ),
    );
  }
}

// Ícones minimalistas geométricos para cada categoria (fallback)
class MinimalIcon extends StatelessWidget {
  final String slug;
  final double size;

  const MinimalIcon({super.key, required this.slug, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MinimalIconPainter(slug),
    );
  }
}

class _MinimalIconPainter extends CustomPainter {
  final String slug;

  _MinimalIconPainter(this.slug);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final s = size.width;

    switch (slug.toLowerCase()) {
      case 'peito':
        // Dois arcos representando peitorais
        canvas.drawArc(Rect.fromCenter(center: Offset(s * 0.35, s * 0.5), width: s * 0.4, height: s * 0.5), 0.5, 2.2, false, paint);
        canvas.drawArc(Rect.fromCenter(center: Offset(s * 0.65, s * 0.5), width: s * 0.4, height: s * 0.5), 0.4, -2.2, false, paint);
        break;
      case 'costas':
        // V invertido minimalista
        final path = Path()
          ..moveTo(s * 0.2, s * 0.3)
          ..lineTo(s * 0.5, s * 0.5)
          ..lineTo(s * 0.8, s * 0.3)
          ..moveTo(s * 0.35, s * 0.5)
          ..lineTo(s * 0.35, s * 0.75)
          ..moveTo(s * 0.65, s * 0.5)
          ..lineTo(s * 0.65, s * 0.75);
        canvas.drawPath(path, paint);
        break;
      case 'perna':
        // Duas linhas paralelas
        canvas.drawLine(Offset(s * 0.35, s * 0.2), Offset(s * 0.3, s * 0.8), paint);
        canvas.drawLine(Offset(s * 0.65, s * 0.2), Offset(s * 0.7, s * 0.8), paint);
        canvas.drawOval(Rect.fromCenter(center: Offset(s * 0.5, s * 0.15), width: s * 0.4, height: s * 0.15), fillPaint);
        break;
      case 'ombro':
        // Arco superior com linhas
        canvas.drawArc(Rect.fromCenter(center: center, width: s * 0.7, height: s * 0.4), 3.14, 3.14, false, paint);
        canvas.drawLine(Offset(s * 0.15, s * 0.5), Offset(s * 0.15, s * 0.7), paint);
        canvas.drawLine(Offset(s * 0.85, s * 0.5), Offset(s * 0.85, s * 0.7), paint);
        break;
      case 'biceps':
        // Braço flexionado minimalista
        final path = Path()
          ..moveTo(s * 0.3, s * 0.7)
          ..quadraticBezierTo(s * 0.35, s * 0.4, s * 0.5, s * 0.3)
          ..quadraticBezierTo(s * 0.55, s * 0.25, s * 0.6, s * 0.35);
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(s * 0.5, s * 0.45), s * 0.12, fillPaint);
        break;
      case 'triceps':
        // Braço estendido
        canvas.drawLine(Offset(s * 0.25, s * 0.4), Offset(s * 0.75, s * 0.4), paint);
        canvas.drawLine(Offset(s * 0.75, s * 0.4), Offset(s * 0.75, s * 0.65), paint);
        canvas.drawArc(Rect.fromCenter(center: Offset(s * 0.55, s * 0.55), width: s * 0.25, height: s * 0.2), 0, 3.14, false, paint);
        break;
      case 'cardio':
        // Pulso cardíaco minimalista
        final path = Path()
          ..moveTo(s * 0.1, s * 0.5)
          ..lineTo(s * 0.3, s * 0.5)
          ..lineTo(s * 0.4, s * 0.25)
          ..lineTo(s * 0.5, s * 0.7)
          ..lineTo(s * 0.6, s * 0.35)
          ..lineTo(s * 0.7, s * 0.5)
          ..lineTo(s * 0.9, s * 0.5);
        canvas.drawPath(path, paint);
        break;
      case 'abdomen':
        // Grid minimalista 2x3
        for (var i = 0; i < 2; i++) {
          for (var j = 0; j < 3; j++) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(
                  center: Offset(s * (0.35 + i * 0.3), s * (0.25 + j * 0.25)),
                  width: s * 0.2,
                  height: s * 0.18,
                ),
                const Radius.circular(2),
              ),
              paint,
            );
          }
        }
        break;
      case 'gluteo':
        // Dois semicírculos
        canvas.drawArc(Rect.fromCenter(center: Offset(s * 0.35, s * 0.5), width: s * 0.35, height: s * 0.4), 0, 3.14, false, paint);
        canvas.drawArc(Rect.fromCenter(center: Offset(s * 0.65, s * 0.5), width: s * 0.35, height: s * 0.4), 0, 3.14, false, paint);
        break;
      default:
        // Círculo com cruz
        canvas.drawCircle(center, s * 0.3, paint);
        canvas.drawLine(Offset(s * 0.5, s * 0.3), Offset(s * 0.5, s * 0.7), paint);
        canvas.drawLine(Offset(s * 0.3, s * 0.5), Offset(s * 0.7, s * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CategoryCard extends StatefulWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.cardBackground.withValues(alpha: 0.85)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      CategoryIcon(slug: widget.category.slug, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.1,
                              ),
                            ),
                            if (widget.category.videoCount > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${widget.category.videoCount} vídeo${widget.category.videoCount == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final String slug;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.slug,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.textMuted.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
