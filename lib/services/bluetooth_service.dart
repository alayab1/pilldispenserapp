import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// ── HC-08 UART UUIDs ──────────────────────────────────────────────────────────
const _serviceUuid        = '0000ffe0-0000-1000-8000-00805f9b34fb';
const _characteristicUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';

// ── Commands ──────────────────────────────────────────────────────────────────
const dispenseCommand = [0x44]; // 0x44 = 'D' = dispense

// ── Bluetooth service ─────────────────────────────────────────────────────────

class BluetoothService extends ChangeNotifier {
  BluetoothDevice?        _device;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription?     _scanSub;
  StreamSubscription?     _stateSub;

  bool    _isScanning   = false;
  bool    _isConnected  = false;
  String  _statusMsg    = 'Not connected';
  List<ScanResult> _scanResults = [];

  bool    get isScanning   => _isScanning;
  bool    get isConnected  => _isConnected;
  String  get statusMsg    => _statusMsg;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get device => _device;

  // ── Scan for nearby BLE devices ─────────────────────────────────────────────
  Future<void> startScan() async {
    _scanResults.clear();
    _isScanning = true;
    _statusMsg  = 'Scanning...';
    notifyListeners();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    await Future.delayed(const Duration(seconds: 8));
    await stopScan();
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();
    _isScanning = false;
    _statusMsg  = _isConnected ? 'Connected' : 'Scan complete';
    notifyListeners();
  }

  // ── Connect to a device ──────────────────────────────────────────────────────
  Future<void> connect(BluetoothDevice device) async {
    _statusMsg = 'Connecting...';
    notifyListeners();

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _device = device;

      // Listen for disconnection
      _stateSub = device.connectionState.listen((state) {
        _isConnected = state == BluetoothConnectionState.connected;
        _statusMsg   = _isConnected ? 'Connected to ${device.platformName}' : 'Disconnected';
        if (!_isConnected) _characteristic = null;
        notifyListeners();
      });

      // Discover UART characteristic
      final services = await device.discoverServices();
      for (final s in services) {
        if (s.uuid.toString().toLowerCase() == _serviceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid.toString().toLowerCase() == _characteristicUuid) {
              _characteristic = c;
              break;
            }
          }
        }
      }

      if (_characteristic == null) {
        _statusMsg = 'HC-08 UART not found — check module';
      } else {
        _isConnected = true;
        _statusMsg   = 'Connected to ${device.platformName}';
      }
    } catch (e) {
      _statusMsg = 'Connection failed: $e';
    }

    notifyListeners();
  }

  // ── Disconnect ───────────────────────────────────────────────────────────────
  Future<void> disconnect() async {
    await _device?.disconnect();
    _stateSub?.cancel();
    _device         = null;
    _characteristic = null;
    _isConnected    = false;
    _statusMsg      = 'Disconnected';
    notifyListeners();
  }

  // ── Send dispense command (0x44) ─────────────────────────────────────────────
  Future<bool> dispense() async {
    if (_characteristic == null) {
      _statusMsg = 'Not connected — cannot dispense';
      notifyListeners();
      return false;
    }
    try {
      await _characteristic!.write(dispenseCommand, withoutResponse: true);
      _statusMsg = 'Dispense command sent!';
      notifyListeners();
      return true;
    } catch (e) {
      _statusMsg = 'Send failed: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Send any raw bytes ────────────────────────────────────────────────────────
  Future<bool> sendBytes(List<int> bytes) async {
    if (_characteristic == null) return false;
    try {
      await _characteristic!.write(bytes, withoutResponse: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Send a plain text string ──────────────────────────────────────────────────
  Future<bool> sendString(String text) async {
    return sendBytes(utf8.encode(text));
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }
}