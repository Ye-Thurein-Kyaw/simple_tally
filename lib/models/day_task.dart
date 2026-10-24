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
