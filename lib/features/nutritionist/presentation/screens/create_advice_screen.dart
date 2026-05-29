import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/nutritionist_provider.dart';
import '../../domain/advice.dart';

class CreateAdviceScreen extends ConsumerStatefulWidget {
  const CreateAdviceScreen({super.key});

  @override
  ConsumerState<CreateAdviceScreen> createState() =>
      _CreateAdviceScreenState();
}

class _CreateAdviceScreenState
    extends ConsumerState<CreateAdviceScreen> {
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _saving = false;

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final t = _tagController.text.trim();
    if (t.isNotEmpty && !_tags.contains(t)) {
      setState(() {
        _tags.add(t);
        _tagController.clear();
      });
    }
  }

  Future<void> _publish() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le contenu est obligatoire.')));
      return;
    }
    setState(() => _saving = true);

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    final advice = Advice(
      id: '',
      content: _contentController.text.trim(),
      nutritionistId: uid,
      tags: List.from(_tags),
      publishedAt: DateTime.now(),
    );

    try {
      await ref
          .read(nutritionistRepositoryProvider)
          .createAdvice(advice);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conseil publié avec succès !')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la publication.')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier un conseil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contenu du conseil',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Partagez votre conseil nutritionnel...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tags',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    onSubmitted: (_) => _addTag(),
                    decoration: InputDecoration(
                      hintText: 'Ajouter un tag...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(60, 52)),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: _tags
                    .map((t) => Chip(
                          label: Text(t),
                          onDeleted: () =>
                              setState(() => _tags.remove(t)),
                          deleteIconColor: AppColors.error,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 32),
            _saving
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : ElevatedButton.icon(
                    onPressed: _publish,
                    icon: const Icon(Icons.send),
                    label: const Text('Publier'),
                  ),
          ],
        ),
      ),
    );
  }
}
