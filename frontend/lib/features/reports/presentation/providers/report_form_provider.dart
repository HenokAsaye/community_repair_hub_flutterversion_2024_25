import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_service_provider.dart';

import '../../../../shared/models/report.dart';

// Report Form State
enum ReportFormStatus { initial, loading, success, error }

class ReportFormState {
  final ReportFormStatus status;
  final String? errorMessage;
  final Issue? createdIssue;

  ReportFormState({
    this.status = ReportFormStatus.initial,
    this.errorMessage,
    this.createdIssue,
  });

  ReportFormState copyWith({
    ReportFormStatus? status,
    String? errorMessage,
    Issue? createdIssue,
  }) {
    return ReportFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdIssue: createdIssue ?? this.createdIssue,
    );
  }
}

// Report Form Notifier
class ReportFormNotifier extends StateNotifier<ReportFormState> {
  final ApiService _apiService;

  ReportFormNotifier(this._apiService) : super(ReportFormState());

  Future<bool> submitReport({
    required String category,
    required String city,
    required String specificAddress,
    required String description,
    required DateTime issueDate,
    required File imageFile,
  }) async {
    state = state.copyWith(status: ReportFormStatus.loading);

    try {
      print('Preparing to submit report with image: ${imageFile.path}');

      final fileName = imageFile.path.split('/').last;
      
      final fileExtension = fileName.split('.').last.toLowerCase();

      String mimeSubtype = 'jpeg'; // Default to jpeg
      if (fileExtension == 'png') {
        mimeSubtype = 'png';
      } else if (fileExtension == 'gif') {
        mimeSubtype = 'gif';
      }

      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', mimeSubtype),
      );

      final formData = FormData.fromMap({
        'category': category,
        'description': description,
        'city': city,
        'specificAddress': specificAddress,
        'issueDate': issueDate.toIso8601String(),
        'image': multipartFile,
      });

      // Submit the report
      final response = await _apiService.postFormData(
        '/citizens/report',
        formData: formData,
      );

      // Assuming the created issue is nested under a 'data' key
      final issue = Issue.fromJson(response.data['data']);

      // Update state with success
      state = state.copyWith(
        status: ReportFormStatus.success,
        createdIssue: issue,
        errorMessage: null,
      );
      
      return true;
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        status: ReportFormStatus.error,
        errorMessage: e.toString(),
      );
      
      return false;
    }
  }

  void resetState() {
    state = ReportFormState();
  }
}

// Provider
final reportFormProvider = StateNotifierProvider<ReportFormNotifier, ReportFormState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ReportFormNotifier(apiService);
});
