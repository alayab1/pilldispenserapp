import 'package:flutter/material.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String time;
  final String status; // 'taken', 'upcoming', 'missed', 'skipped'
  final int compartment;
  final Color color;
  final VoidCallback? onTakeDose;
  final VoidCallback? onSkip;
  final VoidCallback? onTap;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
    required this.compartment,
    this.color = const Color(0xFF4FC3F7),
    this.onTakeDose,
    this.onSkip,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case 'taken': return const Color(0xFF2ECC71);
      case 'missed': return const Color(0xFFC4622D);
      case 'skipped': return const Color(0xFFE8C84A);
      default: return const Color(0xFF4FC3F7);
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'taken': return '✓ TAKEN';
      case 'missed': return '✗ MISSED';
      case 'skipped': return '– SKIPPED';
      default: return '⏳ UPCOMING';
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

  @override
  Widget build(BuildContext context) {
    final isTaken = status == 'taken';
    final isUpcoming = status == 'upcoming';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2235),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isTaken
                ? const Color(0xFF2ECC71).withOpacity(0.3)
                : const Color(0xFF3A3050),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isUpcoming
                  ? color.withOpacity(0.06)
                  : Colors.transparent,
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Compartment badge
                _buildCompartmentBadge(),
                const SizedBox(width: 14),

                // Medication info
                Expanded(child: _buildMedInfo(isTaken)),

                // Time + status
                _buildTimeStatus(),
              ],
            ),

            // Action buttons for upcoming doses
            if (isUpcoming) ...[
              const SizedBox(height: 14),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  // ─── COMPARTMENT BADGE ────────────────────────────────────────────────────
  Widget _buildCompartmentBadge() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _statusIcon,
            style: TextStyle(
              color: _statusColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '#$compartment',
            style: TextStyle(
              color: _statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── MED INFO ─────────────────────────────────────────────────────────────
  Widget _buildMedInfo(bool isTaken) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            color: isTaken ? Colors.white.withOpacity(0.4) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: isTaken ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white38,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dosage,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ─── TIME + STATUS ────────────────────────────────────────────────────────
  Widget _buildTimeStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.12),
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
      ],
    );
  }

  // ─── ACTION BUTTONS ───────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Take Now button
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onTakeDose,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'TAKE NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Skip button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0F1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, color: Colors.white38, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'SKIP',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
