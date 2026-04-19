import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/storage_service.dart';
import 'scan_models.dart';

class ScanHistoryService {
  final StorageService _storage;
  static const String _historyKey = 'scan_history_list';

  ScanHistoryService(this._storage);

  Future<void> saveScan(ScanResult result) async {
    final history = await getHistory();
    // Eviter les doublons si même ID
    if (!history.any((s) => s.id == result.id)) {
      final updatedHistory = [result, ...history];
      // On garde les 20 derniers scans pour la performance
      final limitedHistory = updatedHistory.take(20).toList();
      
      final jsonList = limitedHistory.map((s) => jsonEncode(s.toJson())).toList();
      await _storage.setStringList(_historyKey, jsonList);
    }
  }

  Future<List<ScanResult>> getHistory() async {
    final jsonList = _storage.getStringList(_historyKey);
    if (jsonList == null) return [];

    try {
      return jsonList.map((s) => ScanResult.fromJson(jsonDecode(s))).toList();
    } catch (e) {
      print('Error parsing scan history: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    await _storage.remove(_historyKey);
  }
}

final scanHistoryServiceProvider = Provider<ScanHistoryService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ScanHistoryService(storage);
});
