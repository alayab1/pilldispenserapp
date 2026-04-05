import 'package:flutter/material.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  final String petName = 'WALLE';
  final int coinBalance = 340;
  final int streakDays = 7;
  final double happiness = 0.72;
  final double energy = 0.55;
  final double cleanliness = 0.88;
  String _currentMood = 'Happy';
  String _currentEmoji = '🤖';

  final List<Map<String, dynamic>> _equippedItems = [
    {'name': 'Space Helmet', 'icon': '🪖', 'slot': 'head'},
    {'name': 'Bowtie', 'icon': '🎀', 'slot': 'accessory'},
  ];

  final List<Map<String, dynamic>> _recentActivity = [
    {'action': 'Took Vitamin D on time', 'reward': '+10 coins', 'time': '8:03 AM', 'icon': '💊'},
    {'action': '7 day streak bonus!', 'reward': '+50 coins', 'time': 'Today', 'icon': '🔥'},
    {'action': 'Took Omega-3 on time', 'reward': '+10 coins', 'time': '12:11 PM', 'icon': '💊'},
    {'action': 'Missed Melatonin', 'reward': '-5 happiness', 'time': 'Yesterday', 'icon': '😔'},
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _updateMood();
  }

  void _updateMood() {
    if (happiness >= 0.8) { _currentMood = 'Thriving'; _currentEmoji = '🤩'; }
    else if (happiness >= 0.6) { _currentMood = 'Happy'; _currentEmoji = '🤖'; }
    else if (happiness >= 0.4) { _currentMood = 'Okay'; _currentEmoji = '😐'; }
    else { _currentMood = 'Sad'; _currentEmoji = '😢'; }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F1A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFE8C84A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('MY PET', style: TextStyle(color: Color(0xFFE8C84A), fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 16)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2235),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8C84A).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFE8C84A), size: 15),
                const SizedBox(width: 4),
                Text('$coinBalance', style: const TextStyle(color: Color(0xFFE8C84A), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPetDisplay(),
          const SizedBox(height: 24),
          _buildStatusBars(),
          const SizedBox(height: 24),
          _buildEquippedItems(),
          const SizedBox(height: 24),
          _buildStreakBanner(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPetDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1F2940), Color(0xFF0D1520)]),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.08), blurRadius: 30, spreadRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['✦', '✧', '✦', '✧', '✦'].map((s) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(s, style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 10)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) => Transform.translate(offset: Offset(0, _floatAnimation.value), child: child),
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [const Color(0xFF4FC3F7).withOpacity(0.15), Colors.transparent]),
                    ),
                  ),
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1D2E),
                      border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.5), width: 2.5),
                    ),
                    child: Center(child: Text(_currentEmoji, style: const TextStyle(fontSize: 58))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(petName, style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.4)),
            ),
            child: Text(_currentMood.toUpperCase(), style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton('Feed', '🍎', const Color(0xFFC4622D)),
              const SizedBox(width: 12),
              _buildActionButton('Play', '🎮', const Color(0xFF4FC3F7)),
              const SizedBox(width: 12),
              _buildActionButton('Clean', '🛁', const Color(0xFF2ECC71)),
              const SizedBox(width: 12),
              _buildActionButton('Shop', '🛒', const Color(0xFFE8C84A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, String emoji, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBars() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A3050)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PET STATUS', style: TextStyle(color: Color(0xFFE8C84A), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
          const SizedBox(height: 16),
          _buildStatusBar('Happiness', happiness, '😊', const Color(0xFF2ECC71)),
          const SizedBox(height: 14),
          _buildStatusBar('Energy', energy, '⚡', const Color(0xFFE8C84A)),
          const SizedBox(height: 14),
          _buildStatusBar('Cleanliness', cleanliness, '✨', const Color(0xFF4FC3F7)),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String label, double value, String emoji, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
            Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFF3A3050),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEquippedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('EQUIPPED ITEMS', style: TextStyle(color: Color(0xFFE8C84A), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
            GestureDetector(onTap: () {}, child: const Text('Visit Shop →', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 12))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ..._equippedItems.map((item) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2235),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(item['icon'], style: const TextStyle(fontSize: 30)),
                    const SizedBox(height: 8),
                    Text(item['name'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(item['slot'].toString().toUpperCase(), style: const TextStyle(color: Color(0xFF4FC3F7), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
            )),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2235),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3A3050)),
                ),
                child: Column(
                  children: [
                    const Text('➕', style: TextStyle(fontSize: 30)),
                    const SizedBox(height: 8),
                    Text('Empty Slot', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2A1A0D), Color(0xFF1A100A)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC4622D).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streakDays DAY STREAK', style: const TextStyle(color: Color(0xFFE07840), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                const Text('Take today\'s pills to keep WALLE happy!', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFC4622D).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC4622D).withOpacity(0.5)),
            ),
            child: const Column(
              children: [
                Text('🪙', style: TextStyle(fontSize: 18)),
                SizedBox(height: 2),
                Text('+50', style: TextStyle(color: Color(0xFFE8C84A), fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT ACTIVITY', style: TextStyle(color: Color(0xFFE8C84A), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2235),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3A3050)),
          ),
          child: Column(
            children: _recentActivity.asMap().entries.map((entry) {
              final i = entry.key;
              final activity = entry.value;
              final isLast = i == _recentActivity.length - 1;
              final isPositive = (activity['reward'] as String).startsWith('+');
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Text(activity['icon'], style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activity['action'], style: const TextStyle(color: Colors.white, fontSize: 13)),
                              const SizedBox(height: 3),
                              Text(activity['time'], style: const TextStyle(color: Colors.white30, fontSize: 11)),
                            ],
                          ),
                        ),
                        Text(activity['reward'], style: TextStyle(color: isPositive ? const Color(0xFF2ECC71) : const Color(0xFFC4622D), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
