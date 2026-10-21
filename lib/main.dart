import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

void main() => runApp(const TallyApp());

class TallyApp extends StatelessWidget {
  const TallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tally App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const TallyPage(),
    );
  }
}

// ───────────────────────── Models ─────────────────────────

/// Plan ထဲက ရက်တစ်ရက် (ဂါထာ + ပုတီးလုံး + ပတ်အရေအတွက်)
class DayTask {
  final List<String> phrases; // တစ်ခါနှိပ်တိုင်း နောက်တစ်ကြောင်းပြောင်း
  final int beadsPerRound; // ၁ ပတ်မှာ နှိပ်ရမယ့်အကြိမ် (ဥပမာ ၁၀၈ / ၂၄)
  final int rounds; // ပတ်အရေအတွက် (ဥပမာ ၇)

  DayTask({
    required this.phrases,
    required this.beadsPerRound,
    required this.rounds,
  });

  int get totalTaps => beadsPerRound * rounds;

  Map<String, dynamic> toJson() => {
        'phrases': phrases,
        'beadsPerRound': beadsPerRound,
        'rounds': rounds,
      };

  factory DayTask.fromJson(Map<String, dynamic> j) => DayTask(
        phrases: List<String>.from(j['phrases'] ?? ['-']),
        beadsPerRound: j['beadsPerRound'] ?? 108,
        rounds: j['rounds'] ?? 1,
      );
}

class TallyPlan {
  final String id;
  final String name;
  final List<DayTask> days;

  TallyPlan({required this.id, required this.name, required this.days});

  int get totalTaps => days.fold(0, (s, d) => s + d.totalTaps);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'days': days.map((d) => d.toJson()).toList()};

  factory TallyPlan.fromJson(Map<String, dynamic> j) => TallyPlan(
        id: j['id'],
        name: j['name'],
        days: (j['days'] as List).map((d) => DayTask.fromJson(d)).toList(),
      );
}

class Progress {
  int day; // လက်ရှိရက် (0-based). days.length ဆိုရင် plan ပြီး
  int round; // ပြီးသွားတဲ့ ပတ်အရေအတွက်
  int bead; // လက်ရှိပတ်ထဲ နှိပ်ပြီးသွားတဲ့အကြိမ်

  Progress({this.day = 0, this.round = 0, this.bead = 0});

  Map<String, dynamic> toJson() => {'day': day, 'round': round, 'bead': bead};

  factory Progress.fromJson(Map<String, dynamic> j) =>
      Progress(day: j['day'] ?? 0, round: j['round'] ?? 0, bead: j['bead'] ?? 0);
}

// ───────────────────────── Default plans ─────────────────────────

const List<String> _gatha24 = [
  "အရဟံဝတ လာဘံ ဟေတုပစ္စယော",
  "အရဟံဝတ လာဘံ အရမ္မဏပစ္စယော",
  "အရဟံဝတ လာဘံ အဓိပတိပစ္စယော",
  "အရဟံဝတ လာဘံ အနန္တရပစ္စယော",
  "အရဟံဝတ လာဘံ သမနန္တရပစ္စယော",
  "အရဟံဝတ လာဘံ သဟဇာတပစ္စယော",
  "အရဟံဝတ လာဘံ အညမညပစ္စယော",
  "အရဟံဝတ လာဘံ နိဿယပစ္စယော",
  "အရဟံဝတ လာဘံ ဥပနိဿယပစ္စယော",
  "အရဟံဝတ လာဘံ ပုရေဇာတပစ္စယော",
  "အရဟံဝတ လာဘံ ပစ္ဆာဇာတပစ္စယော",
  "အရဟံဝတ လာဘံ အာသေဝနပစ္စယော",
  "အရဟံဝတ လာဘံ ကမ္မပစ္စယော",
  "အရဟံဝတ လာဘံ ဝိပါကပစ္စယော",
  "အရဟံဝတ လာဘံ အဟာရပစ္စယော",
  "အရဟံဝတ လာဘံ ဣန္ဒြိယပစ္စယော",
  "အရဟံဝတ လာဘံ ဈာနပစ္စယော",
  "အရဟံဝတ လာဘံ မဂ္ဂပစ္စယော",
  "အရဟံဝတ လာဘံ သမ္ပယုတ္တပစ္စယော",
  "အရဟံဝတ လာဘံ ဝိပ္ပယုတ္တပစ္စယော",
  "အရဟံဝတ လာဘံ အတ္ထိပစ္စယော",
  "အရဟံဝတ လာဘံ နတ္ထိပစ္စယော",
  "အရဟံဝတ လာဘံ ဝိဂတပစ္စယော",
  "အရဟံဝတ လာဘံ အဝိဂတပစ္စယောတိ။",
];

