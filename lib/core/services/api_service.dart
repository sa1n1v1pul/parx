import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  final GetStorage _storage = GetStorage();

  // Initialize interceptor
  void init() {
    _dio.interceptors.clear(); // Clear existing interceptors first
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read(AppConstants.tokenKey);
          print('[API_SERVICE] Request URL: ${options.baseUrl}${options.path}');
          print('[API_SERVICE] Token exists: ${token != null}');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print(
              '[API_SERVICE] Authorization header added: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
            );
          } else {
            print('[API_SERVICE] No token found in storage');
          }
          print('[API_SERVICE] Request headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('[API_SERVICE] Response status: ${response.statusCode}');
          print('[API_SERVICE] Response data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('[API_SERVICE] Error occurred: ${error.message}');
          print('[API_SERVICE] Error response: ${error.response?.data}');
          print(
            '[API_SERVICE] Error status code: ${error.response?.statusCode}',
          );
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear storage and redirect to login
            _storage.erase();
            print('[API_SERVICE] 401 Unauthorized - cleared storage');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT Request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      rethrow;
    }
  }

  // POST with FormData (for file uploads)
  Future<Response> postFormData(String endpoint, FormData formData) async {
    try {
      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Clear all cache and storage
  void clearCache() {
    try {
      // Remove token from storage
      _storage.remove(AppConstants.tokenKey);

      // Clear interceptors
      _dio.interceptors.clear();

      // Re-initialize interceptors without token
      init();
    } catch (e) {
      // Ignore errors
    }
  }
}
