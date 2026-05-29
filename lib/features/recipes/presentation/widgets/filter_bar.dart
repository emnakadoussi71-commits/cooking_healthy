import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/recipes_provider.dart';

const _dietTags = [
  ('Tous', null),
  ('Standard', 'standard'),
  ('Diabétique', 'diabetique'),
  ('Sans gluten', 'sans_gluten'),
  ('Végétalien', 'vegan'),
];

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(recipeFilterProvider);

    return Container(
      height: 48,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _dietTags.length,
        itemBuilder: (context, index) {
          final tag = _dietTags[index];
          final isSelected = filter.dietTag == tag.$2;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tag.$1),
              selected: isSelected,
              onSelected: (_) {
                ref.read(recipeFilterProvider.notifier).state = isSelected
                    ? filter.copyWith(clearDietTag: true)
                    : filter.copyWith(dietTag: tag.$2);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }
}
