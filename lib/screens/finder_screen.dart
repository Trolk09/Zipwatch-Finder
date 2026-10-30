import 'package:flutter/material.dart';

import '../ble_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/ripples.dart';

class FinderScreen extends StatelessWidget {
  const FinderScreen({super.key, required this.c});
  final BleController c;

  Future<void> _rename(BuildContext context) async {
    final input = TextEditingController(text: c.deviceName);
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Zy.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rename device',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
            const SizedBox(height: 6),
            Text(
              'This changes the Bluetooth name of your device. It restarts to apply the new name.',
              style: TextStyle(color: Zy.muted, fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: input,
              autofocus: true,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              onSubmitted: (v) => Navigator.pop(ctx, v),
              decoration: InputDecoration(
                hintText: 'Zipwatch',
                filled: true,
                fillColor: Zy.surfaceHi,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Zy.cyan, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, input.text),
              child: const Text('Save name'),
            ),
          ],
        ),
      ),
    );
    input.dispose();
    if (name != null && name.trim().isNotEmpty && name.trim() != c.deviceName) {
      c.renameDevice(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    const BrandMark(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.deviceName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: Zy.ok, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('Connected', style: TextStyle(color: Zy.muted, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: Zy.card(),
                      child: Row(
                        children: [
                          SignalBars(rssi: c.rssi),
                          const SizedBox(width: 10),
                          Text(proximityLabel(c.rssi),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (c.error != null)
                  NoticeBanner(message: c.error!, actionLabel: 'Dismiss', onAction: c.clearError),
                Expanded(
                  child: Center(
                    child: _FindButton(
                      ringing: c.ringing,
                      onTap: c.ringing ? c.stop : c.find,
                    ),
                  ),
                ),
                Text(
                  c.ringing
                      ? 'Follow the sound. Tap the button to silence it.'
                      : 'Tap to ring the buzzer for 5 seconds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Zy.muted, fontSize: 14.5),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rename(context),
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        label: const Text('Rename'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: c.disconnect,
                        icon: const Icon(Icons.link_off_rounded, size: 20),
                        label: const Text('Disconnect'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The one memorable element: a big glowing button that pulses while the
/// device rings, with a ring that drains over the buzzer's 5 seconds.
class _FindButton extends StatefulWidget {
  const _FindButton({required this.ringing, required this.onTap});
  final bool ringing;
  final VoidCallback onTap;

  @override
  State<_FindButton> createState() => _FindButtonState();
}

class _FindButtonState extends State<_FindButton> with SingleTickerProviderStateMixin {
  late final AnimationController _timer =
      AnimationController(vsync: this, duration: kRingDuration);

  @override
  void didUpdateWidget(_FindButton old) {
    super.didUpdateWidget(old);
    if (widget.ringing && !old.ringing) {
      _timer.forward(from: 0);
    } else if (!widget.ringing && old.ringing) {
      _timer.value = 0;
    }
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringing = widget.ringing;
    return Ripples(
      active: ringing,
      size: 320,
      color: Zy.cyan,
      child: SizedBox(
        width: 236,
        height: 236,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _timer,
              builder: (_, __) => SizedBox.expand(
                child: CircularProgressIndicator(
                  value: ringing ? 1 - _timer.value : 1,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  color: ringing ? Zy.cyan : Colors.white.withAlpha(26),
                  backgroundColor: Colors.white.withAlpha(16),
                ),
              ),
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: ringing
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF6B81), Color(0xFFD62C4B)],
                        )
                      : Zy.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: (ringing ? Zy.danger : Zy.blue).withAlpha(120),
                      blurRadius: 50,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      ringing ? Icons.stop_rounded : Icons.notifications_active_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ringing ? 'Stop' : 'Find',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
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
