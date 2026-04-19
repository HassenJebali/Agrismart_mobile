import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_client.dart';
import 'scan_models.dart';
import 'history_service.dart';

class ScanService {
  final ApiClient _api;
  final ScanHistoryService _history;

  ScanService(this._api, this._history);

  Future<ScanResult> analyzeImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: image.name,
        ),
      });

      final response = await _api.post('plant-ai/diagnose', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        final String diagnostic = data['diagnostic'] ?? 'Unknown';
        final double confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
        
        final result = _mapResult(diagnostic, confidence / 100, image.path);
        
        // Save to history
        await _history.saveScan(result);
        
        return result;
      }
      throw Exception('Failed to analyze image: ${response.statusCode}');
    } catch (e) {
      print('Error in ScanService: $e');
      rethrow;
    }
  }

  ScanResult _mapResult(String label, double confidence, String imagePath) {
    String diseaseName;
    Severity severity;
    List<String> recommendations;

    switch (label) {
      case 'Gray_Leaf_Spot':
        diseaseName = 'Taches Grises (Cercosporiose)';
        severity = Severity.high;
        recommendations = [
          'Améliorez la circulation de l\'air entre les plants.',
          'Utilisez des variétés de maïs résistantes pour la prochaine saison.',
          'Appliquez un fongicide de type strobilurine ou triazole si l\'infection dépasse 5%.'
        ];
        break;
      case 'Common_Rust':
        diseaseName = 'Rouille Commune du Maïs';
        severity = Severity.medium;
        recommendations = [
          'Éliminez les résidus de culture infectés.',
          'Surveillez l\'humidité du feuillage.',
          'Appliquez un fongicide foliaire si les pustules se propagent rapidement.'
        ];
        break;
      case 'Northern_Leaf_Blight':
        diseaseName = 'Helminthosporiose du Nord';
        severity = Severity.high;
        recommendations = [
          'Pratiquez la rotation des cultures (ne pas replanter de maïs immédiatement).',
          'Labourer pour enfouir les résidus infectés.',
          'Traitement fongicide recommandé avant la floraison.'
        ];
        break;
      case 'Healthy':
        diseaseName = 'Plant Sain';
        severity = Severity.low;
        recommendations = [
          'Votre maïs est en excellente santé !',
          'Continuez une irrigation régulière.',
          'Vérifiez périodiquement l\'apparition de parasites.'
        ];
        break;
      default:
        diseaseName = 'Anomalie Détectée ($label)';
        severity = Severity.medium;
        recommendations = [
          'Consultez un agronome local pour confirmation.',
          'Isolez les plants suspects si possible.',
          'Prenez une photo plus nette pour un nouveau scan.'
        ];
    }

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      diseaseName: diseaseName,
      confidence: confidence,
      severity: severity,
      recommendations: recommendations,
      imageUrl: imagePath,
      timestamp: DateTime.now(),
    );
  }
}

final scanServiceProvider = Provider((ref) {
  final api = ref.watch(apiClientProvider);
  final history = ref.watch(scanHistoryServiceProvider);
  return ScanService(api, history);
});
