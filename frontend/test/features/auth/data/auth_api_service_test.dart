import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:community_repair_hub/features/auth/data/auth_api_service.dart';
import 'auth_api_service_test.mocks.dart';
import 'package:community_repair_hub/features/auth/domain/entities/user.dart';

@GenerateMocks([Dio])
void main() {
  late AuthApiService authApiService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    authApiService = AuthApiService(mockDio);
  });

  group('AuthApiService', () {
    group('login', () {
      test('returns a User on successful login', () async {
        final userJson = {
          'id': '1',
          'name': 'Test User',
          'email': 'test@example.com',
          'role': 'citizen',
          'token': 'test_token',
          'status': 'active'
        };
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: userJson,
          statusCode: 200,
        );

        when(mockDio.post(any, data: anyNamed('data'))).thenAnswer((_) async => response);

        final result = await authApiService.login('test@example.com', 'password');

        expect(result, isA<User>());
        expect(result.token, 'test_token');
        expect(result.name, 'Test User');
      });

      test('throws exception on failed login', () async {
        when(mockDio.post(any, data: anyNamed('data')))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        expect(() => authApiService.login('test@example.com', 'wrong_password'), throwsException);
      });
    });

    group('register', () {
      test('returns a User on successful call', () async {
        final userJson = {
          'id': '1',
          'name': 'Test',
          'email': 'test@test.com',
          'role': 'citizen',
          'token': 'test_token',
          'status': 'active',
        };
        when(mockDio.post('/auth/register', data: anyNamed('data')))
            .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: ''), data: userJson, statusCode: 200));

        final result = await authApiService.register(name: 'Test', email: 'test@test.com', password: 'password', role: 'citizen');

        expect(result, isA<User>());
        expect(result.name, 'Test');
      });

      test('throws exception on failed registration', () async {
        when(mockDio.post(any, data: anyNamed('data')))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        expect(
          () => authApiService.register(name: 'Test', email: 'test@example.com', password: 'password', role: 'citizen'),
          throwsException,
        );
      });
    });
  });
}
