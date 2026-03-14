const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  getStudents,
  addStudent,
  getStudentById,
  updateStudent,
  removeStudent,
  getMyTrainer
} = require('../controllers/userController');
const { auth, isTrainer } = require('../middlewares/auth');

// Validações
const addStudentValidation = [
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
    .isLength({ min: 6 }).withMessage('Senha deve ter no mínimo 6 caracteres')
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

// Rotas para alunos
router.get('/my-trainer', getMyTrainer);

// Rotas para trainers (gerenciamento de alunos)
router.get('/students', isTrainer, getStudents);
router.post('/students', isTrainer, addStudentValidation, validate, addStudent);
router.get('/students/:id', isTrainer, getStudentById);
router.put('/students/:id', isTrainer, updateStudent);
router.delete('/students/:id', isTrainer, removeStudent);

module.exports = router;
