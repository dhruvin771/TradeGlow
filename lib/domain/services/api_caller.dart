import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../res/endpoints.dart';
import 'failures.dart';

class ApiCaller {
  final Dio _dio = Dio(BaseOptions(
      baseUrl: AppEndpoints.domainUrl,
      connectTimeout: const Duration(seconds: 30)));

  Future<Either<Failure, Response>> symbols() async {
    try {
      final response = await _dio.get(AppEndpoints.symbolsUrl);
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}
