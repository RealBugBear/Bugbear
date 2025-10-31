import 'package:flutter/material.dart';

enum CosmeticRarity { common, rare, epic, legendary }

CosmeticRarity cosmeticRarityFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'rare':
      return CosmeticRarity.rare;
    case 'epic':
      return CosmeticRarity.epic;
    case 'legendary':
      return CosmeticRarity.legendary;
    default:
      return CosmeticRarity.common;
  }
}

String cosmeticRarityToString(CosmeticRarity rarity) {
  switch (rarity) {
    case CosmeticRarity.rare:
      return 'rare';
    case CosmeticRarity.epic:
      return 'epic';
    case CosmeticRarity.legendary:
      return 'legendary';
    case CosmeticRarity.common:
      return 'common';
  }
}

Color rarityColor(CosmeticRarity rarity, {Brightness brightness = Brightness.light}) {
  switch (rarity) {
    case CosmeticRarity.common:
      return brightness == Brightness.dark
          ? Colors.blueGrey.shade200
          : Colors.blueGrey.shade400;
    case CosmeticRarity.rare:
      return brightness == Brightness.dark ? Colors.indigo.shade200 : Colors.indigo;
    case CosmeticRarity.epic:
      return brightness == Brightness.dark ? Colors.purpleAccent.shade100 : Colors.purple;
    case CosmeticRarity.legendary:
      return brightness == Brightness.dark ? Colors.amberAccent.shade100 : Colors.amber;
  }
}

class CosmeticItem {
  CosmeticItem({
    required this.id,
    required this.name,
    required this.priceXp,
    required this.assetPath,
    required this.rarity,
  });

  final String id;
  final String name;
  final int priceXp;
  final String assetPath;
  final CosmeticRarity rarity;

  factory CosmeticItem.fromMap(Map<String, dynamic> data, String id) {
    return CosmeticItem(
      id: id,
      name: data['name'] as String? ?? 'Kosmetik',
      priceXp: (data['priceXp'] as num?)?.round() ?? 0,
      assetPath: data['assetPath'] as String? ?? '',
      rarity: cosmeticRarityFromString(data['rarity'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'priceXp': priceXp,
        'assetPath': assetPath,
        'rarity': cosmeticRarityToString(rarity),
      };

  Map<String, dynamic> toCache() => {
        'id': id,
        ...toMap(),
      };
}
