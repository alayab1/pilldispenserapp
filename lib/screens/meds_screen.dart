import 'package:flutter/material.dart';
import 'home_screen.dart' show Medication, sampleMeds;
import 'bluetooth_screen.dart';
import '../services/bluetooth_service.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const _bgDark    = Color(0xFF2B2B2B);
const _bgCard    = Color(0xFF383838);
const _accent    = Color(0xFFE8A838);
const _accentDim = Color(0xFF7A561A);
const _textPrim  = Color(0xFFF5EDD6);
const _textSec   = Color(0xFF9A9A9A);
const _danger    = Color(0xFFE05C3A);
const _success   = Color(0xFF6DBF6A);

// ── Medication info data ──────────────────────────────────────────────────────
// Common medication information — extend as needed
const Map<String, Map<String, String>> _medInfo = {
  'metformin': {
    'class': 'Biguanide',
    'purpose': 'Controls blood sugar in type 2 diabetes',
    'sideEffects': 'Nausea, diarrhea, stomach upset (usually temporary)',
    'avoid': 'Excessive alcohol. Take with food.',
    'overdose': '⚠️ Overdose can cause lactic acidosis — seek emergency care.',
  },
  'lisinopril': {
    'class': 'ACE Inhibitor',
    'purpose': 'Lowers blood pressure, protects kidneys',
    'sideEffects': 'Dry cough, dizziness, high potassium',
    'avoid': 'NSAIDs (ibuprofen), potassium supplements, salt substitutes.',
    'overdose': '⚠️ Overdose causes severe low blood pressure — call 911.',
  },
  'vitamin d': {
    'class': 'Vitamin / Supplement',
    'purpose': 'Bone health, immune support, mood regulation',
    'sideEffects': 'Rare at normal doses. High doses may cause nausea.',
    'avoid': 'Very high doses long-term can cause toxicity.',
    'overdose': '⚠️ Vitamin D toxicity from very large doses — seek care.',
  },
};

Map<String, String>? _getInfo(String name) {
  return _medInfo[name.toLowerCase().trim()];
}

// ── Meds screen ───────────────────────────────────────────────────────────────

class MedsScreen extends StatefulWidget {
  final BluetoothService btService;

  const MedsScreen({super.key, required this.btService});

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  // Local copy so we can add/remove without touching sampleMeds directly
  late List<_EditableMed> _meds;

  @override
  void initState() {
    super.initState();
    _meds = sampleMeds.map((m) => _EditableMed.fromMedication(m)).toList();
  }

