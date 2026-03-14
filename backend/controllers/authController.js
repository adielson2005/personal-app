const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Gerar token JWT
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  });
};

// @desc    Registrar novo usuário
// @route   POST /api/auth/register
// @access  Public
const register = async (req, res, next) => {
  try {
    const { name, email, password, role } = req.body;

    // Verificar se usuário já existe
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Este email já está cadastrado'
      });
    }

    // Criar usuário
    const user = await User.create({
      name,
      email,
      password,
      role: role || 'student'
    });

    // Gerar token
    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      message: 'Usuário cadastrado com sucesso',
      data: {
        user: user.toPublicJSON(),
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Login de usuário
// @route   POST /api/auth/login
// @access  Public
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Validar entrada
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Por favor, forneça email e senha'
      });
    }

    // Buscar usuário com senha
    const user = await User.findOne({ email }).select('+password');
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Email ou senha incorretos'
      });
    }

    // Verificar se conta está ativa
    if (!user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Conta desativada. Entre em contato com o suporte.'
      });
    }

    // Verificar senha
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Email ou senha incorretos'
      });
    }

    // Gerar token
    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Login realizado com sucesso',
      data: {
        user: user.toPublicJSON(),
        token
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Obter usuário logado
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    
    res.status(200).json({
      success: true,
      data: user.toPublicJSON()
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Atualizar dados do usuário
// @route   PUT /api/auth/update
// @access  Private
const updateProfile = async (req, res, next) => {
  try {
    const { name, email, profileImage } = req.body;
    
    const updateData = {};
    if (name) updateData.name = name;
    if (email) updateData.email = email;
    if (profileImage) updateData.profileImage = profileImage;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    );

    res.status(200).json({
      success: true,
      message: 'Perfil atualizado com sucesso',
      data: user.toPublicJSON()
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Alterar senha
// @route   PUT /api/auth/password
// @access  Private
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Por favor, forneça a senha atual e a nova senha'
      });
    }

    const user = await User.findById(req.user._id).select('+password');

    // Verificar senha atual
    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Senha atual incorreta'
      });
    }

    // Atualizar senha
    user.password = newPassword;
    await user.save();

    // Gerar novo token
    const token = generateToken(user._id);

    res.status(200).json({
      success: true,
      message: 'Senha alterada com sucesso',
      data: { token }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  getMe,
  updateProfile,
  changePassword
};
