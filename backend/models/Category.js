const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Nome da categoria é obrigatório'],
    unique: true,
    trim: true
  },
  slug: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  description: {
    type: String,
    trim: true
  },
  icon: {
    type: String,
    default: null
  },
  imageUrl: {
    type: String,
    default: null
  },
  order: {
    type: Number,
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Índice para ordenação
categorySchema.index({ order: 1 });

// Método estático para obter categorias padrão
categorySchema.statics.getDefaultCategories = function() {
  return [
    { name: 'Peito', slug: 'peito', description: 'Exercícios para peitoral', order: 1 },
    { name: 'Costas', slug: 'costas', description: 'Exercícios para dorsal', order: 2 },
    { name: 'Perna', slug: 'perna', description: 'Exercícios para quadríceps, posterior e panturrilha', order: 3 },
    { name: 'Ombro', slug: 'ombro', description: 'Exercícios para deltoides', order: 4 },
    { name: 'Bíceps', slug: 'biceps', description: 'Exercícios para bíceps', order: 5 },
    { name: 'Tríceps', slug: 'triceps', description: 'Exercícios para tríceps', order: 6 },
    { name: 'Abdômen', slug: 'abdomen', description: 'Exercícios para core e abdominais', order: 7 },
    { name: 'Glúteo', slug: 'gluteo', description: 'Exercícios para glúteos', order: 8 },
    { name: 'Cardio', slug: 'cardio', description: 'Exercícios cardiovasculares', order: 9 },
    { name: 'Outro', slug: 'outro', description: 'Outros exercícios', order: 10 }
  ];
};

// Método estático para inicializar categorias padrão
categorySchema.statics.initializeDefaults = async function() {
  const count = await this.countDocuments();
  if (count === 0) {
    const defaultCategories = this.getDefaultCategories();
    await this.insertMany(defaultCategories);
    console.log('Categorias padrão inicializadas');
  }
};

const Category = mongoose.model('Category', categorySchema);

module.exports = Category;
