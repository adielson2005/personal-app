import '../models/exercise_video.dart';
import 'api_service.dart';

class VideoService {
  // Obter todos os vídeos
  static Future<Map<String, dynamic>> getVideos({
    String? muscleGroup,
    String? search,
    int page = 1,
    int limit = 20,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'order': order,
    };

    if (muscleGroup != null && muscleGroup.isNotEmpty) {
      queryParams['muscleGroup'] = muscleGroup;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await ApiService.get('/videos', queryParams: queryParams);

    if (response['success'] == true) {
      final videos = (response['data'] as List)
          .map((json) => ExerciseVideo.fromJson(json))
          .toList();
      
      return {
        'videos': videos,
        'pagination': response['pagination'],
      };
    }

    throw ApiException(response['message'] ?? 'Erro ao carregar vídeos');
  }

  // Obter vídeo por ID
  static Future<ExerciseVideo> getVideoById(String id) async {
    final response = await ApiService.get('/videos/$id');

    if (response['success'] == true && response['data'] != null) {
      return ExerciseVideo.fromJson(response['data']);
    }

    throw ApiException(response['message'] ?? 'Erro ao carregar vídeo');
  }

  // Obter vídeos por grupo muscular
  static Future<Map<String, dynamic>> getVideosByMuscleGroup(
    String muscleGroup, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiService.get(
      '/videos/muscle-group/$muscleGroup',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    if (response['success'] == true) {
      final videos = (response['data'] as List)
          .map((json) => ExerciseVideo.fromJson(json))
          .toList();
      
      return {
        'videos': videos,
        'pagination': response['pagination'],
      };
    }

    throw ApiException(response['message'] ?? 'Erro ao carregar vídeos');
  }

  // Upload de vídeo
  static Future<ExerciseVideo> uploadVideo({
    required String filePath,
    required String title,
    required String muscleGroup,
    String? description,
    String? tags,
  }) async {
    final fields = <String, String>{
      'title': title,
      'muscleGroup': muscleGroup,
    };

    if (description != null && description.isNotEmpty) {
      fields['description'] = description;
    }
    if (tags != null && tags.isNotEmpty) {
      fields['tags'] = tags;
    }

    final response = await ApiService.postMultipart(
      '/videos',
      filePath: filePath,
      fileField: 'video',
      fields: fields,
    );

    if (response['success'] == true && response['data'] != null) {
      return ExerciseVideo.fromJson(response['data']);
    }

    throw ApiException(response['message'] ?? 'Erro ao enviar vídeo');
  }

  // Atualizar vídeo
  static Future<ExerciseVideo> updateVideo(
    String id, {
    String? title,
    String? description,
    String? muscleGroup,
    String? tags,
    bool? isPublic,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (muscleGroup != null) body['muscleGroup'] = muscleGroup;
    if (tags != null) body['tags'] = tags;
    if (isPublic != null) body['isPublic'] = isPublic;

    final response = await ApiService.put('/videos/$id', body: body);

    if (response['success'] == true && response['data'] != null) {
      return ExerciseVideo.fromJson(response['data']);
    }

    throw ApiException(response['message'] ?? 'Erro ao atualizar vídeo');
  }

  // Deletar vídeo
  static Future<void> deleteVideo(String id) async {
    final response = await ApiService.delete('/videos/$id');

    if (response['success'] != true) {
      throw ApiException(response['message'] ?? 'Erro ao deletar vídeo');
    }
  }

  // Obter estatísticas (apenas trainers)
  static Future<Map<String, dynamic>> getStats() async {
    final response = await ApiService.get('/videos/stats');

    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    }

    throw ApiException(response['message'] ?? 'Erro ao carregar estatísticas');
  }
}
