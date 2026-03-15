require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');
const { errorHandler, notFound } = require('./middlewares/errorHandler');
const Category = require('./models/Category');

// Importar rotas
const authRoutes = require('./routes/authRoutes');
const videoRoutes = require('./routes/videoRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const userRoutes = require('./routes/userRoutes');

// Inicializar app
const app = express();

// Conectar ao banco de dados
connectDB().then(async () => {
  // Inicializar categorias padrão
  await Category.initializeDefaults();
});

// CORS
const allowedOrigins = (process.env.CORS_ORIGIN || '')
  .split(',')
  .map((o) => o.trim().replace(/\/$/, ''))
  .filter(Boolean);

console.log('[CORS] CORS_ORIGIN env:', process.env.CORS_ORIGIN);
console.log('[CORS] allowedOrigins:', allowedOrigins);

const corsOptions = {
  origin: (origin, callback) => {
    // Permite requests sem origin (curl, healthchecks, apps nativos)
    if (!origin) return callback(null, true);

    // Sem whitelist definida, libera todos os origins
    if (allowedOrigins.length === 0) return callback(null, true);

    const normalizedOrigin = origin.trim().replace(/\/$/, '');
    if (allowedOrigins.includes(normalizedOrigin)) return callback(null, true);

    console.warn('[CORS] Origin bloqueada:', origin);
    return callback(null, false);
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  optionsSuccessStatus: 204,
};

// Middlewares
app.use(cors(corsOptions));
app.options('*', cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rota de saúde
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API Personal Trainer funcionando!',
    timestamp: new Date().toISOString()
  });
});

// Rotas da API
app.use('/api/auth', authRoutes);
app.use('/api/videos', videoRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/users', userRoutes);

// Middleware de erros
app.use(notFound);
app.use(errorHandler);

// Iniciar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📍 Ambiente: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
