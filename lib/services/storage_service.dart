import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tally_plan.dart';
import '../models/progress.dart';

class StorageService {
  static const String _plansKey = 'plans_v2';
  static const String _progressKey = 'progress_v2';
  static const String _currentPlanKey = 'current_plan_v2';

  Future<List<TallyPlan>> loadPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_plansKey);
    if (jsonString == null) return [];
    try {
      final list = jsonDecode(jsonString) as List;
      return list.map((e) => TallyPlan.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlans(List<TallyPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_plansKey, jsonEncode(plans.map((p) => p.toJson()).toList()));
  }

  Future<Map<String, Progress>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_progressKey);
    if (jsonString == null) return {};
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, Progress.fromJson(v)));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveProgress(Map<String, Progress> progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.map((k, v) => MapEntry(k, v.toJson()))));
  }

  Future<String?> loadCurrentPlanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentPlanKey);
  }

  Future<void> saveCurrentPlanId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentPlanKey, id);
  }
}
