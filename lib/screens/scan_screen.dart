import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/ripples.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key, required this.c});
  final BleController c;

  @override
  Widget build(BuildContext context) {
    final connecting = c.link == LinkState.connecting;
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const BrandMark(),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Finder',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                            Text('by Zyvro Technologies',
                                style: TextStyle(fontSize: 12.5, color: Zy.muted)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      c.results.isEmpty ? 'Find your device' : 'Devices nearby',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick your finder to connect and make it ring.',
                      style: TextStyle(fontSize: 14.5, color: Zy.muted),
                    ),
                    const SizedBox(height: 20),
                    if (!c.bluetoothOn && c.adapter != BluetoothAdapterState.unknown)
                      NoticeBanner(
                        message: 'Bluetooth is off.',
                        icon: Icons.bluetooth_disabled_rounded,
                        color: Zy.cyan,
                        actionLabel: 'Turn on',
                        onAction: c.turnOnBluetooth,
                      ),
                    if (c.error != null)
                      NoticeBanner(
                        message: c.error!,
                        actionLabel: 'Dismiss',
                        onAction: c.clearError,
                      ),
                    if (c.notice != null)
                      NoticeBanner(
                        message: c.notice!,
                        icon: Icons.check_circle_rounded,
                        color: Zy.ok,
                        actionLabel: 'OK',
                        onAction: c.clearError,
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: c.results.isEmpty
                            ? _Radar(scanning: c.scanning)
                            : ListView.separated(
                                key: const ValueKey('list'),
                                padding: EdgeInsets.zero,
                                itemCount: c.results.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (_, i) => _DeviceTile(
                                  result: c.results[i],
                                  onTap: () => c.connect(c.results[i]),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _GradientButton(
                      label: c.scanning ? 'Scanning…' : 'Scan again',
                      icon: Icons.radar_rounded,
                      onPressed: (c.scanning || !c.bluetoothOn) ? null : c.startScan,
                    ),
                  ],
                ),
              ),
              if (connecting)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withAlpha(190),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 46,
                            height: 46,
                            child: CircularProgressIndicator(strokeWidth: 3.5, color: Zy.cyan),
                          ),
                          const SizedBox(height: 18),
                          Text('Connecting to ${c.deviceName}…',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radar extends StatelessWidget {
  const _Radar({required this.scanning});
  final bool scanning;

  @override
  Widget build(BuildContext context) => Center(
        key: const ValueKey('radar'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ripples(
              active: scanning,
              size: 240,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Zy.surfaceHi,
                  border: Border.all(color: Zy.cyan.withAlpha(110), width: 1.5),
                ),
                child: const Icon(Icons.bluetooth_searching_rounded, size: 40, color: Zy.cyan),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              scanning ? 'Looking for your finder…' : 'No finder found yet',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              scanning
                  ? 'Keep the device powered and close by.'
                  : 'Make sure the ESP32 is powered, then scan again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Zy.muted, fontSize: 13.5),
            ),
          ],
        ),
      );
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.result, required this.onTap});
  final ScanResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: Zy.card(border: Zy.cyan.withAlpha(60)),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: Zy.gradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.watch_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(BleController.nameOf(result),
                        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(proximityLabel(result.rssi),
                        style: TextStyle(color: Zy.muted, fontSize: 13)),
                  ],
                ),
              ),
              SignalBars(rssi: result.rssi),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Zy.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: Zy.gradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
