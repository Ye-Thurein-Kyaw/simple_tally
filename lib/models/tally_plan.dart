import 'day_task.dart';

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
