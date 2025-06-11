// Reports API Service
import 'package:dio/dio.dart';
import 'dart:io';
import '../domain/entities/report.dart';
import '../domain/entities/assigned_report.dart';
import 'package:community_repair_hub/core/network/api_service.dart';

class ReportsApiService {
  final ApiService api;

  ReportsApiService({required this.api});

  Future<List<Report>> fetchReports() async {
    final response = await api.get('/citizens/reports');
    final List data = response.data;
    return data.map((e) => Report.fromJson(e)).toList();
  }

  Future<List<AssignedReport>> fetchAssignedReports() async {
    final response = await api.get('/citizens/assigned-reports');
    final List data = response.data;
    return data.map((e) => AssignedReport.fromJson(e)).toList();
  }

  Future<String> uploadImage(File image) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path),
    });

    final response = await api.postFormData(
      '/citizens/upload',
      formData: formData,
    );

    return response.data['url'];
  }

  Future<void> submitReport(Report report) async {
    await api.post(
      '/citizens/reports',
      data: report.toJson(),
    );
  }

  Future<void> updateStatus(String reportId, String status) async {
    await api.post(
      '/citizens/reports/$reportId',
      data: {'status': status},
      options: Options(method: 'PATCH'),
    );
  }
}