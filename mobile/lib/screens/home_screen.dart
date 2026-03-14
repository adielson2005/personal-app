import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../utils/theme.dart';
import 'video_list_screen.dart';
import 'video_player_screen.dart';
import 'upload_video_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categoryProvider = context.read<CategoryProvider>();
    final videoProvider = context.read<VideoProvider>();

    await categoryProvider.loadCategories(withCount: true);
    await videoProvider.loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isTrainer = authProvider.isTrainer;

    final screens = [
      const _HomeContent(),
      const VideoListScreen(),
      if (isTrainer) const UploadVideoScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.textMuted.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Início'),
                _buildNavItem(1, Icons.play_circle_filled, Icons.play_circle_outline, 'Vídeos'),
                if (isTrainer)
                  _buildNavItem(2, Icons.add_circle, Icons.add_circle_outline, 'Upload'),
                _buildNavItem(isTrainer ? 3 : 2, Icons.person, Icons.person_outline, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final videoProvider = context.watch<VideoProvider>();
    final userName = authProvider.user?.name.split(' ').first ?? 'Usuário';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await categoryProvider.loadCategories(withCount: true);
          await videoProvider.loadVideos(refresh: true);
        },
        color: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context, userName, authProvider),
            ),
            // Categories Section
            SliverToBoxAdapter(
              child: _buildCategoriesSection(context, categoryProvider),
            ),
            // Recent Videos Header
            SliverToBoxAdapter(
              child: _buildSectionHeader('Recentes', null, () {}),
            ),
            // Videos List
            if (videoProvider.status == VideoStatus.loading &&
                videoProvider.videos.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textSecondary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else if (videoProvider.videos.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyVideos())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= 5) return null;
                      final video = videoProvider.videos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: VideoCard(
                          video: video,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerScreen(video: video),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: videoProvider.videos.length > 5
                        ? 5
                        : videoProvider.videos.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String userName, AuthProvider authProvider) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(
              Icons.logout,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Widget _buildCategoriesSection(
      BuildContext context, CategoryProvider categoryProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Categorias', null, () {}),
        const SizedBox(height: 4),
        if (categoryProvider.isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.textSecondary,
                strokeWidth: 2,
              ),
            ),
          )
        else if (categoryProvider.categories.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Nenhuma categoria',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categoryProvider.categories.length,
              itemBuilder: (context, index) {
                final category = categoryProvider.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 100,
                    child: CategoryCard(
                      category: category,
                      onTap: () {
                        context
                            .read<VideoProvider>()
                            .loadVideosByMuscleGroup(category.slug);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(
      String title, String? action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                action,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyVideos() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Figura minimalista
          CustomPaint(
            size: const Size(48, 48),
            painter: _EmptyStatePainter(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum vídeo',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Conteúdo aparecerá aqui',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor para estado vazio minimalista
class _EmptyStatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final s = size.width;
    
    // Retângulo representando vídeo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.1, s * 0.2, s * 0.8, s * 0.5),
        const Radius.circular(4),
      ),
      paint,
    );
    
    // Triângulo de play
    final playPath = Path()
      ..moveTo(s * 0.4, s * 0.35)
      ..lineTo(s * 0.65, s * 0.45)
      ..lineTo(s * 0.4, s * 0.55)
      ..close();
    canvas.drawPath(playPath, paint);
    
    // Linha inferior
    canvas.drawLine(
      Offset(s * 0.2, s * 0.85),
      Offset(s * 0.8, s * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
