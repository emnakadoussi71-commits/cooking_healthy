import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/app_user.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _goal = 'maintenir';
  String _dietType = 'standard';
  bool _loading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    final profile = UserProfile(
      age: int.parse(_ageController.text.trim()),
      weight: double.parse(_weightController.text.trim()),
      height: double.parse(_heightController.text.trim()),
      goal: _goal,
      dietType: _dietType,
    );

    try {
      await ref.read(authRepositoryProvider).saveUserProfile(uid, profile);
      if (mounted) context.go('/home/recettes');
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon profil santé'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quelques informations',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ces données nous permettent de personnaliser vos recommandations.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.positiveInt(v, "L'âge"),
                        decoration: const InputDecoration(
                            labelText: 'Âge', suffixText: 'ans'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) =>
                            Validators.positiveNumber(v, 'Le poids'),
                        decoration: const InputDecoration(
                            labelText: 'Poids', suffixText: 'kg'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) =>
                            Validators.positiveNumber(v, 'La taille'),
                        decoration: const InputDecoration(
                            labelText: 'Taille', suffixText: 'cm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Votre objectif',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 12),
                _GoalSelector(
                  selected: _goal,
                  onChanged: (v) => setState(() => _goal = v),
                ),
                const SizedBox(height: 28),
                const Text('Type d\'alimentation',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 12),
                _DietSelector(
                  selected: _dietType,
                  onChanged: (v) => setState(() => _dietType = v),
                ),
                const SizedBox(height: 36),
                _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))
                    : ElevatedButton(
                        onPressed: _save,
                        child: const Text('Commencer'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GoalSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final goals = [
      ('perdre', 'Perdre du poids', Icons.trending_down),
      ('maintenir', 'Maintenir mon poids', Icons.balance),
      ('prendre', 'Prendre du poids', Icons.trending_up),
    ];

    return Column(
      children: goals.map((g) {
        final isSelected = selected == g.$1;
        return GestureDetector(
          onTap: () => onChanged(g.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(g.$3,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(g.$2,
                    style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DietSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _DietSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final diets = [
      ('standard', 'Alimentation standard'),
      ('diabetique', 'Adapté au diabète'),
      ('sans_gluten', 'Sans gluten'),
      ('vegan', 'Végétalien'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: diets.map((d) {
        final isSelected = selected == d.$1;
        return FilterChip(
          label: Text(d.$2),
          selected: isSelected,
          onSelected: (_) => onChanged(d.$1),
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
