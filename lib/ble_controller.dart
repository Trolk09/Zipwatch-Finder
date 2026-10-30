import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Must match the ESP32 firmware.
final Guid kServiceUuid = Guid('12345678-1234-1234-1234-123456789001');
final Guid kCharUuid = Guid('12345678-1234-1234-1234-123456789002');
const kRingDuration = Duration(seconds: 5); // firmware auto-stops after 5 s

enum LinkState { idle, connecting, connected }

class BleController extends ChangeNotifier {
  BluetoothAdapterState adapter = BluetoothAdapterState.unknown;
  List<ScanResult> results = const [];
  bool scanning = false;
  LinkState link = LinkState.idle;
  String deviceName = '';
  bool ringing = false;
  int? rssi;
  String? error;
  String? notice;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _char;
  final List<StreamSubscription> _subs = [];
  StreamSubscription? _connSub;
  Timer? _ringTimer;
  Timer? _rssiTimer;

  bool get bluetoothOn => adapter == BluetoothAdapterState.on;

  void init() {
    _subs.add(FlutterBluePlus.adapterState.listen((s) {
      adapter = s;
      notifyListeners();
      if (s == BluetoothAdapterState.on && link == LinkState.idle && !scanning) {
        startScan();
      }
    }));
    _subs.add(FlutterBluePlus.scanResults.listen((r) {
      results = [...r]..sort((a, b) => b.rssi.compareTo(a.rssi));
      notifyListeners();
    }));
    _subs.add(FlutterBluePlus.isScanning.listen((v) {
      scanning = v;
      notifyListeners();
    }));
  }

  static String nameOf(ScanResult r) {
    if (r.advertisementData.advName.isNotEmpty) return r.advertisementData.advName;
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    return 'Zipwatch';
  }

  String _clean(Object e) => e
      .toString()
      .replaceAll('FlutterBluePlusException | ', '')
      .replaceAll('Exception: ', '');

  void clearError() {
    error = null;
    notice = null;
    notifyListeners();
  }

  Future<void> turnOnBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      error = 'Bluetooth is off. Turn it on in Settings to find your device.';
      notifyListeners();
    }
  }

  Future<void> startScan() async {
    if (link != LinkState.idle || scanning) return;
    error = null;
    notifyListeners();
    try {
      await FlutterBluePlus.startScan(
        withServices: [kServiceUuid],
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      error = _clean(e);
      notifyListeners();
    }
  }

  Future<void> connect(ScanResult r) async {
    if (link != LinkState.idle) return;
    final d = r.device;
    error = null;
    notice = null;
    link = LinkState.connecting;
    _device = d;
    deviceName = nameOf(r);
    notifyListeners();
    try {
      await FlutterBluePlus.stopScan();
      await d.connect(timeout: const Duration(seconds: 12));
      final services = await d.discoverServices();
      BluetoothCharacteristic? found;
      for (final s in services) {
        if (s.uuid == kServiceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid == kCharUuid) found = c;
          }
        }
      }
      if (found == null) {
        throw 'This device does not support the finder service.';
      }
      _char = found;
      rssi = r.rssi;
      _connSub = d.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected) {
          _cleanup(message: 'Connection lost. Move closer and reconnect.');
        }
      });
      _rssiTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
        try {
          rssi = await d.readRssi();
          notifyListeners();
        } catch (_) {}
      });
      link = LinkState.connected;
      notifyListeners();
    } catch (e) {
      await _cleanup(message: 'Could not connect: ${_clean(e)}');
    }
  }

  Future<void> disconnect() async {
    await _cleanup();
  }

  Future<void> _cleanup({String? message, String? notice}) async {
    if (link == LinkState.idle && _device == null) return;
    _ringTimer?.cancel();
    _rssiTimer?.cancel();
    await _connSub?.cancel();
    _connSub = null;
    final d = _device;
    _device = null;
    _char = null;
    ringing = false;
    rssi = null;
    link = LinkState.idle;
    error = message;
    this.notice = notice;
    notifyListeners();
    if (d != null) {
      try {
        await d.disconnect();
      } catch (_) {}
    }
    Future.delayed(const Duration(milliseconds: 600), startScan);
  }

  Future<bool> _send(String cmd) async {
    final c = _char;
    if (c == null) return false;
    try {
      await c.write(utf8.encode(cmd));
      return true;
    } catch (e) {
      error = 'Command failed: ${_clean(e)}';
      notifyListeners();
      return false;
    }
  }

  /// Changes the Bluetooth name the ESP32 advertises. The ESP32 saves it and
  /// restarts, so the app drops the connection and scans again.
  Future<void> renameDevice(String newName) async {
    final name = newName.trim();
    if (name.isEmpty || name.length > 20) {
      error = 'Use 1 to 20 characters for the device name.';
      notifyListeners();
      return;
    }
    if (!await _send('NAME:$name')) return;
    await _cleanup(
      notice: 'Renamed to "$name". The device is restarting and will show up in the list in a moment.',
    );
  }

  Future<void> find() async {
    if (!await _send('FIND')) return;
    ringing = true;
    _ringTimer?.cancel();
    _ringTimer = Timer(kRingDuration, () {
      ringing = false;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> stop() async {
    _ringTimer?.cancel();
    ringing = false;
    notifyListeners();
    await _send('STOP');
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _connSub?.cancel();
    _ringTimer?.cancel();
    _rssiTimer?.cancel();
    super.dispose();
  }
}
