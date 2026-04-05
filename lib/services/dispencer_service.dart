import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DispenserService {
  static final DispenserService _instance = DispenserService._internal();
  factory DispenserService() => _instance;
  DispenserService._internal();

  // BLE device reference
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;

  // Connection state
  bool get isConnected => _connectedDevice != null;
  String get connectedDeviceName => _connectedDevice?.platformName ?? 'None';

  // UUIDs — match these to your ESP32 firmware
  static const String SERVICE_UUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String WRITE_UUID   = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String NOTIFY_UUID  = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';

  // ─── SCAN FOR DEVICES ─────────────────────────────────────────────────────
  Stream<List<ScanResult>> scanForDispensers() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // ─── CONNECT ──────────────────────────────────────────────────────────────
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (BluetoothCharacteristic c in service.characteristics) {
            if (c.uuid.toString() == WRITE_UUID) {
              _writeCharacteristic = c;
            }
            if (c.uuid.toString() == NOTIFY_UUID) {
              _notifyCharacteristic = c;
              await c.setNotifyValue(true);
              _listenToDispenser();
            }
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint('DispenserService connect error: $e');
      _connectedDevice = null;
      return false;
    }
  }

  // ─── DISCONNECT ───────────────────────────────────────────────────────────
  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
  }

  // ─── DISPENSE PILL ────────────────────────────────────────────────────────
  // compartment: 1-7
  Future<bool> dispensePill(int compartment) async {
    if (_writeCharacteristic == null) {
      debugPrint('DispenserService: not connected');
      return false;
    }
    try {
      // Send command e.g. "DISPENSE:3" for compartment 3
      final command = 'DISPENSE:$compartment';
      await _writeCharacteristic!.write(command.codeUnits);
      debugPrint('DispenserService: sent $command');
      return true;
    } catch (e) {
      debugPrint('DispenserService dispensePill error: $e');
      return false;
    }
  }

  // ─── CHECK STATUS ─────────────────────────────────────────────────────────
  Future<bool> checkStatus() async {
    if (_writeCharacteristic == null) return false;
    try {
      await _writeCharacteristic!.write('STATUS'.codeUnits);
      return true;
    } catch (e) {
      debugPrint('DispenserService checkStatus error: $e');
      return false;
    }
  }

  // ─── GET PILL COUNT ───────────────────────────────────────────────────────
  Future<bool> requestPillCount(int compartment) async {
    if (_writeCharacteristic == null) return false;
    try {
      await _writeCharacteristic!.write('COUNT:$compartment'.codeUnits);
      return true;
    } catch (e) {
      debugPrint('DispenserService requestPillCount error: $e');
      return false;
    }
  }

  // ─── LISTEN TO DISPENSER RESPONSES ───────────────────────────────────────
  void _listenToDispenser() {
    _notifyCharacteristic?.onValueReceived.listen((value) {
      final response = String.fromCharCodes(value);
      debugPrint('DispenserService received: $response');

      // Parse responses from ESP32
      if (response.startsWith('DISPENSED:')) {
        final compartment = response.split(':')[1];
        debugPrint('Pill dispensed from compartment $compartment');
        // TODO: update DoseLog in Isar DB
      } else if (response.startsWith('COUNT:')) {
        final parts = response.split(':');
        final compartment = parts[1];
        final count = parts[2];
        debugPrint('Compartment $compartment has $count pills');
        // TODO: update Medication pill count in Isar DB
      } else if (response == 'ERROR') {
        debugPrint('Dispenser reported an error');
        // TODO: show error to user
      } else if (response == 'LOW') {
        debugPrint('Dispenser reports low pill count');
        // TODO: trigger refill notification
      }
    });
  }

  // ─── SYNC SCHEDULE TO DISPENSER ───────────────────────────────────────────
  // Send the full schedule so the dispenser can work offline
  Future<bool> syncSchedule(List<Map<String, dynamic>> schedules) async {
    if (_writeCharacteristic == null) return false;
    try {
      for (final schedule in schedules) {
        // Format: "SCHEDULE:compartment:hour:minute"
        final command =
            'SCHEDULE:${schedule['compartment']}:${schedule['hour']}:${schedule['minute']}';
        await _writeCharacteristic!.write(command.codeUnits);
        // Small delay between commands
        await Future.delayed(const Duration(milliseconds: 100));
      }
      debugPrint('DispenserService: schedule synced');
      return true;
    } catch (e) {
      debugPrint('DispenserService syncSchedule error: $e');
      return false;
    }
  }

  // ─── CONNECTION STREAM ────────────────────────────────────────────────────
  Stream<BluetoothConnectionState> get connectionStream =>
      _connectedDevice?.connectionState ??
      const Stream.empty();
}