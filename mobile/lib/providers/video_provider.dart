import 'package:flutter/material.dart';
import '../models/exercise_video.dart';
import '../services/video_service.dart';

enum VideoStatus { initial, loading, loaded, error, uploading }

class VideoProvider extends ChangeNotifier {
  VideoStatus _status = VideoStatus.initial;
  List<ExerciseVideo> _videos = [];
  ExerciseVideo? _selectedVideo;
  String? _error;
  Map<String, dynamic>? _pagination;
  String? _currentMuscleGroup;
  double _uploadProgress = 0;

  VideoStatus get status => _status;
  List<ExerciseVideo> get videos => _videos;
  ExerciseVideo? get selectedVideo => _selectedVideo;
  String? get error => _error;
  Map<String, dynamic>? get pagination => _pagination;
  String? get currentMuscleGroup => _currentMuscleGroup;
  double get uploadProgress => _uploadProgress;
  bool get hasMore => _pagination != null && 
      (_pagination!['currentPage'] ?? 0) < (_pagination!['totalPages'] ?? 0);

  // Carregar vídeos
  Future<void> loadVideos({
    String? muscleGroup,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh) {
      _videos = [];
      _pagination = null;
    }

    _status = VideoStatus.loading;
    _error = null;
    _currentMuscleGroup = muscleGroup;
    notifyListeners();

    try {
      final result = await VideoService.getVideos(
        muscleGroup: muscleGroup,
        search: search,
        page: 1,
      );

      _videos = result['videos'] as List<ExerciseVideo>;
      _pagination = result['pagination'] as Map<String, dynamic>?;
      _status = VideoStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = VideoStatus.error;
    }

    notifyListeners();
  }

  // Carregar mais vídeos (paginação)
  Future<void> loadMore() async {
    if (!hasMore || _status == VideoStatus.loading) return;

    final nextPage = (_pagination?['currentPage'] ?? 0) + 1;

    try {
      final result = await VideoService.getVideos(
        muscleGroup: _currentMuscleGroup,
        page: nextPage,
      );

      _videos.addAll(result['videos'] as List<ExerciseVideo>);
      _pagination = result['pagination'] as Map<String, dynamic>?;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Carregar vídeos por grupo muscular
  Future<void> loadVideosByMuscleGroup(String muscleGroup) async {
    _status = VideoStatus.loading;
    _error = null;
    _currentMuscleGroup = muscleGroup;
    notifyListeners();

    try {
      final result = await VideoService.getVideosByMuscleGroup(muscleGroup);
      _videos = result['videos'] as List<ExerciseVideo>;
      _pagination = result['pagination'] as Map<String, dynamic>?;
      _status = VideoStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = VideoStatus.error;
    }

    notifyListeners();
  }

  // Carregar vídeo por ID
  Future<void> loadVideoById(String id) async {
    _status = VideoStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _selectedVideo = await VideoService.getVideoById(id);
      _status = VideoStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = VideoStatus.error;
    }

    notifyListeners();
  }

  // Upload de vídeo
  Future<bool> uploadVideo({
    required String filePath,
    required String title,
    required String muscleGroup,
    String? description,
    String? tags,
  }) async {
    _status = VideoStatus.uploading;
    _error = null;
    _uploadProgress = 0;
    notifyListeners();

    try {
      final video = await VideoService.uploadVideo(
        filePath: filePath,
        title: title,
        muscleGroup: muscleGroup,
        description: description,
        tags: tags,
      );

      _videos.insert(0, video);
      _status = VideoStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = VideoStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Atualizar vídeo
  Future<bool> updateVideo(
    String id, {
    String? title,
    String? description,
    String? muscleGroup,
    String? tags,
    bool? isPublic,
  }) async {
    try {
      final updatedVideo = await VideoService.updateVideo(
        id,
        title: title,
        description: description,
        muscleGroup: muscleGroup,
        tags: tags,
        isPublic: isPublic,
      );

      final index = _videos.indexWhere((v) => v.id == id);
      if (index != -1) {
        _videos[index] = updatedVideo;
      }

      if (_selectedVideo?.id == id) {
        _selectedVideo = updatedVideo;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Deletar vídeo
  Future<bool> deleteVideo(String id) async {
    try {
      await VideoService.deleteVideo(id);
      _videos.removeWhere((v) => v.id == id);
      
      if (_selectedVideo?.id == id) {
        _selectedVideo = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Selecionar vídeo
  void selectVideo(ExerciseVideo video) {
    _selectedVideo = video;
    notifyListeners();
  }

  // Limpar seleção
  void clearSelection() {
    _selectedVideo = null;
    notifyListeners();
  }

  // Limpar erro
  void clearError() {
    _error = null;
    if (_status == VideoStatus.error) {
      _status = _videos.isNotEmpty ? VideoStatus.loaded : VideoStatus.initial;
    }
    notifyListeners();
  }

  // Atualizar progresso do upload
  void updateUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }
}
