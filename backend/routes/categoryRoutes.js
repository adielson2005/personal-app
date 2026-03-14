const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  getCategories,
  getCategoryById,
  getCategoriesWithCount,
  createCategory,
  updateCategory,
  initializeCategories
} = require('../controllers/categoryController');
const { auth, isTrainer } = require('../middlewares/auth');

// Validações
const categoryValidation = [
  body('name')
    .trim()
    .notEmpty().withMessage('Nome da categoria é obrigatório'),
  body('description')
    .optional()
    .trim()
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

// Rotas públicas
router.get('/', getCategories);
router.get('/:id', getCategoryById);

// Rotas privadas
router.get('/user/with-count', auth, getCategoriesWithCount);
router.post('/initialize', auth, isTrainer, initializeCategories);
router.post('/', auth, isTrainer, categoryValidation, validate, createCategory);
router.put('/:id', auth, isTrainer, updateCategory);

module.exports = router;
