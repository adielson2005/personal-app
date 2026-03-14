const User = require('../models/User');

// @desc    Obter alunos do trainer
// @route   GET /api/users/students
// @access  Private (Trainer)
const getStudents = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, search } = req.query;

    const query = {
      trainer: req.user._id,
      role: 'student'
    };

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [students, total] = await Promise.all([
      User.find(query)
        .select('-password')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      User.countDocuments(query)
    ]);

    res.status(200).json({
      success: true,
      data: students.map(s => s.toPublicJSON()),
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

// @desc    Adicionar aluno ao trainer
// @route   POST /api/users/students
// @access  Private (Trainer)
const addStudent = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    // Verificar se email já existe
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Este email já está cadastrado'
      });
    }

    const student = await User.create({
      name,
      email,
      password,
      role: 'student',
      trainer: req.user._id
    });

    res.status(201).json({
      success: true,
      message: 'Aluno adicionado com sucesso',
      data: student.toPublicJSON()
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter aluno por ID
// @route   GET /api/users/students/:id
// @access  Private (Trainer)
const getStudentById = async (req, res, next) => {
  try {
    const student = await User.findOne({
      _id: req.params.id,
      trainer: req.user._id,
      role: 'student'
    });

    if (!student) {
      return res.status(404).json({
        success: false,
        message: 'Aluno não encontrado'
      });
    }

    res.status(200).json({
      success: true,
      data: student.toPublicJSON()
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Atualizar aluno
// @route   PUT /api/users/students/:id
// @access  Private (Trainer)
const updateStudent = async (req, res, next) => {
  try {
    const { name, email, isActive } = req.body;

    const student = await User.findOne({
      _id: req.params.id,
      trainer: req.user._id,
      role: 'student'
    });

    if (!student) {
      return res.status(404).json({
        success: false,
        message: 'Aluno não encontrado'
      });
    }

    if (name) student.name = name;
    if (email) student.email = email;
    if (isActive !== undefined) student.isActive = isActive;

    await student.save();

    res.status(200).json({
      success: true,
      message: 'Aluno atualizado com sucesso',
      data: student.toPublicJSON()
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Remover aluno
// @route   DELETE /api/users/students/:id
// @access  Private (Trainer)
const removeStudent = async (req, res, next) => {
  try {
    const student = await User.findOneAndDelete({
      _id: req.params.id,
      trainer: req.user._id,
      role: 'student'
    });

    if (!student) {
      return res.status(404).json({
        success: false,
        message: 'Aluno não encontrado'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Aluno removido com sucesso'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter perfil do trainer (para alunos)
// @route   GET /api/users/my-trainer
// @access  Private (Student)
const getMyTrainer = async (req, res, next) => {
  try {
    if (!req.user.trainer) {
      return res.status(404).json({
        success: false,
        message: 'Você não está vinculado a nenhum personal trainer'
      });
    }

    const trainer = await User.findById(req.user.trainer);

    if (!trainer) {
      return res.status(404).json({
        success: false,
        message: 'Trainer não encontrado'
      });
    }

    res.status(200).json({
      success: true,
      data: trainer.toPublicJSON()
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getStudents,
  addStudent,
  getStudentById,
  updateStudent,
  removeStudent,
  getMyTrainer
};
