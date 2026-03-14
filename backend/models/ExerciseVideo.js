const mongoose = require('mongoose');

const exerciseVideoSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Título é obrigatório'],
    trim: true,
    maxlength: [200, 'Título deve ter no máximo 200 caracteres']
  },
  description: {
    type: String,
    trim: true,
    maxlength: [2000, 'Descrição deve ter no máximo 2000 caracteres']
  },
  muscleGroup: {
    type: String,
    required: [true, 'Grupo muscular é obrigatório'],
    enum: {
      values: ['peito', 'costas', 'perna', 'ombro', 'biceps', 'triceps', 'cardio', 'abdomen', 'gluteo', 'outro'],
      message: 'Grupo muscular inválido'
    }
  },
  videoUrl: {
    type: String,
    required: [true, 'URL do vídeo é obrigatória']
  },
  videoPublicId: {
    type: String,
    required: [true, 'ID público do vídeo é obrigatório']
  },
  thumbnailUrl: {
    type: String,
    default: null
  },
  duration: {
    type: Number, // Em segundos
    default: null
  },
  trainer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Trainer é obrigatório']
  },
  isPublic: {
    type: Boolean,
    default: false
  },
  viewCount: {
    type: Number,
    default: 0
  },
  tags: [{
    type: String,
    trim: true
  }]
}, {
  timestamps: true
});

// Índices para otimização de busca
exerciseVideoSchema.index({ trainer: 1, muscleGroup: 1 });
exerciseVideoSchema.index({ muscleGroup: 1 });
exerciseVideoSchema.index({ title: 'text', description: 'text' });

// Virtual para URL formatada
exerciseVideoSchema.virtual('formattedDuration').get(function() {
  if (!this.duration) return null;
  const minutes = Math.floor(this.duration / 60);
  const seconds = this.duration % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
});

// Método para incrementar visualizações
exerciseVideoSchema.methods.incrementViews = async function() {
  this.viewCount += 1;
  await this.save();
};

// Configuração para incluir virtuals no JSON
exerciseVideoSchema.set('toJSON', { virtuals: true });
exerciseVideoSchema.set('toObject', { virtuals: true });

const ExerciseVideo = mongoose.model('ExerciseVideo', exerciseVideoSchema);

module.exports = ExerciseVideo;
