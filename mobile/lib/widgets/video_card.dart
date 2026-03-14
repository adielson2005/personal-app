import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/exercise_video.dart';
import '../utils/theme.dart';

class VideoCard extends StatelessWidget {
  final ExerciseVideo video;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail compacto
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 120,
                    height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildThumbnail(),
                        // Play icon minimalista
                        Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.background.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.textPrimary,
                              size: 18,
                            ),
                          ),
                        ),
                        // Duration
                        if (video.formattedDuration != null)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                video.formattedDuration!,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag minimalista
                      Text(
                        video.muscleGroupDisplayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted.withValues(alpha: 0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (video.description != null &&
                          video.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          video.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Actions minimalistas
                      if (showActions) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (onEdit != null)
                              _MinimalActionButton(
                                icon: Icons.edit_outlined,
                                onTap: onEdit!,
                              ),
                            if (onEdit != null && onDelete != null)
                              const SizedBox(width: 8),
                            if (onDelete != null)
                              _MinimalActionButton(
                                icon: Icons.delete_outline,
                                onTap: onDelete!,
                                isDestructive: true,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow indicator
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: video.thumbnailUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: CustomPaint(
          size: const Size(24, 24),
          painter: _PlayIconPainter(),
        ),
      ),
    );
  }
}

// Ícone de play minimalista
class _PlayIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.8)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Botão de ação minimalista
class _MinimalActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MinimalActionButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.textMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDestructive ? AppColors.error : AppColors.textSecondary,
        ),
      ),
    );
  }
}
