import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/video_provider.dart';
import '../widgets/widgets.dart';
import '../utils/theme.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _selectedMuscleGroup;
  File? _selectedVideo;
  String? _selectedVideoName;
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedVideo = File(result.files.first.path!);
          _selectedVideoName = result.files.first.name;
        });
      }
    } catch (e) {
      _showSnackBar('Erro: ${e.toString()}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVideo == null) {
      _showSnackBar('Selecione um vídeo', isError: true);
      return;
    }

    if (_selectedMuscleGroup == null) {
      _showSnackBar('Selecione um grupo muscular', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    _simulateProgress();

    final videoProvider = context.read<VideoProvider>();
    final success = await videoProvider.uploadVideo(
      filePath: _selectedVideo!.path,
      title: _titleController.text.trim(),
      muscleGroup: _selectedMuscleGroup!,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      tags: _tagsController.text.trim().isNotEmpty
          ? _tagsController.text.trim()
          : null,
    );

    setState(() => _isUploading = false);

    if (success && mounted) {
      _showSnackBar('Vídeo enviado!');
      _clearForm();
    } else if (mounted) {
      _showSnackBar(videoProvider.error ?? 'Erro ao enviar', isError: true);
    }
  }

  void _simulateProgress() async {
    while (_isUploading && _uploadProgress < 0.95) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _isUploading) {
        setState(() => _uploadProgress += 0.02);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _tagsController.clear();
    setState(() {
      _selectedMuscleGroup = null;
      _selectedVideo = null;
      _selectedVideoName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adicione um novo vídeo',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                _buildVideoPicker(),
                const SizedBox(height: 24),
                _buildLabel('Título'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      const InputDecoration(hintText: 'Nome do exercício'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildLabel('Grupo Muscular'),
                const SizedBox(height: 12),
                _buildMuscleGroupSelector(),
                const SizedBox(height: 20),
                _buildLabel('Descrição'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Instruções do exercício',
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Tags'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    hintText: 'força, iniciante',
                  ),
                ),
                const SizedBox(height: 32),
                _buildUploadButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildVideoPicker() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickVideo,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedVideo != null
                ? AppColors.textSecondary.withValues(alpha: 0.3)
                : AppColors.textMuted.withValues(alpha: 0.15),
          ),
        ),
        child: _selectedVideo != null
            ? Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.video_file,
                          size: 32,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _selectedVideoName ?? 'Vídeo selecionado',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVideo = null;
                          _selectedVideoName = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 32,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Selecionar vídeo',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'MP4, MOV (máx. 100MB)',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMuscleGroupSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MuscleGroupSelector.muscleGroups
          .map(
            (group) => GestureDetector(
              onTap: () {
                setState(() => _selectedMuscleGroup = group['slug']);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedMuscleGroup == group['slug']
                      ? AppColors.textPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _selectedMuscleGroup == group['slug']
                        ? AppColors.textPrimary
                        : AppColors.textMuted.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  group['name']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: _selectedMuscleGroup == group['slug']
                        ? FontWeight.w500
                        : FontWeight.w400,
                    color: _selectedMuscleGroup == group['slug']
                        ? AppColors.background
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _handleUpload,
        child: _isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Enviando ${(_uploadProgress * 100).toInt()}%'),
                ],
              )
            : const Text('Enviar'),
      ),
    );
  }
}