  void _showAddMedSheet({_EditableMed? existing, int? editIndex}) {
    final nameCtrl    = TextEditingController(text: existing?.name ?? '');
    final dosageCtrl  = TextEditingController(text: existing?.dosage ?? '');
    final purposeCtrl = TextEditingController(text: existing?.purpose ?? '');
    final pillsCtrl   = TextEditingController(
        text: existing?.pillsRemaining.toString() ?? '30');
    Color pickedColor = existing?.color ?? const Color(0xFFE8A838);
    final days = List<bool>.from(
        existing?.scheduledDays != null
            ? List.generate(7, (i) => existing!.scheduledDays.contains(i))
            : List.filled(7, true));
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final colors = [
      const Color(0xFFE8A838),
      const Color(0xFF5B9BD5),
      const Color(0xFF7EC86A),
      const Color(0xFFE07090),
      const Color(0xFFB07EE8),
      const Color(0xFFE8703A),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
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
                Text(existing == null ? 'Add medication' : 'Edit medication',
                    style: const TextStyle(
                        color: _textPrim,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 20),

                // Name
                _FieldLabel('Medication name'),
                const SizedBox(height: 8),
                _Field(controller: nameCtrl, hint: 'e.g. Metformin',
                    icon: Icons.medication_rounded),

                const SizedBox(height: 14),

                // Dosage
                _FieldLabel('Dosage'),
                const SizedBox(height: 8),
                _Field(controller: dosageCtrl, hint: 'e.g. 500 mg',
                    icon: Icons.scale_rounded),

                const SizedBox(height: 14),

                // Purpose
                _FieldLabel('Purpose (optional)'),
                const SizedBox(height: 8),
                _Field(controller: purposeCtrl,
                    hint: 'e.g. Blood pressure control',
                    icon: Icons.info_outline_rounded),

                const SizedBox(height: 14),

                // Pills remaining
                _FieldLabel('Pills remaining'),
                const SizedBox(height: 8),
                _Field(controller: pillsCtrl, hint: '30',
                    icon: Icons.inventory_2_outlined,
                    keyboard: TextInputType.number),

                const SizedBox(height: 14),

                // Color picker
                _FieldLabel('Color'),
                const SizedBox(height: 10),
                Row(
                  children: colors.map((c) {
                    final selected = pickedColor == c;
                    return GestureDetector(
                      onTap: () => setLocal(() => pickedColor = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 10),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: selected
                              ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 8)]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Days
                _FieldLabel('Schedule days'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    return GestureDetector(
                      onTap: () => setLocal(() => days[i] = !days[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: days[i]
                              ? pickedColor.withValues(alpha: 0.2)
                              : _bgDark,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: days[i]
                                ? pickedColor
                                : _textSec.withValues(alpha: 0.3),
                            width: days[i] ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(dayLabels[i],
                              style: TextStyle(
                                  color: days[i] ? pickedColor : _textSec,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Save
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final dosage = dosageCtrl.text.trim();
                      if (name.isEmpty || dosage.isEmpty) return;
                      final newMed = _EditableMed(
                        name: name,
                        dosage: dosage,
                        purpose: purposeCtrl.text.trim(),
                        pillsRemaining:
                            int.tryParse(pillsCtrl.text.trim()) ?? 30,
                        color: pickedColor,
                        scheduledDays: List.generate(7, (i) => i)
                            .where((i) => days[i])
                            .toList(),
                      );
                      setState(() {
                        if (editIndex != null) {
                          _meds[editIndex] = newMed;
                        } else {
                          _meds.add(newMed);
                        }
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(editIndex != null
                            ? '$name updated!'
                            : '$name added!'),
                        backgroundColor: _success,
                        duration: const Duration(seconds: 2),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _bgDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      existing == null ? 'Add medication' : 'Save changes',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMedInfo(_EditableMed med) {
    final info = _getInfo(med.name);
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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

              // Header
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: med.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.medication_rounded,
                        color: med.color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med.name,
                            style: TextStyle(
                                color: _textPrim,
                                fontWeight: FontWeight.w800,
                                fontSize: 20)),
                        Text(med.dosage,
                            style:
                                TextStyle(color: med.color, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Pills remaining
              _InfoRow(
                icon: Icons.inventory_2_outlined,
                color: _accent,
                label: 'Pills remaining',
                value: '${med.pillsRemaining}',
              ),

              if (med.purpose.isNotEmpty) ...[
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  color: const Color(0xFF5B9BD5),
                  label: 'Purpose',
                  value: med.purpose,
                ),
              ],

              // Schedule
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                color: _success,
                label: 'Schedule',
                value: _daysLabel(med.scheduledDays),
              ),

              // Database info if available
              if (info != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _bgDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: med.color.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Drug info',
                          style: TextStyle(
                              color: med.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 12),
                      _InfoSection('Drug class', info['class']!),
                      _InfoSection('How it works', info['purpose']!),
                      _InfoSection('Common side effects',
                          info['sideEffects']!),
                      _InfoSection('Things to avoid', info['avoid']!),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _danger.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          info['overdose']!,
                          style: TextStyle(
                              color: _danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bgDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          color: _textSec, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ask EVE in the Chat tab for detailed info about ${med.name}.',
                          style:
                              TextStyle(color: _textSec, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),
              Text(
                'This is general information only. Always follow your doctor\'s instructions.',
                style: TextStyle(
                    color: _textSec.withValues(alpha: 0.6), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _daysLabel(List<int> days) {
    if (days.length == 7) return 'Every day';
    if (days.isEmpty) return 'No days set';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (days.toSet().containsAll({0, 1, 2, 3, 4}) && days.length == 5) {
      return 'Weekdays';
    }
    return days.map((d) => names[d]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _accent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Medications',
          style: TextStyle(
            color: _accent,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          // Dispenser shortcut
          ListenableBuilder(
            listenable: widget.btService,
            builder: (_, __) => IconButton(
              icon: Icon(
                widget.btService.isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_outlined,
                color: widget.btService.isConnected ? _success : _textSec,
                size: 22,
              ),
              tooltip: 'Dispenser',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BluetoothScreen(btService: widget.btService),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedSheet(),
        backgroundColor: _accent,
        foregroundColor: _bgDark,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add med',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _meds.isEmpty
          ? _EmptyState(onAdd: () => _showAddMedSheet())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: _meds.length,
              itemBuilder: (_, i) => _MedCard(
                med: _meds[i],
                onTap: () => _showMedInfo(_meds[i]),
                onEdit: () =>
                    _showAddMedSheet(existing: _meds[i], editIndex: i),
                onDelete: () => setState(() => _meds.removeAt(i)),
              ),
            ),
    );
  }
}

// ── Editable med model ────────────────────────────────────────────────────────

class _EditableMed {
  String name;
  String dosage;
  String purpose;
  int pillsRemaining;
  Color color;
  List<int> scheduledDays;

  _EditableMed({
    required this.name,
    required this.dosage,
    required this.purpose,
    required this.pillsRemaining,
    required this.color,
    required this.scheduledDays,
  });

  factory _EditableMed.fromMedication(Medication m) => _EditableMed(
        name: m.name,
        dosage: m.dosage,
        purpose: m.purpose,
        pillsRemaining: m.pillsRemaining,
        color: m.color,
        scheduledDays: List.from(m.scheduledDays),
      );
}

// ── Med card ──────────────────────────────────────────────────────────────────

class _MedCard extends StatelessWidget {
  final _EditableMed med;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedCard({
    required this.med,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final needsRefill = med.pillsRemaining <= 7;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: needsRefill
                ? _danger.withValues(alpha: 0.4)
                : med.color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: med.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.medication_rounded,
                      color: med.color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name,
                          style: const TextStyle(
                              color: _textPrim,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      Text(med.dosage,
                          style:
                              TextStyle(color: med.color, fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: _bgCard,
                  icon: Icon(Icons.more_vert_rounded,
                      color: _textSec, size: 20),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            color: _accent, size: 18),
                        const SizedBox(width: 10),
                        const Text('Edit',
                            style: TextStyle(color: _textPrim)),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            color: _danger, size: 18),
                        const SizedBox(width: 10),
                        Text('Delete',
                            style: TextStyle(color: _danger)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Pills + schedule row
            Row(
              children: [
                _PillBadge(
                  icon: Icons.inventory_2_outlined,
                  label: '${med.pillsRemaining} pills',
                  color: needsRefill ? _danger : _textSec,
                ),
                const SizedBox(width: 10),
                _PillBadge(
                  icon: Icons.calendar_today_outlined,
                  label: _daysShort(med.scheduledDays),
                  color: _textSec,
                ),
                if (med.purpose.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      med.purpose,
                      style: TextStyle(
                          color: _textSec.withValues(alpha: 0.7),
                          fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            if (needsRefill) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: _danger, size: 14),
                    const SizedBox(width: 6),
                    Text('Refill soon',
                        style: TextStyle(
                            color: _danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],

            // Tap hint
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                Text('Tap for info',
                    style: TextStyle(
                        color: _textSec.withValues(alpha: 0.5),
                        fontSize: 11)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: _textSec.withValues(alpha: 0.4), size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _daysShort(List<int> days) {
    if (days.length == 7) return 'Daily';
    if (days.isEmpty) return 'No days';
    if (days.toSet().containsAll({0, 1, 2, 3, 4}) && days.length == 5) {
      return 'Weekdays';
    }
    const n = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days.map((d) => n[d]).join('·');
  }
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PillBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined,
              color: _textSec.withValues(alpha: 0.4), size: 64),
          const SizedBox(height: 16),
          Text('No medications yet',
              style: TextStyle(
                  color: _textPrim,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          const SizedBox(height: 8),
          Text('Tap + Add med to get started',
              style: TextStyle(color: _textSec, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Info sheet helpers ────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon,
      required this.color,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: _textSec, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: _textPrim,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String body;
  const _InfoSection(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: _textSec,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4)),
          const SizedBox(height: 3),
          Text(body,
              style: const TextStyle(color: _textPrim, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Field helpers ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: _accent,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: _textPrim),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textSec),
        filled: true,
        fillColor: _bgDark,
        prefixIcon: Icon(icon, color: _accent, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentDim)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentDim)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.5)),
      ),
    );
  }
}