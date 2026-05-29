import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/admin_provider.dart';

const _roles = ['user', 'nutritionist', 'admin'];
const _roleLabels = {
  'user': 'Utilisateur',
  'nutritionist': 'Nutritionniste',
  'admin': 'Administrateur',
};
const _roleIcons = {
  'user': Icons.person,
  'nutritionist': Icons.health_and_safety,
  'admin': Icons.admin_panel_settings,
};
const _roleColors = {
  'user': AppColors.textSecondary,
  'nutritionist': AppColors.success,
  'admin': AppColors.secondary,
};

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des utilisateurs')),
      body: usersAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) =>
            const Center(child: Text('Erreur lors du chargement.')),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Aucun utilisateur.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (_, i) {
              final u = users[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(u.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(u.email),
                  trailing: DropdownButton<String>(
                    value: u.role,
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: AppColors.primary),
                    items: _roles
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _roleIcons[r],
                                    size: 16,
                                    color: _roleColors[r],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(_roleLabels[r] ?? r,
                                      style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (newRole) async {
                      if (newRole != null && newRole != u.role) {
                        await ref
                            .read(adminRepositoryProvider)
                            .updateUserRole(u.uid, newRole);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Rôle de ${u.name} mis à jour : ${_roleLabels[newRole]}'),
                          ));
                        }
                      }
                    },
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
