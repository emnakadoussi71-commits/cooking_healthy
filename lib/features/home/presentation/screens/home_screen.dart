import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith('/home/accueil')) {
      currentIndex = 0;
    } else if (location.startsWith('/home/recettes')) {
      currentIndex = 1;
    } else if (location.startsWith('/home/nutrition')) {
      currentIndex = 2;
    } else if (location.startsWith('/home/favoris')) {
      currentIndex = 3;
    } else if (location.startsWith('/home/conseils') ||
        location.startsWith('/home/plans')) {
      currentIndex = 4;
    }

    final appUserAsync = ref.watch(currentAppUserProvider);
    final isAdmin = appUserAsync.valueOrNull?.isAdmin ?? false;
    final isNutritionist = appUserAsync.valueOrNull?.isNutritionist ?? false;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home/accueil');
            case 1:
              context.go('/home/recettes');
            case 2:
              context.go('/home/nutrition');
            case 3:
              context.go('/home/favoris');
            case 4:
              context.go('/home/conseils');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Recettes',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_weight_outlined),
            selectedIcon: Icon(Icons.monitor_weight),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            selectedIcon: Icon(Icons.health_and_safety),
            label: 'Conseils',
          ),
        ],
      ),
      drawer: _AppDrawer(isAdmin: isAdmin, isNutritionist: isNutritionist),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  final bool isAdmin;
  final bool isNutritionist;

  const _AppDrawer({required this.isAdmin, required this.isNutritionist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(currentAppUserProvider).valueOrNull;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(appUser?.name ?? ''),
              accountEmail: Text(appUser?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  appUser?.name.isNotEmpty == true
                      ? appUser!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              decoration: const BoxDecoration(color: AppColors.primary),
            ),
            if (isNutritionist || isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.dashboard_customize_outlined),
                title: const Text('Espace Nutritionniste'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/nutritionniste');
                },
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Publier un conseil'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/nutritionniste/conseil/creer');
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Créer un plan alimentaire'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/nutritionniste/plan/creer');
                },
              ),
            ],
            if (isAdmin) ...[
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.admin_panel_settings_outlined),
                title: const Text("Panneau d'administration"),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/admin');
                },
              ),
            ],
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Se déconnecter',
                  style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authRepositoryProvider).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
