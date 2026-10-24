class Progress {
  int day; // လက်ရှိရက် (0-based). days.length ဆိုရင် plan ပြီး
  int round; // ပြီးသွားတဲ့ ပတ်အရေအတွက်
  int bead; // လက်ရှိပတ်ထဲ နှိပ်ပြီးသွားတဲ့အကြိမ်

  Progress({this.day = 0, this.round = 0, this.bead = 0});

  Map<String, dynamic> toJson() => {'day': day, 'round': round, 'bead': bead};

  factory Progress.fromJson(Map<String, dynamic> j) =>
      Progress(day: j['day'] ?? 0, round: j['round'] ?? 0, bead: j['bead'] ?? 0);
}
