import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/bluetooth_service.dart';

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
  final BluetoothService btService;

  const ProfileScreen({
    super.key,
    this.name    = 'Alex',
    this.emoji   = '🧑',
    this.age     = 25,
    this.streak  = 7,
    required this.btService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn  = true;
  bool _familyShareOn    = false;
  bool _overdoseWarnings = true;
  bool _soundOn          = true;

  // Editable profile fields
  late String _name;
  late String _emoji;
  late int    _age;

  final List<Map<String, String>> _familyMembers = [];
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name  = widget.name;
    _emoji = widget.emoji;
    _age   = widget.age;
  }

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

  void _showEditProfile() {
    final nameController  = TextEditingController(text: _name);
    final ageController   = TextEditingController(text: _age.toString());
    String selectedEmoji  = _emoji;
    const avatars = ['🧑', '👦', '👧', '🧒', '👴', '👵', '🤖', '👾', '🐱', '🐶', '🦊', '🐸'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 20, 24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: _textSec.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Edit profile',
                    style: TextStyle(
                        color: _textPrim,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 20),

                // Avatar picker
                Text('Avatar',
                    style: TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: avatars.map((e) {
                    final selected = selectedEmoji == e;
                    return GestureDetector(
                      onTap: () => setLocal(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: selected
                              ? _accent.withValues(alpha: 0.15)
                              : _bgDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? _accent : _textSec.withValues(alpha: 0.2),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                            child: Text(e,
                                style: const TextStyle(fontSize: 24))),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Name field
                Text('Name',
                    style: TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: _textPrim),
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    hintStyle: TextStyle(color: _textSec),
                    filled: true,
                    fillColor: _bgDark,
                    prefixIcon: Icon(Icons.person_outline,
                        color: _accent, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _accentDim)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _accentDim)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: _accent, width: 1.5)),
                  ),
                ),

                const SizedBox(height: 16),

                // Age field
                Text('Age',
                    style: TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5)),
                const SizedBox(height: 8),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: _textPrim),
                  decoration: InputDecoration(
                    hintText: 'Your age',
                    hintStyle: TextStyle(color: _textSec),
                    filled: true,
                    fillColor: _bgDark,
                    prefixIcon:
                        Icon(Icons.cake_outlined, color: _accent, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _accentDim)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _accentDim)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: _accent, width: 1.5)),
                  ),
                ),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final newAge =
                          int.tryParse(ageController.text.trim()) ?? _age;
                      final newName = nameController.text.trim();
                      if (newName.isEmpty) return;
                      setState(() {
                        _name  = newName;
                        _emoji = selectedEmoji;
                        _age   = newAge;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Profile updated!'),
                          backgroundColor: _success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _bgDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save changes',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign out?',
            style: TextStyle(
                color: _textPrim, fontWeight: FontWeight.w700)),
        content: Text(
          'You\'ll need to select your profile again to get back in.',
          style: TextStyle(color: _textSec, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textSec)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      LoginScreen(btService: widget.btService),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign out',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
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
              name: _name,
              emoji: _emoji,
              age: _age,
              streak: widget.streak,
              onEdit: _showEditProfile,
            ),

            const SizedBox(height: 20),

            // ── Stats row ─────────────────────────────────────────────────
            _StatsRow(streak: widget.streak, age: _age),

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
                onPressed: _logout,
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
  final VoidCallback onEdit;
  const _ProfileHeader({
    required this.name,
    required this.emoji,
    required this.age,
    required this.streak,
    required this.onEdit,
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
            onPressed: onEdit,
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