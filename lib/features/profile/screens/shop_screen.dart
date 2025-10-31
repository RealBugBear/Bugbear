import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:free_base/features/profile/models/cosmetic_item.dart';
import 'package:free_base/features/profile/models/reflex_profile.dart';
import 'package:free_base/features/profile/state/profile_shop_notifier.dart';
import 'package:free_base/features/training/notifier/session_notifier.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.profile});

  final ReflexProfile profile;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String? _activeItemId;
  int _xpSpent = 0;

  @override
  void initState() {
    super.initState();
    _activeItemId = widget.profile.avatarItemId;
    _xpSpent = widget.profile.xpSpent;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = context.read<ProfileShopNotifier>();
      await notifier.ensureCatalogLoaded();
      await notifier.loadPurchases(widget.profile.id);
    });
  }

  @override
  void didUpdateWidget(covariant ShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id) {
      _activeItemId = widget.profile.avatarItemId;
      _xpSpent = widget.profile.xpSpent;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final notifier = context.read<ProfileShopNotifier>();
        await notifier.loadPurchases(widget.profile.id);
      });
    }
  }

  Future<void> _onAction(CosmeticItem item) async {
    final notifier = context.read<ProfileShopNotifier>();
    final result = await notifier.purchaseOrApply(
      profile: widget.profile,
      item: item,
    );
    if (!mounted) return;
    final message = result.message ?? 'Aktion ausgeführt';
    if (result.outcome == ShopActionOutcome.purchased) {
      setState(() {
        _activeItemId = item.id;
        _xpSpent += item.priceXp;
      });
    } else if (result.outcome == ShopActionOutcome.applied) {
      setState(() {
        _activeItemId = item.id;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildHeader(SessionNotifier sessionNotifier) {
    final xpBalance = sessionNotifier.state.xpTotal;
    final subtitle = 'Ausgegebene EXP: $_xpSpent';
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.profile.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Verfügbare EXP: $xpBalance'),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(ProfileShopNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Seltenheit:'),
          const SizedBox(width: 12),
          DropdownButton<CosmeticRarity?>(
            value: notifier.filter,
            items: const [
              DropdownMenuItem(value: null, child: Text('Alle')),
              DropdownMenuItem(
                value: CosmeticRarity.common,
                child: Text('Häufig'),
              ),
              DropdownMenuItem(
                value: CosmeticRarity.rare,
                child: Text('Selten'),
              ),
              DropdownMenuItem(
                value: CosmeticRarity.epic,
                child: Text('Episch'),
              ),
              DropdownMenuItem(
                value: CosmeticRarity.legendary,
                child: Text('Legendär'),
              ),
            ],
            onChanged: notifier.setFilter,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aktualisieren',
            onPressed: () async {
              await notifier.refreshCatalog();
              await notifier.loadPurchases(widget.profile.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    ProfileShopNotifier notifier,
    CosmeticItem item,
  ) {
    final theme = Theme.of(context);
    final owned = notifier.isOwned(widget.profile.id, item.id);
    final isActive = _activeItemId == item.id;
    final brightness = theme.colorScheme.brightness;
    final accent = rarityColor(item.rarity, brightness: brightness);
    final actionLabel = isActive
        ? 'Aktiv'
        : owned
            ? 'Anwenden'
            : 'Kaufen (${item.priceXp} XP)';
    final isProcessing = notifier.isProcessing(item.id);

    return Card(
      elevation: isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isActive ? accent : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: accent.withOpacity(0.2),
                    child: Icon(
                      Icons.style,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seltenheit: ${cosmeticRarityToString(item.rarity)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isActive || isProcessing ? null : () => _onAction(item),
              child: isProcessing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalog(
    ProfileShopNotifier notifier,
    SessionNotifier sessionNotifier,
  ) {
    if (notifier.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Der Shop konnte nicht geladen werden.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await notifier.refreshCatalog();
                  await notifier.loadPurchases(widget.profile.id);
                },
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    final items = notifier.catalog;
    if (notifier.isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return const Center(child: Text('Keine kosmetischen Items verfügbar.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) => _buildItemCard(notifier, items[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileShopNotifier, SessionNotifier>(
      builder: (context, notifier, sessionNotifier, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Kosmetik-Shop'),
          ),
          body: Column(
            children: [
              _buildHeader(sessionNotifier),
              if (notifier.offline)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: Colors.orangeAccent,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Offline-Modus: Es werden lokale Shop-Daten angezeigt.',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _buildFilter(notifier),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await notifier.refreshCatalog();
                    await notifier.loadPurchases(widget.profile.id);
                  },
                  child: _buildCatalog(notifier, sessionNotifier),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
