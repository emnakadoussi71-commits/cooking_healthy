import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/profile_setup_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/home_dashboard_screen.dart';
import '../features/recipes/presentation/screens/recipes_list_screen.dart';
import '../features/recipes/presentation/screens/recipe_detail_screen.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/nutrition/presentation/screens/dashboard_screen.dart';
import '../features/nutrition/presentation/screens/add_meal_screen.dart';
import '../features/recommendations/presentation/screens/recommendations_screen.dart';
import '../features/nutritionist/presentation/screens/nutritionist_dashboard_screen.dart';
import '../features/nutritionist/presentation/screens/advice_feed_screen.dart';
import '../features/nutritionist/presentation/screens/diet_plans_screen.dart';
import '../features/nutritionist/presentation/screens/create_advice_screen.dart';
import '../features/nutritionist/presentation/screens/create_diet_plan_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/manage_recipes_screen.dart';
import '../features/admin/presentation/screens/recipe_form_screen.dart';
import '../features/admin/presentation/screens/manage_users_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (previous, next) => notifier.value++);
  ref.listen(currentAppUserProvider, (previous, next) => notifier.value++);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authValue = ref.read(authStateProvider);
      if (authValue.isLoading) return null;

      final user = authValue.valueOrNull;
      final loc = state.matchedLocation;
      final isPublic = loc == '/login' || loc == '/register';

      if (user == null) {
        return isPublic ? null : '/login';
      }
      if (isPublic) return '/home/accueil';

      // Role-based guards (wait until role is resolved)
      final appUserValue = ref.read(currentAppUserProvider);
      if (appUserValue.isLoading) return null;
      final appUser = appUserValue.valueOrNull;

      if (loc.startsWith('/admin') && appUser?.isAdmin != true) {
        return '/home/accueil';
      }
      if (loc.startsWith('/nutritionniste') &&
          appUser?.isNutritionist != true &&
          appUser?.isAdmin != true) {
        return '/home/accueil';
      }

      return null;
    },
    routes: [
      // ── Public ─────────────────────────────────────────────────────────────
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
          path: '/profile-setup',
          builder: (context, state) => const ProfileSetupScreen()),

      // ── Main shell with bottom navigation ──────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          // Tab 0 — Accueil (personal dashboard)
          GoRoute(
            path: '/home/accueil',
            builder: (context, state) => const HomeDashboardScreen(),
          ),
          // Tab 1 — Recettes
          GoRoute(
            path: '/home/recettes',
            builder: (context, state) => const RecipesListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => RecipeDetailScreen(
                  recipeId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          // Tab 2 — Nutrition
          GoRoute(
            path: '/home/nutrition',
            builder: (context, state) => const DashboardScreen(),
            routes: [
              GoRoute(
                path: 'ajouter',
                builder: (context, state) => const AddMealScreen(),
              ),
            ],
          ),
          // Tab 3 — Favoris
          GoRoute(
              path: '/home/favoris',
              builder: (_, _) => const FavoritesScreen()),
          // Tab 4 — Conseils
          GoRoute(
              path: '/home/conseils',
              builder: (_, _) => const AdviceFeedScreen()),
          GoRoute(
              path: '/home/plans',
              builder: (_, _) => const DietPlansScreen()),
          // Kept as deep-link (no tab)
          GoRoute(
              path: '/home/recommandations',
              builder: (_, _) => const RecommendationsScreen()),
        ],
      ),

      // ── Nutritionist routes (role-guarded) ─────────────────────────────────
      GoRoute(
        path: '/nutritionniste',
        builder: (_, _) => const NutritionistDashboardScreen(),
      ),
      GoRoute(
        path: '/nutritionniste/conseil/creer',
        builder: (_, _) => const CreateAdviceScreen(),
      ),
      GoRoute(
        path: '/nutritionniste/plan/creer',
        builder: (_, _) => const CreateDietPlanScreen(),
      ),

      // ── Admin routes (role-guarded) ────────────────────────────────────────
      GoRoute(path: '/admin', builder: (_, _) => const AdminDashboardScreen()),
      GoRoute(
          path: '/admin/recettes',
          builder: (_, _) => const ManageRecipesScreen()),
      GoRoute(
          path: '/admin/recettes/creer',
          builder: (_, _) => const RecipeFormScreen()),
      GoRoute(
        path: '/admin/recettes/:id/modifier',
        builder: (_, state) =>
            RecipeFormScreen(recipeId: state.pathParameters['id']),
      ),
      GoRoute(
          path: '/admin/utilisateurs',
          builder: (_, _) => const ManageUsersScreen()),
    ],
  );

  ref.onDispose(notifier.dispose);
  return router;
});
