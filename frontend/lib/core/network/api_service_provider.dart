import 'package:flutter_riverpod/flutter_riverpod.dart';
import './api_service.dart'; // Imports ApiService from the same directory

// This is the primary base URL for your application.
// It's taken from one of the fallback URLs in your ApiService for now.
// Consider moving this to a more formal configuration management system if needed.
const String _primaryBaseUrl = 'http://192.168.100.10:5500'; 

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: _primaryBaseUrl);
});
