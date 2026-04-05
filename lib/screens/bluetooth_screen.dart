import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const _bgDark   = Color(0xFF2B2B2B);
const _bgCard   = Color(0xFF383838);
const _accent   = Color(0xFFE8A838);
const _textPrim = Color(0xFFF5EDD6);
const _textSec  = Color(0xFF9A9A9A);
const _success  = Color(0xFF6DBF6A);
const _danger   = Color(0xFFE05C3A);

// ── Screen ────────────────────────────────────────────────────────────────────

class BluetoothScreen extends StatefulWidget {
  final BluetoothService btService;
  const BluetoothScreen({super.key, required this.btService});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  BluetoothService get _bt => widget.btService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _bt,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _bgDark,
          appBar: AppBar(
            backgroundColor: _bgDark,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: _accent, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Dispenser',
              style: TextStyle(
                color: _accent,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 1.1,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Status card ───────────────────────────────────────────
                _StatusCard(bt: _bt),
                const SizedBox(height: 20),

                // ── Dispense button (only when connected) ─────────────────
                if (_bt.isConnected) ...[
                  _DispenseButton(bt: _bt),
                  const SizedBox(height: 20),
                ],

                // ── Scan button ───────────────────────────────────────────
                if (!_bt.isConnected)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _bt.isScanning ? _bt.stopScan : _bt.startScan,
                      icon: Icon(_bt.isScanning ? Icons.stop : Icons.bluetooth_searching),
                      label: Text(_bt.isScanning ? 'Stop scan' : 'Scan for dispenser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: _bgDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // ── Scan results ──────────────────────────────────────────
                if (!_bt.isConnected && _bt.scanResults.isNotEmpty) ...[
                  Text(
                    'Nearby devices',
                    style: TextStyle(
                      color: _textPrim,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _bt.scanResults.length,
                      itemBuilder: (_, i) {
                        final result = _bt.scanResults[i];
                        final name = result.device.platformName.isNotEmpty
                            ? result.device.platformName
                            : 'Unknown device';
                        final rssi = result.rssi;
                        return _DeviceTile(
                          name: name,
                          rssi: rssi,
                          onTap: () => _bt.connect(result.device),
                        );
                      },
                    ),
                  ),
                ],

                // Disconnect button
                if (_bt.isConnected) ...[
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _bt.disconnect,
                      icon: Icon(Icons.bluetooth_disabled, color: _danger),
                      label: Text('Disconnect',
                          style: TextStyle(color: _danger)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _danger.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Status card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final BluetoothService bt;
  const _StatusCard({required this.bt});

  @override
  Widget build(BuildContext context) {
    final color = bt.isConnected ? _success : (bt.isScanning ? _accent : _textSec);
    final icon  = bt.isConnected
        ? Icons.bluetooth_connected
        : (bt.isScanning ? Icons.bluetooth_searching : Icons.bluetooth_disabled);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: bt.isScanning
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                        color: _accent, strokeWidth: 2.5),
                  )
                : Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bt.isConnected
                      ? 'Dispenser connected'
                      : (bt.isScanning ? 'Scanning...' : 'Not connected'),
                  style: TextStyle(
                    color: _textPrim,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bt.statusMsg,
                  style: TextStyle(color: _textSec, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dispense test button ──────────────────────────────────────────────────────

class _DispenseButton extends StatefulWidget {
  final BluetoothService bt;
  const _DispenseButton({required this.bt});

  @override
  State<_DispenseButton> createState() => _DispenseButtonState();
}

class _DispenseButtonState extends State<_DispenseButton> {
  bool _sending = false;

  Future<void> _onDispense() async {
    setState(() => _sending = true);
    final success = await widget.bt.dispense();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '💊 Dispense command sent!' : '❌ Failed to send command'),
          backgroundColor: success ? _success : _danger,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _sending ? null : _onDispense,
        icon: _sending
            ? SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    color: _bgDark, strokeWidth: 2))
            : const Icon(Icons.medication_rounded),
        label: Text(_sending ? 'Sending...' : 'Test dispense (0x44)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _success,
          foregroundColor: _bgDark,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ── Device tile in scan list ──────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  final String name;
  final int rssi;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.name,
    required this.rssi,
    required this.onTap,
  });

  IconData _signalIcon() {
    if (rssi > -60) return Icons.signal_cellular_alt;
    if (rssi > -80) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.2), width: 1),
      ),
      child: ListTile(
        leading: Icon(Icons.bluetooth, color: _accent),
        title: Text(name,
            style: TextStyle(
                color: _textPrim, fontWeight: FontWeight.w600)),
        subtitle: Text('Signal: $rssi dBm',
            style: TextStyle(color: _textSec, fontSize: 12)),
        trailing: Icon(_signalIcon(), color: _textSec, size: 20),
        onTap: onTap,
      ),
    );
  }
}