import 'package:cloud_firestore/cloud_firestore.dart';

class CosmeticPurchase {
  CosmeticPurchase({
    required this.id,
    required this.profileId,
    required this.itemId,
    required this.unlockedAt,
  });

  final String id;
  final String profileId;
  final String itemId;
  final DateTime unlockedAt;

  factory CosmeticPurchase.fromMap(Map<String, dynamic> data, String id) {
    final timestamp = data['unlockedAt'];
    DateTime unlockedAt;
    if (timestamp is Timestamp) {
      unlockedAt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      unlockedAt = timestamp;
    } else {
      unlockedAt = DateTime.now();
    }
    return CosmeticPurchase(
      id: id,
      profileId: data['profileId'] as String? ?? '',
      itemId: data['itemId'] as String? ?? '',
      unlockedAt: unlockedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'profileId': profileId,
        'itemId': itemId,
        'unlockedAt': Timestamp.fromDate(unlockedAt),
      };
}
