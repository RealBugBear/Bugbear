import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:free_base/features/profile/models/cosmetic_item.dart';
import 'package:free_base/features/profile/models/cosmetic_purchase.dart';
import 'package:free_base/features/profile/models/reflex_profile.dart';
import 'package:free_base/features/profile/services/profile_service.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';

enum ShopActionOutcome { purchased, applied, insufficientXp, unauthorized, error }

class ShopActionResult {
  ShopActionResult(this.outcome, {this.message});

  final ShopActionOutcome outcome;
  final String? message;

  bool get isSuccess =>
      outcome == ShopActionOutcome.purchased || outcome == ShopActionOutcome.applied;
}

class ProfileShopNotifier extends ChangeNotifier {
  ProfileShopNotifier({
    required this.firestore,
    required this.sessionNotifier,
    required this.cacheBox,
    ProfileService? profileService,
  }) : _profileService = profileService ?? ProfileService();

  final FirebaseFirestore firestore;
  final SessionNotifier sessionNotifier;
  final Box cacheBox;
  final ProfileService _profileService;

  final Map<String, List<CosmeticPurchase>> _purchasesByProfile = {};
  final Set<String> _processingItems = {};

  List<CosmeticItem> _catalog = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _offline = false;
  bool _catalogLoaded = false;
  CosmeticRarity? _filter;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get offline => _offline;
  CosmeticRarity? get filter => _filter;

  List<CosmeticItem> get catalog {
    if (_filter == null) return List.unmodifiable(_catalog);
    return _catalog.where((item) => item.rarity == _filter).toList(growable: false);
  }

  bool isProcessing(String itemId) => _processingItems.contains(itemId);

  List<CosmeticPurchase> purchasesFor(String profileId) =>
      List.unmodifiable(_purchasesByProfile[profileId] ?? <CosmeticPurchase>[]);

  bool isOwned(String profileId, String itemId) =>
      _purchasesByProfile[profileId]?.any((p) => p.itemId == itemId) ?? false;

  Future<void> ensureCatalogLoaded() async {
    if (_catalogLoaded) return;
    await loadCatalog();
  }

  Future<void> loadCatalog({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_catalogLoaded && !forceRefresh) return;
    _isLoading = true;
    _hasError = false;
    _offline = false;
    notifyListeners();
    try {
      final snapshot = await firestore.collection('cosmetics_catalog').get();
      _catalog = snapshot.docs
          .map((doc) => CosmeticItem.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => a.priceXp.compareTo(b.priceXp));
      _catalogLoaded = true;
      await cacheBox.put(
        'catalog',
        _catalog.map((e) => e.toCache()).toList(),
      );
    } on FirebaseException catch (e) {
      _offline = e.code == 'unavailable' || e.code == 'failed-precondition';
      if (!await _loadCatalogFromCache()) {
        _hasError = true;
      }
    } catch (_) {
      if (!await _loadCatalogFromCache()) {
        _hasError = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _loadCatalogFromCache() async {
    final cached = cacheBox.get('catalog');
    if (cached is List) {
      _catalog = cached
          .whereType<Map>()
          .map((raw) {
            final map = Map<String, dynamic>.from(raw as Map);
            final id = map['id'] as String? ?? (map['name'] as String? ?? '').toLowerCase();
            return CosmeticItem.fromMap(map, id);
          })
          .toList()
        ..sort((a, b) => a.priceXp.compareTo(b.priceXp));
      if (_catalog.isNotEmpty) {
        _catalogLoaded = true;
        return true;
      }
    }
    return false;
  }

  Future<void> refreshCatalog() => loadCatalog(forceRefresh: true);

  void setFilter(CosmeticRarity? rarity) {
    _filter = rarity;
    notifyListeners();
  }

  Future<void> loadPurchases(String profileId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _purchasesByProfile[profileId] = <CosmeticPurchase>[];
      notifyListeners();
      return;
    }
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('cosmetics')
          .where('profileId', isEqualTo: profileId)
          .orderBy('unlockedAt', descending: true)
          .get();
      _purchasesByProfile[profileId] = snapshot.docs
          .map((doc) => CosmeticPurchase.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load purchases: ${e.code}');
      }
    }
  }

  Future<ShopActionResult> purchaseOrApply({
    required ReflexProfile profile,
    required CosmeticItem item,
  }) async {
    if (isProcessing(item.id)) {
      return ShopActionResult(
        ShopActionOutcome.error,
        message: 'Aktion läuft bereits.',
      );
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return ShopActionResult(ShopActionOutcome.unauthorized,
          message: 'Bitte melde dich erneut an.');
    }
    if (profile.avatarItemId == item.id) {
      return ShopActionResult(
        ShopActionOutcome.applied,
        message: 'Bereits aktiv.',
      );
    }
    if (isOwned(profile.id, item.id)) {
      return _applyItem(user.uid, profile, item);
    }
    if (sessionNotifier.state.xpTotal < item.priceXp) {
      return ShopActionResult(
        ShopActionOutcome.insufficientXp,
        message: 'Nicht genügend EXP vorhanden.',
      );
    }
    _processingItems.add(item.id);
    notifyListeners();
    try {
      final docRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('cosmetics')
          .doc();
      await firestore.runTransaction((transaction) async {
        transaction.set(docRef, {
          'profileId': profile.id,
          'itemId': item.id,
          'unlockedAt': FieldValue.serverTimestamp(),
        });
        transaction.set(
          firestore
              .collection('users')
              .doc(user.uid)
              .collection('profiles')
              .doc(profile.id),
          {
            'avatarItemId': item.id,
            'xpSpent': FieldValue.increment(item.priceXp),
          },
          SetOptions(merge: true),
        );
      });
      sessionNotifier.spendXp(item.priceXp);
      final purchase = CosmeticPurchase(
        id: docRef.id,
        profileId: profile.id,
        itemId: item.id,
        unlockedAt: DateTime.now(),
      );
      final current = List<CosmeticPurchase>.from(_purchasesByProfile[profile.id] ?? []);
      current.insert(0, purchase);
      _purchasesByProfile[profile.id] = current;
      _processingItems.remove(item.id);
      notifyListeners();
      return ShopActionResult(ShopActionOutcome.purchased,
          message: '${item.name} wurde freigeschaltet.');
    } on FirebaseException catch (e) {
      _processingItems.remove(item.id);
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Kauf fehlgeschlagen: ${e.code}');
      }
      if (e.code == 'unavailable') {
        _offline = true;
        notifyListeners();
      }
      return ShopActionResult(
        ShopActionOutcome.error,
        message: 'Kauf fehlgeschlagen. Bitte später erneut versuchen.',
      );
    }
  }

  Future<ShopActionResult> _applyItem(
    String userId,
    ReflexProfile profile,
    CosmeticItem item,
  ) async {
    try {
      await _profileService.updateProfileAppearance(
        userId,
        profile.id,
        avatarItemId: item.id,
      );
      return ShopActionResult(
        ShopActionOutcome.applied,
        message: '${item.name} aktiviert.',
      );
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('Aktivieren fehlgeschlagen: ${e.code}');
      }
      return ShopActionResult(
        ShopActionOutcome.error,
        message: 'Aktivierung nicht möglich.',
      );
    }
  }
}
