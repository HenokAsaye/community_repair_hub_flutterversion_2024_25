import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import '../../../../features/dashboard/data/citizen_api_client.dart';
import '../../../../features/dashboard/presentation/providers/citizen_dashboard_provider.dart';
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
  final CitizenApiClient _apiClient;

  ReportFormNotifier(this._apiClient) : super(ReportFormState());

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
      
      // Get file extension to determine correct MIME type
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      // Map file extension to MIME type
      String mimeSubtype = 'jpeg';
      if (fileExtension == 'png') mimeSubtype = 'png';
      else if (fileExtension == 'gif') mimeSubtype = 'gif';
      
      print('File extension: $fileExtension, using MIME type: image/$mimeSubtype');
      
      // Convert File to MultipartFile with proper content type
      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType('image', mimeSubtype),
      );
      
      print('Created MultipartFile with filename: $fileName and content type: image/$mimeSubtype');

      // Submit the report
      final issue = await _apiClient.reportIssue(
        category: category,
        city: city,
        specificAddress: specificAddress,
        description: description,
        issueDate: issueDate,
        imageFile: multipartFile,
      );

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
  final apiClient = ref.watch(citizenApiClientProvider);
  return ReportFormNotifier(apiClient);
});
