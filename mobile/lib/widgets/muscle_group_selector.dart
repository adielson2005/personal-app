import 'package:flutter/material.dart';
import '../utils/theme.dart';

class MuscleGroupSelector extends StatelessWidget {
  final String? selectedGroup;
  final ValueChanged<String?>? onChanged;

  const MuscleGroupSelector({
    super.key,
    this.selectedGroup,
    this.onChanged,
  });

  // Lista de grupos musculares
  static const List<Map<String, String>> muscleGroups = [
    {'slug': 'peito', 'name': 'Peito'},
    {'slug': 'costas', 'name': 'Costas'},
    {'slug': 'perna', 'name': 'Perna'},
    {'slug': 'ombro', 'name': 'Ombro'},
    {'slug': 'biceps', 'name': 'Bíceps'},
    {'slug': 'triceps', 'name': 'Tríceps'},
    {'slug': 'cardio', 'name': 'Cardio'},
    {'slug': 'abdomen', 'name': 'Abdômen'},
    {'slug': 'gluteo', 'name': 'Glúteo'},
    {'slug': 'outro', 'name': 'Outro'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: muscleGroups.length + 1,
        itemBuilder: (context, index) {
          // "Todos" option
          if (index == 0) {
            final isSelected = selectedGroup == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: 'Todos',
                isSelected: isSelected,
                onTap: () => onChanged?.call(null),
              ),
            );
          }

          final group = muscleGroups[index - 1];
          final isSelected = selectedGroup == group['slug'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: group['name']!,
              isSelected: isSelected,
              onTap: () => onChanged?.call(group['slug']),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.background : AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
