
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
