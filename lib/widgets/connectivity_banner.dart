import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Displays a lightweight banner whenever the device is offline.
///
/// The widget listens to connectivity updates and can optionally receive
/// custom [connectivityStream] and [checkConnectivity] callbacks which makes it
/// easy to mock in tests.
class ConnectivityBanner extends StatefulWidget {
  final Stream<ConnectivityResult>? connectivityStream;
  final Future<ConnectivityResult> Function()? checkConnectivity;

  const ConnectivityBanner({
    super.key,
    this.connectivityStream,
    this.checkConnectivity,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  ConnectivityResult? _status;
  StreamSubscription<ConnectivityResult>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = (widget.connectivityStream ??
            Connectivity().onConnectivityChanged)
        .listen((result) {
      if (!mounted) return;
      setState(() => _status = result);
    });
    _initCurrentStatus();
  }

  Future<void> _initCurrentStatus() async {
    try {
      final checker = widget.checkConnectivity ??
          () => Connectivity().checkConnectivity();
      final result = await checker();
      if (!mounted) return;
      setState(() => _status = result);
    } catch (_) {
      // If the connectivity plugin is unavailable we simply keep the banner
      // hidden. This can happen in widget tests without platform channels.
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offline = _status == ConnectivityResult.none;
    if (!offline) {
      return const SizedBox.shrink();
    }

    final locale = Localizations.maybeLocaleOf(context);
    final isGerman = locale?.languageCode.toLowerCase() == 'de';
    final message = isGerman
        ? 'Keine Internetverbindung. Wir synchronisieren automatisch, sobald du wieder online bist.'
        : 'You are offline. We will sync automatically once you are back online.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
