import 'package:flutter/material.dart';

class DoseHistoryTile extends StatelessWidget {
  final String medicationName;
  final String dosage;
  final String scheduledTime;
  final String? takenTime;
  final String status; // 'taken', 'missed', 'skipped', 'upcoming'

  const DoseHistoryTile({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case 'taken': return const Color(0xFF2ECC71);
      case 'missed': return const Color(0xFFC4622D);
      case 'skipped': return const Color(0xFFE8C84A);
      default: return const Color(0xFF4FC3F7);
    }
  }

  String get _statusIcon {
    switch (status) {
      case 'taken': return '✓';
      case 'missed': return '✗';
      case 'skipped': return '–';
      default: return '⏳';
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'taken': return 'TAKEN';
      case 'missed': return 'MISSED';
      case 'skipped': return 'SKIPPED';
      default: return 'UPCOMING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _statusColor.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                _statusIcon,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Medication info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dosage,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Time + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Scheduled $scheduledTime',
                style: const TextStyle(color: Colors.white30, fontSize: 11),
              ),
              if (takenTime != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Taken $takenTime',
                  style: const TextStyle(
                    color: Color(0xFF2ECC71),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
