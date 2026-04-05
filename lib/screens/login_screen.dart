import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  String _currentView = 'splash';
  Map<String, dynamic>? _selectedProfile;
  String _enteredPin = '';
  bool _pinError = false;

  final List<Map<String, dynamic>> _profiles = [
    {'name': 'Alex', 'emoji': '🧑', 'age': 28, 'pin': '1234', 'color': 0xFF4FC3F7, 'streak': 7},
    {'name': 'Jordan', 'emoji': '👴', 'age': 65, 'pin': '', 'color': 0xFFC4622D, 'streak': 3},
    {'name': 'Sam', 'emoji': '👧', 'age': 14, 'pin': '0000', 'color': 0xFF2ECC71, 'streak': 1},
  ];

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() => _currentView = 'profiles');
          _contentController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _selectProfile(Map<String, dynamic> profile) {
    final hasPin = (profile['pin'] as String).isNotEmpty;
    if (hasPin) {
      setState(() {
        _selectedProfile = profile;
        _currentView = 'pin';
        _enteredPin = '';
        _pinError = false;
      });
    } else {
      _enterApp(profile);
    }
  }

  void _enterApp(Map<String, dynamic> profile) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onPinDigit(String digit) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += digit;
      _pinError = false;
    });
    if (_enteredPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), _checkPin);
    }
  }

  void _onPinDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
  }

  void _checkPin() {
    if (_enteredPin == _selectedProfile!['pin']) {
      _enterApp(_selectedProfile!);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _pinError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F1A),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _currentView == 'splash'
            ? _buildSplash()
            : _currentView == 'profiles'
                ? _buildProfiles()
                : _currentView == 'pin'
                    ? _buildPin()
                    : _buildCreateProfile(),
      ),
    );
  }

  // ─── SPLASH ───────────────────────────────────────────────────────────────

  Widget _buildSplash() {
    return Center(
      key: const ValueKey('splash'),
      child: FadeTransition(
        opacity: _logoFade,
        child: ScaleTransition(
          scale: _logoScale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFC4622D), Color(0xFF7F3010)],
                  ),
                  border: Border.all(color: const Color(0xFFE8C84A), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC4622D).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(child: Text('💊', style: TextStyle(fontSize: 52))),
              ),
              const SizedBox(height: 28),
              const Text(
                'PILL·E',
                style: TextStyle(
                  color: Color(0xFFE8C84A),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your personal pill companion',
                style: TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 1),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFE8C84A).withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── PROFILES ─────────────────────────────────────────────────────────────

  Widget _buildProfiles() {
    return FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: SafeArea(
          key: const ValueKey('profiles'),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'WHO\'S TAKING\nTHEIR MEDS?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select your profile to continue',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    children: [
                      ..._profiles.map((p) => _buildProfileCard(p)),
                      const SizedBox(height: 16),
                      _buildAddProfileCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final color = Color(profile['color'] as int);
    final hasPin = (profile['pin'] as String).isNotEmpty;
    final isSenior = (profile['age'] as int) >= 60;

    return GestureDetector(
      onTap: () => _selectProfile(profile),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2235),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.06), blurRadius: 16, spreadRadius: 1),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D0F1A),
                border: Border.all(color: color, width: 2.5),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, spreadRadius: 1),
                ],
              ),
              child: Center(
                child: Text(profile['emoji'], style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isSenior)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF4FC3F7).withOpacity(0.3),
                            ),
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
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '${profile['streak']} day streak',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Center(
                child: Icon(
                  hasPin ? Icons.lock_outline : Icons.arrow_forward_ios,
                  color: color,
                  size: hasPin ? 18 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProfileCard() {
    return GestureDetector(
      onTap: () => setState(() => _currentView = 'create'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8C84A).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFFE8C84A), size: 20),
            SizedBox(width: 8),
            Text(
              'ADD NEW PROFILE',
              style: TextStyle(
                color: Color(0xFFE8C84A),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PIN ──────────────────────────────────────────────────────────────────

  Widget _buildPin() {
    final profile = _selectedProfile!;
    final color = Color(profile['color'] as int);

    return SafeArea(
      key: const ValueKey('pin'),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFE8C84A)),
              onPressed: () => setState(() {
                _currentView = 'profiles';
                _enteredPin = '';
              }),
            ),
          ),
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0D0F1A),
              border: Border.all(color: color, width: 2.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 16, spreadRadius: 2),
              ],
            ),
            child: Center(
              child: Text(profile['emoji'], style: const TextStyle(fontSize: 38)),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile['name'],
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _pinError ? 'Wrong PIN. Try again.' : 'Enter your PIN',
            style: TextStyle(
              color: _pinError ? const Color(0xFFC4622D) : Colors.white38,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _enteredPin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? _pinError
                          ? const Color(0xFFC4622D)
                          : color
                      : Colors.transparent,
                  border: Border.all(
                    color: filled
                        ? _pinError
                            ? const Color(0xFFC4622D)
                            : color
                        : Colors.white24,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 48),
          _buildNumpad(color),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildNumpad(Color accentColor) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 72, height: 72);
              return GestureDetector(
                onTap: () => key == 'del' ? _onPinDelete() : _onPinDigit(key),
                child: Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2235),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF3A3050)),
                  ),
                  child: Center(
                    child: key == 'del'
                        ? const Icon(Icons.backspace_outlined, color: Colors.white54, size: 22)
                        : Text(
                            key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // ─── CREATE PROFILE ───────────────────────────────────────────────────────

  Widget _buildCreateProfile() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String selectedEmoji = '🧑';
    final avatars = ['🧑', '👦', '👧', '🧒', '👴', '👵', '🤖', '👾', '🐱', '🐶', '🦊', '🐸'];

    return SafeArea(
      key: const ValueKey('create'),
      child: StatefulBuilder(
        builder: (context, setLocal) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            IconButton(
              alignment: Alignment.centerLeft,
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFE8C84A)),
              onPressed: () => setState(() => _currentView = 'profiles'),
            ),
            const SizedBox(height: 10),
            const Text(
              'CREATE PROFILE',
              style: TextStyle(
                color: Color(0xFFE8C84A),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set up a new user profile',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 32),
            const Text(
              'CHOOSE AVATAR',
              style: TextStyle(
                color: Color(0xFFE8C84A),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: avatars.map((emoji) {
                final selected = selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () => setLocal(() => selectedEmoji = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF4FC3F7).withOpacity(0.15)
                          : const Color(0xFF1F2235),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? const Color(0xFF4FC3F7) : const Color(0xFF3A3050),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Text(
              'NAME',
              style: TextStyle(
                color: Color(0xFFE8C84A),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter name',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4FC3F7), size: 20),
                filled: true,
                fillColor: const Color(0xFF1F2235),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF3A3050)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF3A3050)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AGE',
              style: TextStyle(
                color: Color(0xFFE8C84A),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter age',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF4FC3F7), size: 20),
                filled: true,
                fillColor: const Color(0xFF1F2235),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF3A3050)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF3A3050)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Age determines your experience (senior mode for 60+)',
              style: TextStyle(color: Colors.white24, fontSize: 11),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
                  setState(() {
                    _profiles.add({
                      'name': nameController.text,
                      'emoji': selectedEmoji,
                      'age': int.tryParse(ageController.text) ?? 0,
                      'pin': '',
                      'color': 0xFF4FC3F7,
                      'streak': 0,
                    });
                    _currentView = 'profiles';
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC4622D), Color(0xFFE07840)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC4622D).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'CREATE PROFILE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}