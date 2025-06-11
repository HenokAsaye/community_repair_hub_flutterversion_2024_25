import 'package:flutter/material.dart';
import '../../domain/reports_repository.dart';
import '../../domain/entities/assigned_report.dart';

class AssignedReportProvider with ChangeNotifier {
  final ReportsRepository repository;
  List<AssignedReport> _items = [];
  bool _loading = false;
  String? _error;

  AssignedReportProvider(this.repository);

  List<AssignedReport> get items => _items;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchAssignedReports() async {
    _loading = true; notifyListeners();
    try {
      _items = await repository.getAssignedReports();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }

  Future<void> updateStatus(String reportId, String status) async {
    _loading = true; notifyListeners();
    try {
      await repository.updateReportStatus(reportId, status);
      final idx = _items.indexWhere((r) => r.id == reportId);
      if (idx >= 0) _items[idx] = _items[idx].copyWith(status: status);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }
}