import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../recipes/domain/recipe.dart';
import '../../../recipes/presentation/providers/recipes_provider.dart';

const _allDietTags = [
  'standard',
  'diabetique',
  'sans_gluten',
  'vegan',
];

class RecipeFormScreen extends ConsumerStatefulWidget {
  final String? recipeId;

  const RecipeFormScreen({super.key, this.recipeId});

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _prepCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '2');
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final List<Ingredient> _ingredients = [];
  final List<String> _steps = [];
  final List<String> _selectedTags = [];
  File? _imageFile;
  String? _existingImageUrl;
  bool _saving = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipeId != null) {
      _isEdit = true;
      _loadRecipe();
    }
  }

  Future<void> _loadRecipe() async {
    final recipe = await ref
        .read(recipeRepositoryProvider)
        .getRecipe(widget.recipeId!);
    if (recipe == null || !mounted) return;
    setState(() {
      _titleCtrl.text = recipe.title;
      _descCtrl.text = recipe.description;
      _calCtrl.text = recipe.calories.toString();
      _prepCtrl.text = recipe.prepTime.toString();
      _servingsCtrl.text = recipe.servings.toString();
      _proteinCtrl.text = recipe.nutritionValues.protein.toString();
      _carbsCtrl.text = recipe.nutritionValues.carbs.toString();
      _fatCtrl.text = recipe.nutritionValues.fat.toString();
      _fiberCtrl.text = recipe.nutritionValues.fiber.toString();
      _ingredients.addAll(recipe.ingredients);
      _steps.addAll(recipe.steps);
      _selectedTags.addAll(recipe.dietTags);
      _existingImageUrl = recipe.imageUrl;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String> _uploadImage(String recipeId) async {
    if (_imageFile == null) return _existingImageUrl ?? '';
    final ref =
        FirebaseStorage.instance.ref('recipes/$recipeId.jpg');
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    try {
      final repo = ref.read(recipeRepositoryProvider);
      final recipeId =
          widget.recipeId ?? const Uuid().v4();

      final imageUrl = await _uploadImage(recipeId);

      final recipe = Recipe(
        id: recipeId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: imageUrl,
        authorId: uid,
        status: 'draft',
        calories: int.tryParse(_calCtrl.text) ?? 0,
        prepTime: int.tryParse(_prepCtrl.text) ?? 0,
        servings: int.tryParse(_servingsCtrl.text) ?? 1,
        ingredients: List.from(_ingredients),
        steps: List.from(_steps),
        dietTags: List.from(_selectedTags),
        nutritionValues: NutritionValues(
          protein: double.tryParse(_proteinCtrl.text) ?? 0,
          carbs: double.tryParse(_carbsCtrl.text) ?? 0,
          fat: double.tryParse(_fatCtrl.text) ?? 0,
          fiber: double.tryParse(_fiberCtrl.text) ?? 0,
        ),
        createdAt: DateTime.now(),
      );

      if (_isEdit) {
        await repo.updateRecipe(recipe);
      } else {
        await repo.createRecipe(recipe);
      }

      if (mounted) {
        context.go('/admin/recettes');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit
              ? 'Recette modifiée avec succès !'
              : 'Recette créée avec succès !'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de l\'enregistrement.')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _calCtrl.dispose();
    _prepCtrl.dispose();
    _servingsCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _fiberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la recette' : 'Nouvelle recette'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImagePicker(
                imageFile: _imageFile,
                existingUrl: _existingImageUrl,
                onTap: _pickImage,
              ),
              const SizedBox(height: 20),
              _sectionTitle('Informations générales'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                validator: (v) => Validators.required(v, 'Le titre'),
                decoration:
                    const InputDecoration(labelText: 'Titre de la recette'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _calCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.positiveInt(v, 'Les calories'),
                      decoration: const InputDecoration(
                          labelText: 'Calories', suffixText: 'kcal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _prepCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.positiveInt(v, 'Le temps'),
                      decoration: const InputDecoration(
                          labelText: 'Temps', suffixText: 'min'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _servingsCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.positiveInt(v, 'Les portions'),
                      decoration: const InputDecoration(
                          labelText: 'Portions'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle('Valeurs nutritionnelles (pour toute la recette)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Protéines', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Glucides', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fatCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Lipides', suffixText: 'g'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fiberCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Fibres', suffixText: 'g'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle('Régimes alimentaires'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _allDietTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      if (selected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    }),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _IngredientsList(
                ingredients: _ingredients,
                onChanged: (list) => setState(() {
                  _ingredients
                    ..clear()
                    ..addAll(list);
                }),
              ),
              const SizedBox(height: 20),
              _StepsList(
                steps: _steps,
                onChanged: (list) => setState(() {
                  _steps
                    ..clear()
                    ..addAll(list);
                }),
              ),
              const SizedBox(height: 32),
              _saving
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : ElevatedButton(
                      onPressed: _save,
                      child: Text(_isEdit
                          ? 'Enregistrer les modifications'
                          : 'Créer la recette'),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary),
      );
}

class _ImagePicker extends StatelessWidget {
  final File? imageFile;
  final String? existingUrl;
  final VoidCallback onTap;

  const _ImagePicker(
      {required this.imageFile,
      required this.existingUrl,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageFile != null
            ? Image.file(imageFile!, fit: BoxFit.cover)
            : (existingUrl != null && existingUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: existingUrl!, fit: BoxFit.cover)
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: AppColors.textSecondary),
                      SizedBox(height: 8),
                      Text('Ajouter une image',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
      ),
    );
  }
}

class _IngredientsList extends StatefulWidget {
  final List<Ingredient> ingredients;
  final ValueChanged<List<Ingredient>> onChanged;

  const _IngredientsList(
      {required this.ingredients, required this.onChanged});

  @override
  State<_IngredientsList> createState() => _IngredientsListState();
}

class _IngredientsListState extends State<_IngredientsList> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();

  void _add() {
    final name = _nameCtrl.text.trim();
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final unit = _unitCtrl.text.trim();
    if (name.isEmpty || qty <= 0) return;
    final updated = [
      ...widget.ingredients,
      Ingredient(name: name, quantity: qty, unit: unit),
    ];
    widget.onChanged(updated);
    _nameCtrl.clear();
    _qtyCtrl.clear();
    _unitCtrl.clear();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingrédients',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(hintText: 'Nom'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _qtyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'Qté'),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _unitCtrl,
                decoration: const InputDecoration(hintText: 'Unité'),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: _add,
              icon: const Icon(Icons.add_circle,
                  color: AppColors.primary, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.ingredients.asMap().entries.map((e) => ListTile(
              dense: true,
              leading: const Icon(Icons.circle,
                  size: 8, color: AppColors.primary),
              title: Text(
                  '${e.value.name} — ${e.value.quantity} ${e.value.unit}'),
              trailing: IconButton(
                icon:
                    const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () {
                  final updated = List<Ingredient>.from(widget.ingredients)
                    ..removeAt(e.key);
                  widget.onChanged(updated);
                },
              ),
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }
}

class _StepsList extends StatefulWidget {
  final List<String> steps;
  final ValueChanged<List<String>> onChanged;

  const _StepsList({required this.steps, required this.onChanged});

  @override
  State<_StepsList> createState() => _StepsListState();
}

class _StepsListState extends State<_StepsList> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onChanged([...widget.steps, text]);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Étapes de préparation',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLines: 2,
                onSubmitted: (_) => _add(),
                decoration: const InputDecoration(hintText: 'Ajouter une étape...'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _add,
              icon: const Icon(Icons.add_circle,
                  color: AppColors.primary, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.steps.asMap().entries.map((e) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text('${e.key + 1}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10)),
              ),
              title: Text(e.value),
              trailing: IconButton(
                icon:
                    const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () {
                  final updated = List<String>.from(widget.steps)
                    ..removeAt(e.key);
                  widget.onChanged(updated);
                },
              ),
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }
}