DayTask _one(String phrase, int rounds, [int beads = 108]) =>
    DayTask(phrases: [phrase], beadsPerRound: beads, rounds: rounds);

List<TallyPlan> _defaultPlans() {
  final t = DateTime.now().millisecondsSinceEpoch;
  return [
    // ပုံ ၁ : ဂါထာ ၂၄ ကြောင်း × ၇ ပတ်
    TallyPlan(id: '$t-1', name: 'ပစ္စယော ၂၄ ကြောင်း (၇ ပတ်)', days: [
      DayTask(phrases: _gatha24, beadsPerRound: 24, rounds: 7),
    ]),
    // ပုံ ၂ : ၇ ရက် plan
    TallyPlan(id: '$t-2', name: '၇ ရက် အဓိဋ္ဌာန်', days: [
      _one('အရဟံ', 7),
      _one('အရဟံ ဗုဒ္ဓေါ', 9),
      _one('အရဟံ လောကဝိဒူ', 8),
      _one('အရဟံ သုဂတော', 5),
      _one('အရဟံ ဘဂဝါ', 9),
      _one('အရဟံ သိဒ္ဓိ', 9),
      _one('အရဟံ သိဒ္ဓိဘဝါအောင်', 11),
    ]),
    // ပုံ ၃ : ၁၁ ရက် plan (ပုံထဲက စာတွေကို ကိုယ်တိုင်ပြန်စစ်ပြီး edit လုပ်ပါ)
    TallyPlan(id: '$t-3', name: '၁၁ ရက် အဓိဋ္ဌာန်', days: [
      _one('အရဟံ နမောဘဿ', 5),
      _one('အရဟံ ဘဂဝေါ', 2),
      _one('အရဟံ အရဟတော', 2),
      _one('အရဟံ သမ္မာသမ္ဗုဒ္ဓေါ', 3),
      _one('အရဟံ ဗုဒ္ဓေါ', 5),
      _one('အရဟံ သိဒ္ဓိ', 7),
      _one('အရဟံ သိဒ္ဓိဘဝါအောင်', 9),
      _one('သောဘဂဝါ အရဟံ', 6),
      _one('သုဂတော သိဒ္ဓိ', 6),
      _one('ဗုဒ္ဓေါ သိဒ္ဓိ', 9),
      _one('လောကဝိဒူ သိဒ္ဓိ', 8),
    ]),
  ];
}

// ───────────────────────── Main page ─────────────────────────

class TallyPage extends StatefulWidget {
  const TallyPage({super.key});

  @override
  State<TallyPage> createState() => _TallyPageState();
}

class _TallyPageState extends State<TallyPage> {
  List<TallyPlan> _plans = [];
  Map<String, Progress> _progress = {};
  String? _currentId;
  bool _loaded = false;

