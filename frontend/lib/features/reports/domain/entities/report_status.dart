// Report Status Enum
enum ReportStatus { pending, inProgress, fixed }

extension StatusExtension on ReportStatus {
  String get name {
    switch (this) {
      case ReportStatus.pending: return 'Pending';
      case ReportStatus.inProgress: return 'In Progress';
      case ReportStatus.fixed: return 'Fixed';
    }
  }

  static ReportStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'pending': return ReportStatus.pending;
      case 'in progress': return ReportStatus.inProgress;
      case 'fixed': return ReportStatus.fixed;
      default: return ReportStatus.pending;
    }
  }
}