// Middleware para tratamento de erros
const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Erro de validação do Mongoose
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map(e => e.message);
    return res.status(400).json({
      success: false,
      message: 'Erro de validação',
      errors: messages
    });
  }

  // Erro de cast (ObjectId inválido)
  if (err.name === 'CastError') {
    return res.status(400).json({
      success: false,
      message: 'ID inválido'
    });
  }

  // Erro de duplicação (unique constraint)
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return res.status(400).json({
      success: false,
      message: `${field} já está em uso`
    });
  }

  // Erro do Multer (upload)
  if (err.name === 'MulterError') {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'Arquivo muito grande. Limite máximo: 100MB'
      });
    }
    return res.status(400).json({
      success: false,
      message: `Erro no upload: ${err.message}`
    });
  }

  // Erro genérico
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Erro interno do servidor';

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

// Middleware para rotas não encontradas
const notFound = (req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Rota não encontrada: ${req.originalUrl}`
  });
};

module.exports = {
  errorHandler,
  notFound
};
