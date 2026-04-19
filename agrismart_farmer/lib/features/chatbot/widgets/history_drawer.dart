import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../scan/scan_models.dart';
import '../../scan/history_service.dart';
import '../../scan/scan_screen.dart';
import '../../../core/theme/app_colors.dart';

class ScanHistoryDrawer extends ConsumerWidget {
  const ScanHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(_historyFutureProvider);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // En-tête avec flèche de retour
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                  onPressed: () {
                    // Fermer le drawer et quitter l'écran de résultat pour revenir au scan principal
                    Navigator.of(context).pop(); // Ferme le drawer
                    Navigator.of(context).pop(); // Ferme le ScanResultScreen (retour au ScanScreen avec navbar)
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Historique des Analyses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: historyAsync.when(
              data: (history) => history.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: history.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final scan = history[index];
                        return _buildHistoryItem(context, scan);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucun historique disponible',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ScanResult scan) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        scan.diseaseName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        DateFormat('dd MMM yyyy, HH:mm', 'fr_FR').format(scan.timestamp),
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () {
        // Remplacer l'écran actuel par le scan sélectionné
        Navigator.of(context).pop(); // Ferme le drawer
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ScanResultScreen(result: scan)),
        );
      },
    );
  }
}

final _historyFutureProvider = FutureProvider<List<ScanResult>>((ref) async {
  final service = ref.watch(scanHistoryServiceProvider);
  return service.getHistory();
});
