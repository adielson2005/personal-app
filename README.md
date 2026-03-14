# 📱 Personal Trainer Video App

Aplicativo criado para personal trainers enviarem vídeos de treino para seus alunos.
O objetivo do app é funcionar como uma biblioteca privada de exercícios, onde o treinador pode subir vídeos e os alunos podem assistir facilmente pelo aplicativo.

## 🎯 Objetivo do Projeto

O aplicativo permite que personal trainers organizem e compartilhem exercícios em vídeo com seus alunos.

### Principais Funcionalidades

- ✅ Upload de vídeos de exercícios
- ✅ Organização por grupo muscular
- ✅ Visualização de treinos pelos alunos
- ✅ Biblioteca de exercícios organizada
- ✅ Sistema de autenticação (Personal Trainer / Aluno)

## 🏗 Arquitetura do Projeto

```
personal-trainer-app/
├── backend/                 # API Node.js + Express
│   ├── config/             # Configurações (DB, Cloudinary)
│   ├── controllers/        # Lógica de negócio
│   ├── middlewares/        # Autenticação, erros
│   ├── models/             # Schemas MongoDB
│   ├── routes/             # Rotas da API
│   └── server.js           # Entry point
│
└── mobile/                  # App Flutter
    └── lib/
        ├── config/         # Configurações do app
        ├── models/         # Modelos de dados
        ├── providers/      # Gerenciamento de estado
        ├── screens/        # Telas do app
        ├── services/       # Comunicação com API
        ├── utils/          # Tema, helpers
        ├── widgets/        # Componentes reutilizáveis
        └── main.dart       # Entry point
```

## ⚙️ Stack de Tecnologia

### Mobile App
- **Flutter** - Framework multiplataforma (Android/iOS)
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Chewie/Video Player** - Reprodução de vídeos

### Backend
- **Node.js + Express** - API REST
- **MongoDB** - Banco de dados
- **JWT** - Autenticação
- **Cloudinary** - Armazenamento de vídeos

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- Node.js 18+
- MongoDB instalado e rodando
- Flutter SDK 3.0+
- Conta no Cloudinary (para upload de vídeos)

### Backend

1. Entre na pasta do backend:
```bash
cd backend
```

2. Instale as dependências:
```bash
npm install
```

3. Configure as variáveis de ambiente:
```bash
cp .env.example .env
```

4. Edite o `.env` com suas configurações:
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/personal-trainer-db
JWT_SECRET=sua_chave_secreta_aqui
JWT_EXPIRES_IN=7d
CLOUDINARY_CLOUD_NAME=seu_cloud_name
CLOUDINARY_API_KEY=sua_api_key
CLOUDINARY_API_SECRET=seu_api_secret
```

5. Inicie o servidor:
```bash
npm start
# ou para desenvolvimento com hot-reload:
npm run dev
```

### Mobile (Flutter)

1. Entre na pasta mobile:
```bash
cd mobile
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure a URL da API em `lib/config/app_config.dart`:
```dart
// Para emulador Android
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Para iOS simulator
static const String baseUrl = 'http://localhost:3000/api';

// Para dispositivo físico (use o IP da sua máquina)
static const String baseUrl = 'http://SEU_IP:3000/api';
```

4. Execute o app:
```bash
flutter run
```

## 📱 Telas do Aplicativo

| Tela | Descrição |
|------|-----------|
| **Login** | Autenticação com email e senha |
| **Cadastro** | Registro como Personal Trainer ou Aluno |
| **Home** | Categorias e vídeos recentes |
| **Biblioteca** | Lista completa de vídeos com filtros |
| **Player** | Reprodução de vídeo com detalhes |
| **Upload** | Envio de novos vídeos (apenas trainers) |
| **Perfil** | Configurações do usuário |

## 🔐 Sistema de Usuários

### Personal Trainer
- Enviar vídeos
- Editar vídeos
- Excluir vídeos
- Gerenciar alunos

### Aluno
- Visualizar vídeos do seu trainer
- Assistir treinos
- Filtrar por categoria

## 📌 Categorias de Treino

- 💪 Peito
- 🔙 Costas
- 🦵 Perna
- 🏋️ Ombro
- 💪 Bíceps
- 💪 Tríceps
- ❤️ Cardio
- 🔥 Abdômen
- 🍑 Glúteo

## 🔮 Funcionalidades Futuras

- [ ] Plano de treino semanal
- [ ] Comentários em vídeos
- [ ] Sistema de favoritos
- [ ] Progresso do aluno
- [ ] Notificações de novos treinos
- [ ] Planos pagos (SaaS)
- [ ] Métricas de treino

## 📡 API Endpoints

### Autenticação
```
POST   /api/auth/register    - Cadastro
POST   /api/auth/login       - Login
GET    /api/auth/me          - Usuário logado
PUT    /api/auth/update      - Atualizar perfil
PUT    /api/auth/password    - Alterar senha
```

### Vídeos
```
GET    /api/videos           - Listar vídeos
GET    /api/videos/:id       - Detalhes do vídeo
POST   /api/videos           - Upload (trainer)
PUT    /api/videos/:id       - Atualizar (trainer)
DELETE /api/videos/:id       - Deletar (trainer)
GET    /api/videos/stats     - Estatísticas (trainer)
```

### Categorias
```
GET    /api/categories       - Listar categorias
GET    /api/categories/user/with-count - Com contagem
```

### Usuários
```
GET    /api/users/students       - Listar alunos (trainer)
POST   /api/users/students       - Adicionar aluno (trainer)
GET    /api/users/my-trainer     - Meu trainer (aluno)
```

## 📄 Licença

Este projeto é um MVP para fins educacionais e de demonstração.

---

Desenvolvido com ❤️ para Personal Trainers e seus alunos.
