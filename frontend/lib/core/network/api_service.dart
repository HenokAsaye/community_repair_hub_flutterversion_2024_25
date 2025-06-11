import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;
  final List<String> fallbackUrls = [
    'http://192.168.1.3:5500',   // Current IP address
        'http://192.168.1.3:5500',      // Android emulator special IP that points to host machine
        'http://192.168.1.3:5500',     // For local testing
    'http://192.168.1.3:5500'      // For local testing
  ];
  late String _currentActiveUrl;

  ApiService({required this.baseUrl}) : 
    _currentActiveUrl = baseUrl,
    _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),  // Increased timeout
    receiveTimeout: const Duration(seconds: 15),  // Increased timeout
    validateStatus: (status) => status != null && status < 500,
  )) {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
    
    // Add an interceptor to log all errors in detail
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        debugPrint('=== DIO ERROR DETAILS ===');
        debugPrint('Type: ${e.type}');
        debugPrint('Message: ${e.message}');
        debugPrint('Response: ${e.response}');
        debugPrint('Error: ${e.error}');
        debugPrint('RequestOptions: ${e.requestOptions.uri}');
        debugPrint('========================');
        return handler.next(e);
      }
    ));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    DioException? lastError;
    
    // Try with the primary URL first
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        lastError = e;
        debugPrint('Primary URL failed: ${e.message}');
      } else {
        debugPrint('GET Error: $e');
        rethrow;
      }
    }
    
    // If primary URL fails, try fallback URLs
    if (fallbackUrls.isNotEmpty) {
      debugPrint('Trying fallback URLs...');
      
      for (int i = 0; i < fallbackUrls.length; i++) {
        final fallbackUrl = fallbackUrls[i];
        debugPrint('Trying fallback URL: $fallbackUrl');
        
        try {
          // Create a new Dio instance with the fallback URL
          final fallbackDio = Dio(BaseOptions(
            baseUrl: fallbackUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            validateStatus: (status) => status != null && status < 500,
          ));
          
          final response = await fallbackDio.get(
            path,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onReceiveProgress: onReceiveProgress,
          );
          
          // If successful, update the primary Dio instance to use this URL
          _dio.options.baseUrl = fallbackUrl;
          _currentActiveUrl = fallbackUrl;
          debugPrint('Connection successful with fallback URL: $_currentActiveUrl');
          
          return response;
        } catch (e) {
          if (e is DioException) {
            lastError = e; // Update lastError with the latest DioException
            debugPrint('Fallback URL $fallbackUrl failed: ${e.message}');
          } else {
            debugPrint('Fallback URL $fallbackUrl error: $e');
            // Consider rethrowing or wrapping non-DioExceptions if specific handling is needed
          }
          // Continue to the next fallback URL
        }
      }
    }

    // If loop finishes, all URLs failed
    if (lastError == null) {
      // This case should ideally not be reached if baseUrls is not empty
      // and the loop runs at least once.
      // However, to be safe and satisfy the analyzer if baseUrls could be empty:
      lastError = DioException(
        requestOptions: RequestOptions(path: path), // Corrected 'endpoint' to 'path'
        message: 'No base URLs available or loop did not execute and lastError remained null.',
      );
    }
        
    // Now, lastError is guaranteed to be non-null by the block above.
    debugPrint('All URLs failed for GET. Last error: ${lastError.message}'); // Removed '!'
    throw lastError; // Removed '!'
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    DioException? lastError;
    
    // Try with the primary URL first
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        lastError = e;
        debugPrint('Primary URL failed for POST: ${e.message}');
      } else {
        debugPrint('POST Error: $e');
        rethrow;
      }
    }
    
    // If primary URL fails, try fallback URLs
    if (fallbackUrls.isNotEmpty) {
      debugPrint('Trying fallback URLs for POST...');
      
      for (int i = 0; i < fallbackUrls.length; i++) {
        final fallbackUrl = fallbackUrls[i];
        debugPrint('Trying fallback URL for POST: $fallbackUrl');
        
        try {
          // Create a new Dio instance with the fallback URL
          final fallbackDio = Dio(BaseOptions(
            baseUrl: fallbackUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            validateStatus: (status) => status != null && status < 500,
          ));
          
          final response = await fallbackDio.post(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          
          // If successful, update the primary Dio instance to use this URL
          _dio.options.baseUrl = fallbackUrl;
          _currentActiveUrl = fallbackUrl;
          debugPrint('POST successful with fallback URL: $_currentActiveUrl');
          
          return response;
        } catch (e) {
          if (e is DioException) {
            debugPrint('Fallback URL $fallbackUrl failed for POST: ${e.message}');
          } else {
            debugPrint('Fallback URL $fallbackUrl error for POST: $e');
          }
          // Continue to the next fallback URL
        }
      }
    }
    
    // If all URLs fail, throw the last error
    // The analyzer indicates lastError cannot be null here, so the if condition is removed.
      debugPrint('All URLs failed for POST. Last error: ${lastError.message}');
      throw lastError;
    // } else { ... } block removed as the condition for 'if (lastError != null)' was deemed always true by the analyzer.
  }
  
  Future<Response> postFormData(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    DioException? lastError;
    
    // Try with the primary URL first
    try {
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        lastError = e;
        debugPrint('Primary URL failed for POST FormData: ${e.message}');
      } else {
        debugPrint('POST FormData Error: $e');
        rethrow;
      }
    }
    
    // If primary URL fails, try fallback URLs
    if (fallbackUrls.isNotEmpty) {
      debugPrint('Trying fallback URLs for POST FormData...');
      
      for (int i = 0; i < fallbackUrls.length; i++) {
        final fallbackUrl = fallbackUrls[i];
        debugPrint('Trying fallback URL for POST FormData: $fallbackUrl');
        
        try {
          // Create a new Dio instance with the fallback URL
          final fallbackDio = Dio(BaseOptions(
            baseUrl: fallbackUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            validateStatus: (status) => status != null && status < 500,
          ));
          
          final response = await fallbackDio.post(
            path,
            data: formData,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          
          // If successful, update the primary Dio instance to use this URL
          _dio.options.baseUrl = fallbackUrl;
          _currentActiveUrl = fallbackUrl;
          debugPrint('POST FormData successful with fallback URL: $_currentActiveUrl');
          
          return response;
        } catch (e) {
          if (e is DioException) {
            debugPrint('Fallback URL $fallbackUrl failed for POST FormData: ${e.message}');
          } else {
            debugPrint('Fallback URL $fallbackUrl error for POST FormData: $e');
          }
          // Continue to the next fallback URL
        }
      }
    }
    
    // If all URLs fail, throw the last error
    if (lastError != null) {
      debugPrint('All URLs failed for POST FormData. Last error: ${lastError.message}');
      throw lastError;
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'All connection attempts failed for POST FormData',
      );
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    DioException? lastError;

    // Try with the primary URL first
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        lastError = e;
        debugPrint('Primary URL failed for PUT: ${e.message}');
      } else {
        debugPrint('PUT Error: $e');
        rethrow;
      }
    }

    // If primary URL fails, try fallback URLs
    if (fallbackUrls.isNotEmpty) {
      debugPrint('Trying fallback URLs for PUT...');

      for (int i = 0; i < fallbackUrls.length; i++) {
        final fallbackUrl = fallbackUrls[i];
        debugPrint('Trying fallback URL for PUT: $fallbackUrl');

        try {
          final fallbackDio = Dio(BaseOptions(
            baseUrl: fallbackUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            validateStatus: (status) => status != null && status < 500,
          ));

          final response = await fallbackDio.put(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );

          _dio.options.baseUrl = fallbackUrl;
          _currentActiveUrl = fallbackUrl;
          debugPrint('PUT successful with fallback URL: $_currentActiveUrl');

          return response;
        } catch (e) {
          if (e is DioException) {
            debugPrint('Fallback URL $fallbackUrl failed for PUT: ${e.message}');
          } else {
            debugPrint('Fallback URL $fallbackUrl error for PUT: $e');
          }
        }
      }
    }

    if (lastError != null) {
      debugPrint('All URLs failed for PUT. Last error: ${lastError.message}');
      throw lastError;
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'All connection attempts failed for PUT',
      );
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    DioException? lastError;

    // Try with the primary URL first
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        lastError = e;
        debugPrint('Primary URL failed for PATCH: ${e.message}');
      } else {
        debugPrint('PATCH Error: $e');
        rethrow;
      }
    }

    // If primary URL fails, try fallback URLs
    if (fallbackUrls.isNotEmpty) {
      debugPrint('Trying fallback URLs for PATCH...');

      for (int i = 0; i < fallbackUrls.length; i++) {
        final fallbackUrl = fallbackUrls[i];
        debugPrint('Trying fallback URL for PATCH: $fallbackUrl');

        try {
          final fallbackDio = Dio(BaseOptions(
            baseUrl: fallbackUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            validateStatus: (status) => status != null && status < 500,
          ));

          final response = await fallbackDio.patch(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );

          _dio.options.baseUrl = fallbackUrl;
          _currentActiveUrl = fallbackUrl;
          debugPrint('PATCH successful with fallback URL: $_currentActiveUrl');

          return response;
        } catch (e) {
          if (e is DioException) {
            debugPrint('Fallback URL $fallbackUrl failed for PATCH: ${e.message}');
          } else {
            debugPrint('Fallback URL $fallbackUrl error for PATCH: $e');
          }
        }
      }
    }

    if (lastError != null) {
      debugPrint('All URLs failed for PATCH. Last error: ${lastError.message}');
      throw lastError;
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'All connection attempts failed for PATCH',
      );
    }
  }
}
