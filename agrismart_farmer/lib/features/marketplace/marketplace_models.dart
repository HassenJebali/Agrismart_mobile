import '../../core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String unit;
  final String? category;
  final String? imageUrl;
  final String? sellerId;
  final String? sellerName;
  final String? location;
  final String? description;
  final String? sellerPhone;
  final bool isAvailable;
  final String? status;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.category,
    this.imageUrl,
    this.sellerId,
    this.sellerName,
    this.location,
    this.description,
    this.sellerPhone,
    this.isAvailable = true,
    this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Mapping from Backend Offer to Flutter Product
    return Product(
      id: json['id'] ?? '',
      name: json['product'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      imageUrl: json['imageUrl'],
      sellerId: json['ownerEmail'],
      sellerName: json['producer'],
      location: json['availability'],
      description: json['description'],
      status: json['status'],
      isAvailable: json['status'] == 'validated',
    );
  }
}

class MarketplaceService {
  final ApiClient _api;

  MarketplaceService(this._api);

  Future<List<Product>> getProducts() async {
    try {
      final response = await _api.get('market/offers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    return [];
  }
}

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final api = ref.watch(apiClientProvider);
  return MarketplaceService(api);
});
