import 'package:flutter/material.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const _bgDark    = Color(0xFF2B2B2B);
const _bgCard    = Color(0xFF383838);
const _accent    = Color(0xFFE8A838);
const _accentDim = Color(0xFF7A561A);
const _textPrim  = Color(0xFFF5EDD6);
const _textSec   = Color(0xFF9A9A9A);
const _success   = Color(0xFF6DBF6A);
const _danger    = Color(0xFFE05C3A);
const _info      = Color(0xFF5B9BD5);

// ── Profile screen ────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  final String name;
  final String emoji;
  final int age;
  final int streak;

  const ProfileScreen({
    super.key,
    this.name    = 'Alex',
    this.emoji   = '🧑',
    this.age     = 25,
    this.streak  = 7,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn  = true;
  bool _familyShareOn    = false;
  bool _overdoseWarnings = true;
  bool _soundOn          = true;

  final List<Map<String, String>> _familyMembers = [];
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _addFamilyMember() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    setState(() {
      _familyMembers.add({'email': email, 'status': 'Pending'});
      _emailController.clear();
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite sent to $email'),
        backgroundColor: _success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddFamilyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add caregiver',
            style: TextStyle(color: _textPrim, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'They will receive alerts if you miss doses.',
              style: TextStyle(color: _textSec, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: _textPrim),
              decoration: InputDecoration(
                hintText: 'caregiver@email.com',
                hintStyle: TextStyle(color: _textSec),
                prefixIcon: Icon(Icons.email_outlined, color: _accent, size: 20),
                filled: true,
                fillColor: _bgDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _accentDim),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _accentDim),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _accent, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textSec)),
          ),
          ElevatedButton(
            onPressed: _addFamilyMember,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _bgDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send invite',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Profile',
          style: TextStyle(
            color: _accent,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Profile header ────────────────────────────────────────────
            _ProfileHeader(
              name: widget.name,
              emoji: widget.emoji,
              age: widget.age,
              streak: widget.streak,
            ),

            const SizedBox(height: 20),

            // ── Stats row ─────────────────────────────────────────────────
            _StatsRow(streak: widget.streak, age: widget.age),

            const SizedBox(height: 20),

            // ── Family sharing ────────────────────────────────────────────
            _SectionHeader(title: 'Family & caregivers'),
            const SizedBox(height: 10),
            _FamilyCard(
              members: _familyMembers,
              shareOn: _familyShareOn,
              onToggle: (v) => setState(() => _familyShareOn = v),
              onAdd: _showAddFamilyDialog,
              onRemove: (i) => setState(() => _familyMembers.removeAt(i)),
            ),

            const SizedBox(height: 20),

            // ── Notifications ─────────────────────────────────────────────
            _SectionHeader(title: 'Notifications'),
            const SizedBox(height: 10),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_rounded,
                  iconColor: _accent,
                  title: 'Dose reminders',
                  subtitle: 'Alert when it\'s time to take meds',
                  value: _notificationsOn,
                  onChanged: (v) => setState(() => _notificationsOn = v),
                ),
                _Divider(),
                _SettingsTile(
                  icon: Icons.volume_up_rounded,
                  iconColor: _info,
                  title: 'Sound alerts',
                  subtitle: 'Play buzzer sound with notifications',
                  value: _soundOn,
                  onChanged: (v) => setState(() => _soundOn = v),
                ),
                _Divider(),
                _SettingsTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: _danger,
                  title: 'Overdose warnings',
                  subtitle: 'Warn before exceeding daily dose limit',
                  value: _overdoseWarnings,
                  onChanged: (v) => setState(() => _overdoseWarnings = v),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── About ─────────────────────────────────────────────────────
            _SectionHeader(title: 'About'),
            const SizedBox(height: 10),
            _SettingsCard(
              children: [
                _InfoTile(
                  icon: Icons.medication_rounded,
                  iconColor: _accent,
                  title: 'App',
                  value: 'WALL-E Meds v1.0.0',
                ),
                _Divider(),
                _InfoTile(
                  icon: Icons.bluetooth_rounded,
                  iconColor: _info,
                  title: 'Dispenser',
                  value: 'HC-08 BLE Module',
                ),
                _Divider(),
                _InfoTile(
                  icon: Icons.cake_outlined,
                  iconColor: _success,
                  title: 'Age',
                  value: '${widget.age} years old',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Sign out ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: Icon(Icons.logout_rounded, color: _danger),
                label: Text('Sign out',
                    style: TextStyle(
                        color: _danger, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: _danger.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name, emoji;
  final int age, streak;
  const _ProfileHeader({
    required this.name,
    required this.emoji,
    required this.age,
    required this.streak,
  });

  String _petLabel() {
    if (age < 21)  return 'WALL-E companion';
    if (age <= 50) return 'M-O companion';
    return 'EVE companion';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgDark,
              border: Border.all(color: _accent, width: 2.5),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: _textPrim,
                        fontWeight: FontWeight.w800,
                        fontSize: 22)),
                const SizedBox(height: 4),
                Text(_petLabel(),
                    style: TextStyle(color: _accent, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('$streak day streak',
                        style: TextStyle(color: _textSec, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: _textSec, size: 20),
            onPressed: () {},
            tooltip: 'Edit profile',
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int streak, age;
  const _StatsRow({required this.streak, required this.age});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Day streak', value: '$streak', icon: '🔥')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Doses taken', value: '142', icon: '💊')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Level', value: '3', icon: '⭐')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: _textSec, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Family card ───────────────────────────────────────────────────────────────

class _FamilyCard extends StatelessWidget {
  final List<Map<String, String>> members;
  final bool shareOn;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _FamilyCard({
    required this.members,
    required this.shareOn,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Toggle row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.people_rounded, color: _success, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Share with family',
                          style: TextStyle(
                              color: _textPrim,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Text('Alert caregivers if you miss doses',
                          style: TextStyle(color: _textSec, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: shareOn,
                  onChanged: onToggle,
                  activeColor: _accent,
                ),
              ],
            ),
          ),

          if (shareOn) ...[
            Divider(height: 1, color: _accentDim.withValues(alpha: 0.2)),

            // Family members list
            ...members.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _info.withValues(alpha: 0.15),
                  child: Icon(Icons.person_outline, color: _info, size: 18),
                ),
                title: Text(m['email'] ?? '',
                    style: TextStyle(color: _textPrim, fontSize: 14)),
                subtitle: Text(m['status'] ?? '',
                    style: TextStyle(
                        color: m['status'] == 'Pending' ? _accent : _success,
                        fontSize: 12)),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: _textSec, size: 18),
                  onPressed: () => onRemove(i),
                ),
              );
            }),

            // Add button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: Icon(Icons.add, color: _accent, size: 18),
                  label: Text('Add caregiver',
                      style: TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: _accent.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Reusable settings components ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          color: _textPrim, fontWeight: FontWeight.w700, fontSize: 15),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: _textPrim,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(color: _textSec, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _accent),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(color: _textSec, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: _textPrim,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1,
        indent: 64,
        color: _accentDim.withValues(alpha: 0.2));
  }
}