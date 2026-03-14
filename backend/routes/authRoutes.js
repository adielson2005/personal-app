const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  register,
  login,
  getMe,
  updateProfile,
  changePassword
} = require('../controllers/authController');
const { auth } = require('../middlewares/auth');

// Validações
const registerValidation = [
  body('name')
    .trim()
    .notEmpty().withMessage('Nome é obrigatório')
    .isLength({ max: 100 }).withMessage('Nome deve ter no máximo 100 caracteres'),
  body('email')
    .trim()
    .notEmpty().withMessage('Email é obrigatório')
    .isEmail().withMessage('Email inválido')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Senha é obrigatória')
    .isLength({ min: 6 }).withMessage('Senha deve ter no mínimo 6 caracteres'),
  body('role')
    .optional()
    .isIn(['trainer', 'student']).withMessage('Role inválido')
];

const loginValidation = [
  body('email')
    .trim()
    .notEmpty().withMessage('Email é obrigatório')
    .isEmail().withMessage('Email inválido')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Senha é obrigatória')
];

// Middleware para validar erros
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
router.post('/register', registerValidation, validate, register);
router.post('/login', loginValidation, validate, login);

// Rotas privadas
router.get('/me', auth, getMe);
router.put('/update', auth, updateProfile);
router.put('/password', auth, changePassword);

module.exports = router;
