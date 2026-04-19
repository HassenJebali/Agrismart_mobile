class Plot {
  final String id;
  final String name;
  final double sizeHa;
  final String status; // 'healthy' or 'alert'
  final String colorHex;
  final List<GeoPoint>? boundary;
  final List<PlotSensor>? sensors;

  Plot({
    required this.id,
    required this.name,
    required this.sizeHa,
    required this.status,
    this.colorHex = '#4CAF50',
    this.boundary,
    this.sensors,
  });

  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sizeHa: (json['sizeHa'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'healthy',
      colorHex: json['colorHex'] ?? '#4CAF50',
      boundary: json['boundary'] != null
          ? (json['boundary'] as List).map((i) => GeoPoint.fromJson(i)).toList()
          : null,
      sensors: json['sensors'] != null
          ? (json['sensors'] as List).map((i) => PlotSensor.fromJson(i)).toList()
          : null,
    );
  }
}

class GeoPoint {
  final double lat;
  final double lng;

  GeoPoint({required this.lat, required this.lng});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PlotSensor {
  final String id;
  final String name;
  final String type;
  final String status;
  final String? unit;
  final double? lastValue;
  final DateTime? lastReadingAt;
  final GeoPoint position;

  PlotSensor({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.unit,
    this.lastValue,
    this.lastReadingAt,
    required this.position,
  });

  factory PlotSensor.fromJson(Map<String, dynamic> json) {
    return PlotSensor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'online',
      unit: json['unit'],
      lastValue: (json['lastValue'] as num?)?.toDouble(),
      lastReadingAt: json['lastReadingAt'] != null 
          ? DateTime.tryParse(json['lastReadingAt'].toString()) 
          : null,
      position: GeoPoint.fromJson(json['position'] ?? {}),
    );
  }
}

class DashboardStats {
  final int totalPlots;
  final int healthyPlots;
  final int activeAlerts;
  final int pendingOrders;

  const DashboardStats({
    this.totalPlots = 0,
    this.healthyPlots = 0,
    this.activeAlerts = 0,
    this.pendingOrders = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPlots: json['totalPlots'] ?? 0,
      healthyPlots: json['healthyPlots'] ?? 0,
      activeAlerts: json['activeAlerts'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
    );
  }
}

class DashboardState {
  final bool isLoading;
  final List<Plot> plots;
  final DashboardStats stats;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.plots = const [],
    this.stats = const DashboardStats(),
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    List<Plot>? plots,
    DashboardStats? stats,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      plots: plots ?? this.plots,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}
