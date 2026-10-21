import 'package:flutter/material.dart';
import '../models/tally_models.dart';

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
