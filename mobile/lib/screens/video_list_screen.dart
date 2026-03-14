import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../widgets/widgets.dart';
import '../utils/theme.dart';
import '../utils/animations.dart';
import 'video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final _scrollController = ScrollController();
  String? _selectedMuscleGroup;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VideoProvider>().loadMore();
    }
  }

  void _onMuscleGroupChanged(String? muscleGroup) {
    setState(() => _selectedMuscleGroup = muscleGroup);
    context.read<VideoProvider>().loadVideos(
          muscleGroup: muscleGroup,
          refresh: true,
        );
  }

  void _onSearch(String query) {
    context.read<VideoProvider>().loadVideos(
          muscleGroup: _selectedMuscleGroup,
          search: query.isNotEmpty ? query : null,
          refresh: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = context.watch<VideoProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vídeos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearch('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _onSearch,
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            // Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: MuscleGroupSelector(
                  selectedGroup: _selectedMuscleGroup,
                  onChanged: _onMuscleGroupChanged,
                ),
              ),
            ),
            // Content
            _buildContent(videoProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(VideoProvider videoProvider) {
    if (videoProvider.status == VideoStatus.loading &&
        videoProvider.videos.isEmpty) {
      return const SliverFillRemaining(
        child: LoadingWidget(message: 'Carregando...'),
      );
    }

    if (videoProvider.status == VideoStatus.error &&
        videoProvider.videos.isEmpty) {
      return SliverFillRemaining(
        child: AppErrorWidget(
          message: videoProvider.error ?? 'Erro ao carregar',
          onRetry: () => videoProvider.loadVideos(
            muscleGroup: _selectedMuscleGroup,
            refresh: true,
          ),
        ),
      );
    }

    if (videoProvider.videos.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.video_library_outlined,
          title: 'Nenhum vídeo',
          subtitle: 'Os vídeos aparecerão aqui',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= videoProvider.videos.length) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            final video = videoProvider.videos[index];
            return StaggeredFadeIn(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VideoCard(
                  video: video,
                  onTap: () {
                    Navigator.of(context).push(
                      SmoothPageRoute(
                        page: VideoPlayerScreen(video: video),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          childCount:
              videoProvider.videos.length + (videoProvider.hasMore ? 1 : 0),
        ),
      ),
    );
  }
}
