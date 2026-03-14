const ExerciseVideo = require('../models/ExerciseVideo');
const { deleteVideo } = require('../config/cloudinary');

// @desc    Criar novo vídeo de exercício
// @route   POST /api/videos
// @access  Private (Trainer)
const createVideo = async (req, res, next) => {
  try {
    const { title, description, muscleGroup, tags } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Por favor, envie um vídeo'
      });
    }

    const video = await ExerciseVideo.create({
      title,
      description,
      muscleGroup,
      videoUrl: req.file.path,
      videoPublicId: req.file.filename,
      thumbnailUrl: req.file.path.replace(/\.[^/.]+$/, '.jpg'),
      trainer: req.user._id,
      tags: tags ? tags.split(',').map(tag => tag.trim()) : []
    });

    await video.populate('trainer', 'name email');

    res.status(201).json({
      success: true,
      message: 'Vídeo enviado com sucesso',
      data: video
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter todos os vídeos
// @route   GET /api/videos
// @access  Private
const getVideos = async (req, res, next) => {
  try {
    const { 
      muscleGroup, 
      search, 
      page = 1, 
      limit = 20,
      sortBy = 'createdAt',
      order = 'desc'
    } = req.query;

    const query = {};

    // Filtrar por grupo muscular
    if (muscleGroup) {
      query.muscleGroup = muscleGroup;
    }

    // Se for aluno, mostrar apenas vídeos do seu trainer ou públicos
    if (req.user.role === 'student') {
      query.$or = [
        { trainer: req.user.trainer },
        { isPublic: true }
      ];
    }

    // Se for trainer, mostrar apenas seus próprios vídeos
    if (req.user.role === 'trainer') {
      query.trainer = req.user._id;
    }

    // Busca por texto
    if (search) {
      query.$text = { $search: search };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const sortOrder = order === 'asc' ? 1 : -1;

    const [videos, total] = await Promise.all([
      ExerciseVideo.find(query)
        .populate('trainer', 'name email')
        .sort({ [sortBy]: sortOrder })
        .skip(skip)
        .limit(parseInt(limit)),
      ExerciseVideo.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      data: videos,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalItems: total,
        itemsPerPage: parseInt(limit)
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter vídeo por ID
// @route   GET /api/videos/:id
// @access  Private
const getVideoById = async (req, res, next) => {
  try {
    const video = await ExerciseVideo.findById(req.params.id)
      .populate('trainer', 'name email');

    if (!video) {
      return res.status(404).json({
        success: false,
        message: 'Vídeo não encontrado'
      });
    }

    // Verificar permissão de acesso
    if (req.user.role === 'student') {
      const hasAccess = 
        video.isPublic || 
        (req.user.trainer && video.trainer._id.equals(req.user.trainer));
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          message: 'Você não tem acesso a este vídeo'
        });
      }
    }

    // Incrementar visualizações
    await video.incrementViews();

    res.status(200).json({
      success: true,
      data: video
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Atualizar vídeo
// @route   PUT /api/videos/:id
// @access  Private (Trainer - owner)
const updateVideo = async (req, res, next) => {
  try {
    const { title, description, muscleGroup, tags, isPublic } = req.body;

    let video = await ExerciseVideo.findById(req.params.id);

    if (!video) {
      return res.status(404).json({
        success: false,
        message: 'Vídeo não encontrado'
      });
    }

    // Verificar se o trainer é o dono do vídeo
    if (!video.trainer.equals(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Você não tem permissão para editar este vídeo'
      });
    }

    const updateData = {};
    if (title) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (muscleGroup) updateData.muscleGroup = muscleGroup;
    if (tags) updateData.tags = tags.split(',').map(tag => tag.trim());
    if (isPublic !== undefined) updateData.isPublic = isPublic;

    video = await ExerciseVideo.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).populate('trainer', 'name email');

    res.status(200).json({
      success: true,
      message: 'Vídeo atualizado com sucesso',
      data: video
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Deletar vídeo
// @route   DELETE /api/videos/:id
// @access  Private (Trainer - owner)
const deleteVideoById = async (req, res, next) => {
  try {
    const video = await ExerciseVideo.findById(req.params.id);

    if (!video) {
      return res.status(404).json({
        success: false,
        message: 'Vídeo não encontrado'
      });
    }

    // Verificar se o trainer é o dono do vídeo
    if (!video.trainer.equals(req.user._id)) {
      return res.status(403).json({
        success: false,
        message: 'Você não tem permissão para deletar este vídeo'
      });
    }

    // Deletar vídeo do Cloudinary
    try {
      await deleteVideo(video.videoPublicId);
    } catch (cloudinaryError) {
      console.error('Erro ao deletar vídeo do Cloudinary:', cloudinaryError);
    }

    // Deletar do banco de dados
    await ExerciseVideo.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Vídeo deletado com sucesso'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter vídeos por grupo muscular
// @route   GET /api/videos/muscle-group/:muscleGroup
// @access  Private
const getVideosByMuscleGroup = async (req, res, next) => {
  try {
    const { muscleGroup } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const query = { muscleGroup };

    if (req.user.role === 'student') {
      query.$or = [
        { trainer: req.user.trainer },
        { isPublic: true }
      ];
    } else {
      query.trainer = req.user._id;
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [videos, total] = await Promise.all([
      ExerciseVideo.find(query)
        .populate('trainer', 'name email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      ExerciseVideo.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      data: videos,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalItems: total
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter estatísticas dos vídeos (apenas trainer)
// @route   GET /api/videos/stats
// @access  Private (Trainer)
const getVideoStats = async (req, res, next) => {
  try {
    const stats = await ExerciseVideo.aggregate([
      { $match: { trainer: req.user._id } },
      {
        $group: {
          _id: '$muscleGroup',
          count: { $sum: 1 },
          totalViews: { $sum: '$viewCount' }
        }
      },
      { $sort: { count: -1 } }
    ]);

    const totalVideos = stats.reduce((acc, s) => acc + s.count, 0);
    const totalViews = stats.reduce((acc, s) => acc + s.totalViews, 0);

    res.status(200).json({
      success: true,
      data: {
        byMuscleGroup: stats,
        totalVideos,
        totalViews
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createVideo,
  getVideos,
  getVideoById,
  updateVideo,
  deleteVideoById,
  getVideosByMuscleGroup,
  getVideoStats
};
