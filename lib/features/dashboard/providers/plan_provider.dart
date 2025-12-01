import 'package:flutter/foundation.dart';
import '../models/plan_model.dart';
import '../services/plan_service.dart';

class PlanProvider with ChangeNotifier {
  final PlanService _planService = PlanService();

  List<PlanModel> _plans = [];
  PlanModel? _selectedPlan;
  bool _loading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<PlanModel> get plans => _plans;
  PlanModel? get selectedPlan => _selectedPlan;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadPlans({bool refresh = false}) async {
    if (_loading) return;

    if (refresh) {
      _plans.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final newPlans = await _planService.getPlans(page: _currentPage);

      if (refresh) {
        _plans = newPlans;
      } else {
        _plans.addAll(newPlans);
      }

      _hasMore = newPlans.length >= 15;
      if (_hasMore) _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> searchPlans(String query) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      _plans = await _planService.getPlans(search: query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadPlanById(int id) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      _selectedPlan = await _planService.getPlanById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectPlan(PlanModel plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  void clearSelectedPlan() {
    _selectedPlan = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
