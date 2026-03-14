const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  createVideo,
  getVideos,
  getVideoById,
  updateVideo,
  deleteVideoById,
  getVideosByMuscleGroup,
  getVideoStats
} = require('../controllers/videoController');
const { auth, isTrainer } = require('../middlewares/auth');
const { uploadVideo } = require('../config/cloudinary');

// Validações
const createVideoValidation = [
  body('title')
    .trim()
    .notEmpty().withMessage('Título é obrigatório')
    .isLength({ max: 200 }).withMessage('Título deve ter no máximo 200 caracteres'),
  body('muscleGroup')
    .notEmpty().withMessage('Grupo muscular é obrigatório')
    .isIn(['peito', 'costas', 'perna', 'ombro', 'biceps', 'triceps', 'cardio', 'abdomen', 'gluteo', 'outro'])
    .withMessage('Grupo muscular inválido'),
  body('description')
    .optional()
    .isLength({ max: 2000 }).withMessage('Descrição deve ter no máximo 2000 caracteres')
];

const updateVideoValidation = [
  body('title')
    .optional()
    .trim()
    .isLength({ max: 200 }).withMessage('Título deve ter no máximo 200 caracteres'),
  body('muscleGroup')
    .optional()
    .isIn(['peito', 'costas', 'perna', 'ombro', 'biceps', 'triceps', 'cardio', 'abdomen', 'gluteo', 'outro'])
    .withMessage('Grupo muscular inválido'),
  body('description')
    .optional()
    .isLength({ max: 2000 }).withMessage('Descrição deve ter no máximo 2000 caracteres')
];

// Middleware de validação
const validate = (req, res, next) => {
  const { validationResult } = require('express-validator');
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Erro de validação',
      errors: errors.array().map(e => e.msg)
    });
  }
  next();
};

// Todas as rotas requerem autenticação
router.use(auth);

// Rotas de estatísticas (apenas trainers)
router.get('/stats', isTrainer, getVideoStats);

// Rotas de listagem e busca
router.get('/', getVideos);
router.get('/muscle-group/:muscleGroup', getVideosByMuscleGroup);

// Rotas de CRUD
router.get('/:id', getVideoById);

// Rotas apenas para trainers
router.post(
  '/',
  isTrainer,
  uploadVideo.single('video'),
  createVideoValidation,
  validate,
  createVideo
);

router.put('/:id', isTrainer, updateVideoValidation, validate, updateVideo);
router.delete('/:id', isTrainer, deleteVideoById);

module.exports = router;
