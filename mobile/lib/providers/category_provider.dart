import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar categorias
  Future<void> loadCategories({bool withCount = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (withCount) {
        _categories = await CategoryService.getCategoriesWithCount();
      } else {
        _categories = await CategoryService.getCategories();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Obter categoria por slug
  Category? getCategoryBySlug(String slug) {
    try {
      return _categories.firstWhere((c) => c.slug == slug);
    } catch (_) {
      return null;
    }
  }

  // Limpar erro
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
