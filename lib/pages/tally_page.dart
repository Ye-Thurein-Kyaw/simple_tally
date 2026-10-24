import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';

import '../models/tally_plan.dart';
import '../models/progress.dart';
import '../data/default_plans.dart';
import '../services/storage_service.dart';
import 'plan_editor_page.dart';

class TallyPage extends StatefulWidget {
  const TallyPage({super.key});

  @override
  State<TallyPage> createState() => _TallyPageState();
}

class _TallyPageState extends State<TallyPage> {
  final StorageService _storage = StorageService();
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
    try {
      _plans = await _storage.loadPlans();
      _progress = await _storage.loadProgress();
      _currentId = await _storage.loadCurrentPlanId();
    } catch (_) {
      _plans = [];
      _progress = {};
    }
    if (_plans.isEmpty) {
      _plans = getDefaultPlans();
      await _storage.savePlans(_plans);
    }
    if (_plan == null) _currentId = _plans.first.id;
    setState(() => _loaded = true);
    _save();
  }

  Future<void> _save() async {
    await _storage.savePlans(_plans);
    await _storage.saveProgress(_progress);
    if (_currentId != null) await _storage.saveCurrentPlanId(_currentId!);
  }

  Future<void> _vibrate(int ms) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: ms);
    }
  }

  Future<void> _handleTap() async {
    final plan = _plan;
    if (plan == null) return;
    final p = _p;
    if (p.day >= plan.days.length) return;
    final task = plan.days[p.day];

    _vibrate(40);
    setState(() {
      p.bead++;
      if (p.bead >= task.beadsPerRound) {
        p.bead = 0;
        p.round++;
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
        _progress[result.id] = Progress();
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

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Scaffold(
      appBar: AppBar(
        title: const Text('အဓိဋ္ဌာန်ပုတီး'),
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
