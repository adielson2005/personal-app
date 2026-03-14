class ExerciseVideo {
  final String id;
  final String title;
  final String? description;
  final String muscleGroup;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? duration;
  final String? formattedDuration;
  final String trainerId;
  final String? trainerName;
  final bool isPublic;
  final int viewCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseVideo({
    required this.id,
    required this.title,
    this.description,
    required this.muscleGroup,
    required this.videoUrl,
    this.thumbnailUrl,
    this.duration,
    this.formattedDuration,
    required this.trainerId,
    this.trainerName,
    this.isPublic = false,
    this.viewCount = 0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseVideo.fromJson(Map<String, dynamic> json) {
    final trainer = json['trainer'];
    String trainerId = '';
    String? trainerName;

    if (trainer is Map<String, dynamic>) {
      trainerId = trainer['_id'] ?? trainer['id'] ?? '';
      trainerName = trainer['name'];
    } else if (trainer is String) {
      trainerId = trainer;
    }

    return ExerciseVideo(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      muscleGroup: json['muscleGroup'] ?? 'outro',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      formattedDuration: json['formattedDuration'],
      trainerId: trainerId,
      trainerName: trainerName,
      isPublic: json['isPublic'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'muscleGroup': muscleGroup,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'trainerId': trainerId,
      'isPublic': isPublic,
      'viewCount': viewCount,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get muscleGroupDisplayName {
    final names = {
      'peito': 'Peito',
      'costas': 'Costas',
      'perna': 'Perna',
      'ombro': 'Ombro',
      'biceps': 'Bíceps',
      'triceps': 'Tríceps',
      'cardio': 'Cardio',
      'abdomen': 'Abdômen',
      'gluteo': 'Glúteo',
      'outro': 'Outro',
    };
    return names[muscleGroup] ?? muscleGroup;
  }

  ExerciseVideo copyWith({
    String? id,
    String? title,
    String? description,
    String? muscleGroup,
    String? videoUrl,
    String? thumbnailUrl,
    int? duration,
    String? formattedDuration,
    String? trainerId,
    String? trainerName,
    bool? isPublic,
    int? viewCount,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      formattedDuration: formattedDuration ?? this.formattedDuration,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      isPublic: isPublic ?? this.isPublic,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
