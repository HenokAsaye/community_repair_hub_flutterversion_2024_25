// Reports Repository Interface
import '../domain/entities/report.dart';
import '../domain/entities/assigned_report.dart';

abstract class ReportsRepository {
  Future<List<Report>> getReports();
  Future<List<AssignedReport>> getAssignedReports();
  Future<void> submitReport(Report report);
  Future<void> updateReportStatus(String reportId, String status);
}