import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider);
    
    // Si pas connecté la garde de navigation redirige déjà vers /login
    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadgesSection(),
                  const SizedBox(height: 32),
                  _buildStatsSection(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('SETTINGS'),
                  const SizedBox(height: 16),
                  _buildSettingsList(context, ref),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, dynamic user) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background elements
            _buildBackgroundDesign(),
            
            // Profile Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pravatar.cc/150?u=${user.id}',
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CircularProgressIndicator(color: Colors.white24);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.location ?? 'No location set',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDesign() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -40,
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBadge(FontAwesomeIcons.circleCheck, 'Verified', Colors.blue),
        _buildBadge(FontAwesomeIcons.award, 'Top Seller', Colors.orange),
        _buildBadge(FontAwesomeIcons.leaf, 'Eco-Farmer', Colors.green),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('12', 'Ventes'),
          _buildVerticalDivider(),
          _buildStatItem('5', 'Cours'),
          _buildVerticalDivider(),
          _buildStatItem('8', 'Champs'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildSettingsItem(
          icon: FontAwesomeIcons.userPen,
          title: 'Modifier le profil',
          subtitle: 'Infos personnelles, adresse...',
        ),
        _buildSettingsItem(
          icon: FontAwesomeIcons.bell,
          title: 'Notifications',
          subtitle: 'Alertes météo, ventes...',
        ),
        _buildSettingsItem(
          icon: FontAwesomeIcons.shieldHalved,
          title: 'Sécurité',
          subtitle: 'Mot de passe, authentification...',
        ),
        _buildSettingsItem(
          icon: FontAwesomeIcons.circleInfo,
          title: 'Aide & Support',
          subtitle: 'FAQ, nous contacter...',
        ),
        const SizedBox(height: 24),
        _buildSettingsItem(
          icon: FontAwesomeIcons.rightFromBracket,
          title: 'Déconnexion',
          subtitle: 'Quitter l\'application',
          titleColor: Colors.red,
          iconColor: Colors.red,
          onTap: () async {
            await ref.read(authServiceProvider).logout();
            // Réinitialise l'état et redirige vers /login
            ref.read(authStateProvider.notifier).state = null;
            if (context.mounted) context.go('/login');
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FaIcon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}
