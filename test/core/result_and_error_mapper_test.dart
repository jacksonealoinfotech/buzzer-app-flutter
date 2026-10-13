import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buzzer_app/core/error/app_exception.dart';
import 'package:buzzer_app/core/error/error_mapper.dart';
import 'package:buzzer_app/core/error/failure.dart';
import 'package:buzzer_app/core/result/result.dart';

void main() {
  group('Result<T> Sealed Hierarchy Tests', () {
    test('Success branch pattern matching and data retrieval', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.getOrNull(), equals(42));
      expect(result.getOrElse((_) => 0), equals(42));

      final value = result.when(
        onSuccess: (data) => 'Value: $data',
        onFailure: (failure) => 'Failed',
      );
      expect(value, equals('Value: 42'));
    });

    test('FailureResult branch pattern matching and fold handling', () {
      const failure = NetworkFailure(message: 'Connection dropped');
      const result = Result<int>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.getOrNull(), isNull);
      expect(result.getOrElse((f) => -1), equals(-1));

      final mapped = result.map((data) => data * 2);
      expect(mapped.isFailure, isTrue);

      final folded = result.fold(
        (f) => 'Handled: ${f.message}',
        (d) => 'Success: $d',
      );
      expect(folded, equals('Handled: Connection dropped'));
    });

    test(
      'safeCall wraps successful async operation without throwing',
      () async {
        final result = await safeCall(() async => 'hello world');
        expect(result, isA<Success<String>>());
        expect((result as Success<String>).data, equals('hello world'));
      },
    );

    test('safeCall captures exceptions and returns FailureResult', () async {
      final result = await safeCall<String>(() async {
        throw const NetworkException();
      });

      expect(result, isA<FailureResult<String>>());
      final failureResult = result as FailureResult<String>;
      expect(failureResult.failure, isA<NetworkFailure>());
    });
  });

  group('ErrorMapper Tests', () {
    test('Maps HTTP 401 DioException to UnauthorizedException and Failure', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          statusCode: 401,
          data: {'message': 'Token expired'},
        ),
        type: DioExceptionType.badResponse,
      );

      final appException = ErrorMapper.fromDioException(dioException);
      expect(appException, isA<UnauthorizedException>());

      final failure = ErrorMapper.toFailure(dioException);
      expect(failure, isA<UnauthorizedFailure>());
    });

    test('Maps HTTP 404 to NotFoundFailure', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/missing'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/missing'),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );

      final failure = ErrorMapper.toFailure(dioException);
      expect(failure, isA<NotFoundFailure>());
    });

    test('Maps connection timeout to TimeoutFailure', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/timeout'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = ErrorMapper.toFailure(dioException);
      expect(failure, isA<TimeoutFailure>());
    });
  });
}
