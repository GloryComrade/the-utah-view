import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_config.dart';

enum ApiErrorKind { offline, timeout, notFound, server, invalidResponse }

/// A failed API call, classified so the UI can pick the right message.
class ApiException implements Exception {
  const ApiException(this.kind, {this.statusCode, this.detail});

  final ApiErrorKind kind;
  final int? statusCode;
  final String? detail;

  /// Short, reader-facing explanation.
  String get userMessage => switch (kind) {
    ApiErrorKind.offline =>
      "You're offline. Check your connection and try again.",
    ApiErrorKind.timeout =>
      'The Utah View is taking too long to respond. Try again.',
    ApiErrorKind.notFound => "This page isn't available.",
    ApiErrorKind.server || ApiErrorKind.invalidResponse =>
      'Something went wrong on our end. Try again shortly.',
  };

  @override
  String toString() =>
      'ApiException($kind${statusCode == null ? '' : ', $statusCode'}'
      '${detail == null ? '' : ', $detail'})';
}

/// Thin wrapper over Dio that returns decoded JSON and throws
/// [ApiException] for every failure mode.
class ApiClient {
  ApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
              // Decode ourselves so a wrong Content-Type can't break parsing.
              responseType: ResponseType.plain,
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<Object?> getJson(String path, {Map<String, String>? query}) =>
      _send(() => _dio.get<String>(path, queryParameters: query));

  Future<Object?> postJson(String path, Map<String, Object?> body) => _send(
    () => _dio.post<String>(
      path,
      data: jsonEncode(body),
      options: Options(contentType: Headers.jsonContentType),
    ),
  );

  /// `GET /api/me` with a Google ID token. Phase 2: used to sync saved
  /// stories once Google Sign-In is enabled.
  Future<Object?> getMe(String googleIdToken) => _send(
    () => _dio.get<String>(
      '/api/me',
      options: Options(headers: {'Authorization': 'Bearer $googleIdToken'}),
    ),
  );

  /// GET with a Bearer token (reader session or Google ID token).
  Future<Object?> getAuthed(String path, String token) => _send(
    () => _dio.get<String>(
      path,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    ),
  );

  /// POST JSON, optionally with a Bearer token (null for signup/login).
  Future<Object?> postAuthed(String path, Map<String, Object?> body, [String? token]) => _send(
    () => _dio.post<String>(
      path,
      data: jsonEncode(body),
      options: Options(
        contentType: Headers.jsonContentType,
        headers: token == null ? null : {'Authorization': 'Bearer $token'},
      ),
    ),
  );

  /// PUT JSON with a Bearer token.
  Future<Object?> putAuthed(String path, Map<String, Object?> body, String token) => _send(
    () => _dio.put<String>(
      path,
      data: jsonEncode(body),
      options: Options(
        contentType: Headers.jsonContentType,
        headers: {'Authorization': 'Bearer $token'},
      ),
    ),
  );

  Future<Object?> _send(Future<Response<String>> Function() request) async {
    final Response<String> response;
    try {
      response = await request();
    } on DioException catch (e) {
      throw _classify(e);
    }
    final text = response.data ?? '';
    if (text.trim().isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException catch (e) {
      throw ApiException(
        ApiErrorKind.invalidResponse,
        statusCode: response.statusCode,
        detail: e.message,
      );
    }
  }

  static ApiException _classify(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(ApiErrorKind.timeout);
      case DioExceptionType.connectionError:
        return ApiException(ApiErrorKind.offline, detail: e.message);
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        return ApiException(
          status == 404 ? ApiErrorKind.notFound : ApiErrorKind.server,
          statusCode: status,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        // Socket errors without a response usually mean no network.
        return ApiException(
          e.response == null ? ApiErrorKind.offline : ApiErrorKind.server,
          statusCode: e.response?.statusCode,
          detail: e.message,
        );
    }
  }
}
