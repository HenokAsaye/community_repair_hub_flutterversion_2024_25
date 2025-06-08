// Reports Provider
import 'package:flutter/material.dart';
import '../../domain/reports_repository.dart';
import '../../domain/entities/report.dart';

class ReportsProvider with ChangeNotifier {
  final ReportsRepository repository;
  List<Report> _reports = [];
  bool _loading = false;
  String? _error;

  ReportsProvider(this.repository);

  List<Report> get reports => _reports;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchReports() async {
    _loading = true; notifyListeners();
    try {
      _reports = await repository.getReports();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }

  Future<void> submitReport(Report report) async {
    _loading = true; notifyListeners();
    try {
      await repository.submitReport(report);
      _error = null;
      await fetchReports();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false; notifyListeners();
  }
}