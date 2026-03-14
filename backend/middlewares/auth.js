const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Middleware para verificar autenticação
const auth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Token de autenticação não fornecido'
      });
    }

    const token = authHeader.split(' ')[1];
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Usuário não encontrado'
      });
    }

    if (!user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Conta desativada'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Token inválido'
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expirado'
      });
    }
    return res.status(500).json({
      success: false,
      message: 'Erro interno do servidor'
    });
  }
};

// Middleware para verificar se é trainer
const isTrainer = (req, res, next) => {
  if (req.user.role !== 'trainer') {
    return res.status(403).json({
      success: false,
      message: 'Acesso negado. Apenas personal trainers podem realizar esta ação.'
    });
  }
  next();
};

// Middleware para verificar se é trainer ou o próprio usuário
const isTrainerOrSelf = (req, res, next) => {
  const targetUserId = req.params.userId || req.params.id;
  
  if (req.user.role !== 'trainer' && req.user._id.toString() !== targetUserId) {
    return res.status(403).json({
      success: false,
      message: 'Acesso negado.'
    });
  }
  next();
};

// Middleware opcional de autenticação (não obriga, mas adiciona user se existir)
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId);
      
      if (user && user.isActive) {
        req.user = user;
      }
    }
    next();
  } catch (error) {
    // Ignora erros - autenticação é opcional
    next();
  }
};

module.exports = {
  auth,
  isTrainer,
  isTrainerOrSelf,
  optionalAuth
};
