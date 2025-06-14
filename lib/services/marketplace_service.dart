import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarketplaceListing {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final bool isActive;
  final List<String> images;
  final Map<String, dynamic> metadata;

  MarketplaceListing({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.isActive = true,
    this.images = const [],
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'images': images,
      'metadata': metadata,
    };
  }

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      sellerId: json['seller_id'] ?? '',
      sellerName: json['seller_name'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
      images: List<String>.from(json['images'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class MarketplaceService {
  static final MarketplaceService _instance = MarketplaceService._internal();
  factory MarketplaceService() => _instance;
  MarketplaceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new marketplace listing
  Future<String?> createListing({
    required String name,
    required String description,
    required double price,
    required String category,
    List<String> images = const [],
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to create listings');
      }

      // Get user profile for seller name
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      final sellerName = userDoc.data()?['name'] ?? 'Anonymous Seller';

      final listingId = _firestore.collection('marketplace_listings').doc().id;
      
      final listing = MarketplaceListing(
        id: listingId,
        name: name,
        description: description,
        price: price,
        category: category,
        sellerId: user.uid,
        sellerName: sellerName,
        createdAt: DateTime.now(),
        images: images,
        metadata: metadata,
      );

      await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .set(listing.toJson());

      // Add to user's listings collection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_listings')
          .doc(listingId)
          .set({
            'listing_id': listingId,
            'created_at': DateTime.now().toIso8601String(),
            'status': 'active',
          });

      return listingId;
    } catch (e) {
      print('Error creating listing: $e');
      return null;
    }
  }

  // Get all active marketplace listings
  Stream<List<MarketplaceListing>> getListings({
    String? category,
    String? searchQuery,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection('marketplace_listings')
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      List<MarketplaceListing> listings = snapshot.docs
          .map((doc) => MarketplaceListing.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Apply search filter locally (Firestore doesn't support text search easily)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        listings = listings.where((listing) {
          return listing.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                 listing.description.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      return listings;
    });
  }

  // Get user's own listings
  Stream<List<MarketplaceListing>> getUserListings() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('marketplace_listings')
        .where('seller_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketplaceListing.fromJson(doc.data()))
            .toList());
  }

  // Update listing
  Future<bool> updateListing({
    required String listingId,
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isActive,
    List<String>? images,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Verify user owns this listing
      final listingDoc = await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .get();

      if (!listingDoc.exists || listingDoc.data()?['seller_id'] != user.uid) {
        return false;
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (category != null) updates['category'] = category;
      if (isActive != null) updates['is_active'] = isActive;
      if (images != null) updates['images'] = images;
      if (metadata != null) updates['metadata'] = metadata;

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .update(updates);

      return true;
    } catch (e) {
      print('Error updating listing: $e');
      return false;
    }
  }

  // Delete listing
  Future<bool> deleteListing(String listingId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Verify user owns this listing
      final listingDoc = await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .get();

      if (!listingDoc.exists || listingDoc.data()?['seller_id'] != user.uid) {
        return false;
      }

      // Soft delete - mark as inactive
      await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .update({
            'is_active': false,
            'deleted_at': DateTime.now().toIso8601String(),
          });

      return true;
    } catch (e) {
      print('Error deleting listing: $e');
      return false;
    }
  }

  // Get listing by ID
  Future<MarketplaceListing?> getListing(String listingId) async {
    try {
      final doc = await _firestore
          .collection('marketplace_listings')
          .doc(listingId)
          .get();

      if (doc.exists) {
        return MarketplaceListing.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting listing: $e');
      return null;
    }
  }

  // Create purchase intent (for future payment processing)
  Future<String?> createPurchaseIntent({
    required String listingId,
    required String buyerId,
  }) async {
    try {
      final intentId = _firestore.collection('purchase_intents').doc().id;
      
      await _firestore
          .collection('purchase_intents')
          .doc(intentId)
          .set({
            'id': intentId,
            'listing_id': listingId,
            'buyer_id': buyerId,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          });

      return intentId;
    } catch (e) {
      print('Error creating purchase intent: $e');
      return null;
    }
  }

  // Analytics and stats
  Future<Map<String, dynamic>> getMarketplaceStats() async {
    try {
      final activeListingsSnapshot = await _firestore
          .collection('marketplace_listings')
          .where('is_active', isEqualTo: true)
          .get();

      final totalListings = activeListingsSnapshot.docs.length;
      
      final categories = <String, int>{};
      double totalValue = 0;

      for (final doc in activeListingsSnapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'Other';
        final price = (data['price'] ?? 0).toDouble();
        
        categories[category] = (categories[category] ?? 0) + 1;
        totalValue += price;
      }

      return {
        'total_listings': totalListings,
        'total_value': totalValue,
        'categories': categories,
        'average_price': totalListings > 0 ? totalValue / totalListings : 0,
      };
    } catch (e) {
      print('Error getting marketplace stats: $e');
      return {};
    }
  }
}