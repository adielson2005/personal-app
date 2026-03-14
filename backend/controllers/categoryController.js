const Category = require('../models/Category');
const ExerciseVideo = require('../models/ExerciseVideo');

// @desc    Obter todas as categorias
// @route   GET /api/categories
// @access  Public
const getCategories = async (req, res, next) => {
  try {
    const categories = await Category.find({ isActive: true })
      .sort({ order: 1 });

    res.status(200).json({
      success: true,
      data: categories
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter categoria por ID
// @route   GET /api/categories/:id
// @access  Public
const getCategoryById = async (req, res, next) => {
  try {
    const category = await Category.findById(req.params.id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Categoria não encontrada'
      });
    }

    res.status(200).json({
      success: true,
      data: category
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter categorias com contagem de vídeos
// @route   GET /api/categories/with-count
// @access  Private
const getCategoriesWithCount = async (req, res, next) => {
  try {
    const query = {};

    // Se for aluno, contar apenas vídeos acessíveis
    if (req.user.role === 'student') {
      query.$or = [
        { trainer: req.user.trainer },
        { isPublic: true }
      ];
    } else {
      query.trainer = req.user._id;
    }

    // Contar vídeos por grupo muscular
    const videoCounts = await ExerciseVideo.aggregate([
      { $match: query },
      {
        $group: {
          _id: '$muscleGroup',
          count: { $sum: 1 }
        }
      }
    ]);

    // Criar mapa de contagens
    const countMap = {};
    videoCounts.forEach(vc => {
      countMap[vc._id] = vc.count;
    });

    // Obter categorias e adicionar contagem
    const categories = await Category.find({ isActive: true })
      .sort({ order: 1 })
      .lean();

    const categoriesWithCount = categories.map(cat => ({
      ...cat,
      videoCount: countMap[cat.slug] || 0
    }));

    res.status(200).json({
      success: true,
      data: categoriesWithCount
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Criar categoria (admin)
// @route   POST /api/categories
// @access  Private (Trainer)
const createCategory = async (req, res, next) => {
  try {
    const { name, description, icon, imageUrl, order } = req.body;

    // Gerar slug a partir do nome
    const slug = name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '');

    const category = await Category.create({
      name,
      slug,
      description,
      icon,
      imageUrl,
      order
    });

    res.status(201).json({
      success: true,
      message: 'Categoria criada com sucesso',
      data: category
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Atualizar categoria
// @route   PUT /api/categories/:id
// @access  Private (Trainer)
const updateCategory = async (req, res, next) => {
  try {
    const { name, description, icon, imageUrl, order, isActive } = req.body;

    const updateData = {};
    if (name) {
      updateData.name = name;
      updateData.slug = name
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)/g, '');
    }
    if (description !== undefined) updateData.description = description;
    if (icon !== undefined) updateData.icon = icon;
    if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
    if (order !== undefined) updateData.order = order;
    if (isActive !== undefined) updateData.isActive = isActive;

    const category = await Category.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Categoria não encontrada'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Categoria atualizada com sucesso',
      data: category
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Inicializar categorias padrão
// @route   POST /api/categories/initialize
// @access  Private (Trainer)
const initializeCategories = async (req, res, next) => {
  try {
    await Category.initializeDefaults();

    const categories = await Category.find({ isActive: true })
      .sort({ order: 1 });

    res.status(200).json({
      success: true,
      message: 'Categorias inicializadas',
      data: categories
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getCategories,
  getCategoryById,
  getCategoriesWithCount,
  createCategory,
  updateCategory,
  initializeCategories
};
