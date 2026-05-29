import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/nutritionist_provider.dart';

class AdviceFeedScreen extends ConsumerWidget {
  const AdviceFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adviceAsync = ref.watch(adviceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Conseils nutritionnels')),
      body: adviceAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) =>
            const Center(child: Text('Erreur lors du chargement.')),
        data: (adviceList) {
          if (adviceList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.health_and_safety_outlined,
                      size: 72, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Aucun conseil publié pour le moment.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adviceList.length,
            itemBuilder: (_, i) {
              final a = adviceList[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.content,
                        style: const TextStyle(
                            fontSize: 15, height: 1.5),
                      ),
                      if (a.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          children: a.tags
                              .map((t) => Chip(
                                    label: Text(t,
                                        style: const TextStyle(
                                            fontSize: 11)),
                                    backgroundColor:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    side: BorderSide.none,
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd MMMM yyyy', 'fr_FR')
                            .format(a.publishedAt),
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