  final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 3));

  TallyPlan? get _plan {
    for (final p in _plans) {
      if (p.id == _currentId) return p;
    }
    return null;
  }

  Progress get _p => _progress.putIfAbsent(_currentId!, () => Progress());

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final plansJson = prefs.getString('plans_v2');
      if (plansJson != null) {
        _plans = (jsonDecode(plansJson) as List)
            .map((e) => TallyPlan.fromJson(e))
            .toList();
      }
      final progJson = prefs.getString('progress_v2');
      if (progJson != null) {
        final m = jsonDecode(progJson) as Map<String, dynamic>;
        _progress = m.map((k, v) => MapEntry(k, Progress.fromJson(v)));
      }
      _currentId = prefs.getString('current_plan_v2');
    } catch (_) {
      _plans = [];
      _progress = {};
    }
    if (_plans.isEmpty) _plans = _defaultPlans();
    if (_plan == null) _currentId = _plans.first.id;
    setState(() => _loaded = true);
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'plans_v2', jsonEncode(_plans.map((p) => p.toJson()).toList()));
    await prefs.setString('progress_v2',
        jsonEncode(_progress.map((k, v) => MapEntry(k, v.toJson()))));
    if (_currentId != null) await prefs.setString('current_plan_v2', _currentId!);
  }

  Future<void> _vibrate(int ms) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: ms);
    }
  }

  // ───── Tap logic ─────

  Future<void> _handleTap() async {
    final plan = _plan;
    if (plan == null) return;
    final p = _p;
    if (p.day >= plan.days.length) return; // plan ပြီးပြီ
    final task = plan.days[p.day];

    _vibrate(40);
    setState(() {
      p.bead++;
      if (p.bead >= task.beadsPerRound) {
        p.bead = 0;
        p.round++; // ပတ်တစ်ပတ် ပြည့်ပြီ
      }
    });

    if (p.round >= task.rounds) {
      await _onDayComplete(plan, p);
    }
    _save();
  }

  Future<void> _onDayComplete(TallyPlan plan, Progress p) async {
    final finishedDay = p.day;
    final planDone = finishedDay + 1 >= plan.days.length;
    _confetti.play();
    _vibrate(300);

    setState(() {
      p.day++;
      p.round = 0;
      p.bead = 0;
    });
    _save();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(planDone ? '🎉 Plan အောင်မြင်ပါပြီ' : '🎉 ရက် ${finishedDay + 1} အောင်မြင်ပါပြီ'),
        content: Text(planDone
            ? '${plan.name} ကို အပြည့်အစုံ ပြီးမြောက်ပါပြီ။ သာဓု!'
            : 'နောက်ရက် (ရက် ${finishedDay + 2}) ကို ဆက်လက်စိပ်ပါ။'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('ကောင်းပါပြီ')),
        ],
      ),
    );
  }

  void _undo() {
    final plan = _plan;
    if (plan == null) return;
    final p = _p;
    if (p.day >= plan.days.length) return;
    final task = plan.days[p.day];
    setState(() {
      if (p.bead > 0) {
        p.bead--;
      } else if (p.round > 0) {
        p.round--;
        p.bead = task.beadsPerRound - 1;
      }
    });
    _save();
  }

  void _resetPlan() {
    if (_plan == null) return;
    setState(() => _progress[_currentId!] = Progress());
    _save();
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('အစကပြန်စမလား?'),
        content: const Text('ဒီ plan ရဲ့ progress အားလုံး ပျက်သွားပါမယ်။'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('မလုပ်တော့ဘူး')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ပြန်စမယ်')),
        ],
      ),
    );
    if (ok == true) _resetPlan();
  }

  // ───── Plan management ─────

  Future<void> _openEditor([TallyPlan? existing]) async {
    final result = await Navigator.push<TallyPlan>(
      context,
      MaterialPageRoute(builder: (_) => PlanEditorPage(plan: existing)),
    );
    if (result == null) return;
    setState(() {
      final i = _plans.indexWhere((p) => p.id == result.id);
      if (i >= 0) {
        _plans[i] = result;
        _progress[result.id] = Progress(); // plan ပြင်ရင် progress ပြန်စ
      } else {
        _plans.add(result);
      }
      _currentId = result.id;
    });
    _save();
  }

  void _showPlanList() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Plans များ စာရင်း'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _plans.length,
              itemBuilder: (_, i) {
                final p = _plans[i];
                final sel = p.id == _currentId;
                return ListTile(
                  leading: Icon(sel ? Icons.check_circle : Icons.circle_outlined,
                      color: sel ? Colors.amber[800] : null),
                  title: Text(p.name),
                  subtitle: Text('${p.days.length} ရက် | စုစုပေါင်း ${p.totalTaps} ကြိမ်'),
                  onTap: () {
                    setState(() => _currentId = p.id);
                    _save();
                    Navigator.pop(ctx);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openEditor(p);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _plans.length <= 1
                            ? null
                            : () {
                                setState(() {
                                  _plans.removeAt(i);
                                  _progress.remove(p.id);
                                  if (_currentId == p.id) _currentId = _plans.first.id;
                                });
                                _save();
                                setD(() {});
                              },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ပိတ်မည်')),
          ],
        ),
      ),
    );
  }

  // ───── UI ─────

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tally'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(onPressed: _undo, icon: const Icon(Icons.undo), tooltip: 'နောက်ပြန်'),
          IconButton(onPressed: _confirmReset, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _showPlanList, icon: const Icon(Icons.list)),
          IconButton(onPressed: () => _openEditor(), icon: const Icon(Icons.add)),
        ],
      ),
      body: !_loaded || plan == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _handleTap,
                  child: SizedBox.expand(child: _buildContent(plan)),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    numberOfParticles: 30,
                    gravity: 0.2,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      );

  Widget _buildContent(TallyPlan plan) {
    final p = _p;

    if (p.day >= plan.days.length) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text('${plan.name}\nပြီးမြောက်ပါပြီ',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _resetPlan, child: const Text('အစကပြန်စမည်')),
        ],
      );
    }

    final task = plan.days[p.day];
    final phrase = task.phrases[p.bead % task.phrases.length];
    final doneBefore = plan.days.take(p.day).fold<int>(0, (s, d) => s + d.totalTaps);
    final doneNow = doneBefore + p.round * task.beadsPerRound + p.bead;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(plan.name,
            style: const TextStyle(fontSize: 16, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text('ရက်: ${p.day + 1} / ${plan.days.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip('ပတ်: ${p.round} / ${task.rounds}'),
            const SizedBox(width: 12),
            _chip('လုံး: ${p.bead} / ${task.beadsPerRound}'),
          ],
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            phrase,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.6),
          ),
        ),
        const SizedBox(height: 36),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: LinearProgressIndicator(
            value: (p.round * task.beadsPerRound + p.bead) / task.totalTaps,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ယနေ့ ${p.round * task.beadsPerRound + p.bead} / ${task.totalTaps} ကြိမ်'
          '   |   စုစုပေါင်း $doneNow / ${plan.totalTaps}',
          style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
        ),
        const SizedBox(height: 30),
        const Text('(မျက်နှာပြင်ကို နှိပ်၍ ပုတီးစိပ်ပါ)',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}

