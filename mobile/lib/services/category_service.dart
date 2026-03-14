import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  // Obter todas as categorias
  static Future<List<Category>> getCategories() async {
    final response = await ApiService.get('/categories', withAuth: false);

    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    }

    throw ApiException(response['message'] ?? 'Erro ao carregar categorias');
  }

  // Obter categorias com contagem de vídeos
  static Future<List<Category>> getCategoriesWithCount() async {
    final response = await ApiService.get('/categories/user/with-count');

    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    }

    throw ApiException(response['message'] ?? 'Erro ao carregar categorias');
  }

  // Obter categoria por ID
  static Future<Category> getCategoryById(String id) async {
    final response = await ApiService.get('/categories/$id', withAuth: false);

    if (response['success'] == true && response['data'] != null) {
      return Category.fromJson(response['data']);
    }

    throw ApiException(response['message'] ?? 'Erro ao carregar categoria');
  }
}
