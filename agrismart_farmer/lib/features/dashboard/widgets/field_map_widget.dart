import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard_provider.dart';
import '../dashboard_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class FieldMapWidget extends ConsumerStatefulWidget {
  const FieldMapWidget({super.key});

  @override
  ConsumerState<FieldMapWidget> createState() => _FieldMapWidgetState();
}

class _FieldMapWidgetState extends ConsumerState<FieldMapWidget> {
  MapLibreMapController? mapController;

  final String osmStyle = 'data:application/json;base64,eyJ2ZXJzaW9uIjo4LCJzb3VyY2VzIjp7Im9zbS10aWxlcyI6eyJ0eXBlIjoicmFzdGVyIiwidGlsZXMiOlsiaHR0cHM6Ly90aWxlLm9wZW5zdHJlZXRtYXAub3JnL3t6fS97eH0ve3l9LnBuZyJdLCJ0aWxlU2l6ZSI6MjU2LCJhdHRyaWJ1dGlvbiI6IiBPcGVuU3RyZWV0TWFwIGNvbnRyaWJ1dG9ycyJ9fSwibGF5ZXJzIjpbeyJpZCI6Im9zbS1sYXllciIsInR5cGUiOiJyYXN0ZXIiLCJzb3VyY2UiOiJvc20tdGlsZXMiLCJtaW56b29tIjowLCJtYXh6b29tIjoxOX1dfQ==';

  void _onMapCreated(MapLibreMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onStyleLoaded() {
    _updateMapContent();
  }

  void _updateMapContent() {
    if (mapController == null) return;
    
    // 1. Clear everything
    mapController!.clearSymbols();
    mapController!.clearFills();
    mapController!.clearLines();

    final plots = ref.read(dashboardProvider).plots;
    if (plots.isEmpty) return;
    
    // 2. Add Polygons (Fills & Lines)
    for (final plot in plots) {
      if (plot.boundary != null && plot.boundary!.length >= 3) {
        final List<LatLng> latLngs = plot.boundary!.map((gp) => LatLng(gp.lat, gp.lng)).toList();
        
        // Add the surface (Fill)
        mapController!.addFill(
          FillOptions(
            geometry: [latLngs],
            fillColor: plot.status == 'alert' ? '#FF9800' : (plot.colorHex.isEmpty ? '#4CAF50' : plot.colorHex),
            fillOpacity: 0.3,
            fillOutlineColor: '#FFFFFF',
          ),
        );

        // Add the border (Line)
        mapController!.addLine(
          LineOptions(
            geometry: latLngs + [latLngs.first], // close the loop
            lineColor: plot.status == 'alert' ? '#EF6C00' : '#2E7D32',
            lineWidth: 2.0,
            lineOpacity: 0.8,
          ),
        );

        // 3. Add Sensors (Symbols)
        if (plot.sensors != null) {
          for (final sensor in plot.sensors!) {
            final LatLng pos = LatLng(sensor.position.lat, sensor.position.lng);
            final bool isOnline = sensor.status == 'online';
            
            mapController!.addSymbol(
              SymbolOptions(
                geometry: pos,
                textField: _getSensorIcon(sensor.type),
                textSize: 18.0,
                textColor: isOnline ? '#FFFFFF' : '#FFEB3B',
                textHaloColor: isOnline ? '#2196F3' : '#F44336',
                textHaloWidth: 3.0,
                textAnchor: 'center',
              ),
            );
            
            // Background for sensor (optional circle can be added as a small fill or another symbol)
          }
        }
      }
    }

    // 4. Center Camera on first plot
    final firstPlot = plots.first;
    if (firstPlot.boundary != null && firstPlot.boundary!.isNotEmpty) {
      final center = firstPlot.boundary![0];
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(center.lat, center.lng), 14.0),
      );
    }
  }

  String _getSensorIcon(String type) {
    switch (type.toLowerCase()) {
      case 'soil_moisture': return '💧';
      case 'soil_temp': return '🌡️';
      case 'soil_ec': return '⚡';
      case 'pump': return '🔌';
      case 'water_flow': return '🌊';
      default: return '📡';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch plots to update markers when data changes
    ref.listen(dashboardProvider, (previous, next) {
      if (previous?.plots != next.plots) {
        _updateMapContent();
      }
    });

    return Container(
      height: 350, // Increased height for better view
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            RepaintBoundary(
              child: MapLibreMap(
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoaded,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(36.75, 10.15),
                  zoom: 9.0,
                ),
                styleString: osmStyle,
                myLocationEnabled: false,
                trackCameraPosition: true,
              ),
            ),
            if (mapController == null)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            // Map Legend/Overlay
            Positioned(
              top: 16,
              left: 16,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.layers_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Vue Satellite : ${ref.watch(dashboardProvider).plots.length} Parcelles',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
