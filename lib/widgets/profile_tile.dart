import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  final String name;
  final String emoji;
  final int streakDays;
  final int coins;
  final bool isActive;
  final Color color;
  final bool isSenior;
  final bool hasPin;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProfileTile({
    super.key,
    required this.name,
    required this.emoji,
    required this.streakDays,
    required this.coins,
    this.isActive = false,
    this.color = const Color(0xFF4FC3F7),
    this.isSenior = false,
    this.hasPin = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(0.08)
              : const Color(0xFF1F2235),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? color.withOpacity(0.5)
                : const Color(0xFF3A3050),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D0F1A),
                border: Border.all(
                  color: isActive ? color : const Color(0xFF3A3050),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)]
                    : null,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white70,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isSenior)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
                          ),
                          child: const Text(
                            'SENIOR',
                            style: TextStyle(
                              color: Color(0xFF4FC3F7),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      if (hasPin) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.lock_outline, color: Colors.white30, size: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        '$streakDays day streak',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      const Text('🪙', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        '$coins coins',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Active badge or delete button
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.4)),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF2ECC71),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