// ───────────────────────── Plan editor ─────────────────────────

class _DayDraft {
  final TextEditingController phrases;
  final TextEditingController beads;
  final TextEditingController rounds;

  _DayDraft({String phrases = '', int beads = 108, int rounds = 7})
      : phrases = TextEditingController(text: phrases),
        beads = TextEditingController(text: '$beads'),
        rounds = TextEditingController(text: '$rounds');

  void dispose() {
    phrases.dispose();
    beads.dispose();
    rounds.dispose();
  }
}

class PlanEditorPage extends StatefulWidget {
  final TallyPlan? plan;
  const PlanEditorPage({super.key, this.plan});

  @override
  State<PlanEditorPage> createState() => _PlanEditorPageState();
}

class _PlanEditorPageState extends State<PlanEditorPage> {
  late final TextEditingController _name;
  final List<_DayDraft> _days = [];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.plan?.name ?? '');
    if (widget.plan != null) {
      for (final d in widget.plan!.days) {
        _days.add(_DayDraft(
          phrases: d.phrases.join('\n'),
          beads: d.beadsPerRound,
          rounds: d.rounds,
        ));
      }
    } else {
      _days.add(_DayDraft());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final d in _days) {
      d.dispose();
    }
    super.dispose();
  }

  void _save() {
    final days = <DayTask>[];
    for (final d in _days) {
      final phrases = d.phrases.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (phrases.isEmpty) continue;
      days.add(DayTask(
        phrases: phrases,
        beadsPerRound: (int.tryParse(d.beads.text) ?? 108).clamp(1, 100000),
        rounds: (int.tryParse(d.rounds.text) ?? 1).clamp(1, 100000),
      ));
    }
    if (days.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ရက်တစ်ရက်တော့ ထည့်ပေးပါ')));
      return;
    }
    Navigator.pop(
      context,
      TallyPlan(
        id: widget.plan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name.text.trim().isEmpty ? 'New Plan' : _name.text.trim(),
        days: days,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan == null ? 'Plan အသစ်ဆောက်မည်' : 'Plan ပြင်မည်'),
        actions: [
          TextButton(onPressed: _save, child: const Text('သိမ်းဆည်းမည်')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _days.add(_DayDraft())),
        icon: const Icon(Icons.add),
        label: const Text('ရက်ထပ်ထည့်'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Plan အမည်', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _days.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('ရက် ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        if (_days.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => setState(() {
                              _days.removeAt(i).dispose();
                            }),
                          ),
                      ],
                    ),
                    TextField(
                      controller: _days[i].phrases,
                      minLines: 1,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'ဂါထာ (တစ်ကြောင်းချင်း ခွဲရေးပါ)',
                        helperText: 'တစ်ကြောင်းထက်များရင် တစ်ခါနှိပ်တိုင်း နောက်တစ်ကြောင်းပြောင်းမယ်',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _days[i].beads,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '၁ ပတ် ပုတီးလုံး',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _days[i].rounds,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'ပတ်အရေအတွက်',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}