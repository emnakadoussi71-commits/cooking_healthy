import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/nutritionist_provider.dart';
import '../../domain/diet_plan.dart';

const _days = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche'
];
const _dietOptions = [
  'standard',
  'diabetique',
  'sans_gluten',
  'vegan',
];

class CreateDietPlanScreen extends ConsumerStatefulWidget {
  const CreateDietPlanScreen({super.key});

  @override
  ConsumerState<CreateDietPlanScreen> createState() =>
      _CreateDietPlanScreenState();
}

class _CreateDietPlanScreenState
    extends ConsumerState<CreateDietPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _targetDiet = 'standard';
  final Map<String, List<String>> _schedule = {
    for (final d in _days) d: [],
  };
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    final plan = DietPlan(
      id: '',
      title: _titleController.text.trim(),
      nutritionistId: uid,
      targetDiet: _targetDiet,
      description: _descController.text.trim(),
      weeklySchedule: Map.from(_schedule),
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(nutritionistRepositoryProvider)
          .createDietPlan(plan);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Plan alimentaire créé avec succès !')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la création.')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau plan alimentaire')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                validator: (v) => Validators.required(v, 'Le titre'),
                decoration: const InputDecoration(labelText: 'Titre du plan'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description (optionnel)'),
              ),
              const SizedBox(height: 16),
              const Text('Type d\'alimentation ciblé',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _targetDiet,
                decoration: const InputDecoration(),
                items: _dietOptions
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _targetDiet = v ?? 'standard'),
              ),
              const SizedBox(height: 24),
              const Text('Programme hebdomadaire',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text(
                  'Entrez les IDs des recettes pour chaque jour (séparés par des virgules).',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              ..._days.map((day) => _DayRow(
                    day: day,
                    recipeIds: _schedule[day]!,
                    onChanged: (ids) =>
                        setState(() => _schedule[day] = ids),
                  )),
              const SizedBox(height: 32),
              _saving
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : ElevatedButton(
                      onPressed: _save,
                      child: const Text('Enregistrer le plan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final String day;
  final List<String> recipeIds;
  final ValueChanged<List<String>> onChanged;

  const _DayRow({
    required this.day,
    required this.recipeIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: recipeIds.join(', '));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              _capitalize(day),
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              onChanged: (v) => onChanged(
                v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
              ),
              decoration: InputDecoration(
                hintText: 'IDs des recettes...',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
