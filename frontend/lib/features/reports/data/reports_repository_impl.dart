// Reports Repository Implementation
import '../data/reports_api_service.dart';
import '../domain/reports_repository.dart';
import '../domain/entities/report.dart';
import '../domain/entities/assigned_report.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsApiService api;

  ReportsRepositoryImpl(this.api);

  @override
  Future<List<Report>> getReports() => api.fetchReports();

  @override
  Future<List<AssignedReport>> getAssignedReports() => api.fetchAssignedReports();

  @override
  Future<void> submitReport(Report report) => api.submitReport(report);

  @override
  Future<void> updateReportStatus(String reportId, String status) => api.updateStatus(reportId, status);
}