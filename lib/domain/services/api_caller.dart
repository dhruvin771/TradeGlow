import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../res/endpoints.dart';
import 'failures.dart';

class ApiCaller {
  final Dio _dio = Dio(BaseOptions(
      baseUrl: AppEndpoints.domainUrl,
      connectTimeout: const Duration(seconds: 30)));

  Future<Either<Failure, Response>> getSymbols() async {
    try {
      final response = await _dio.get(AppEndpoints.symbols);
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Response>> getSymbolDetails(String symbol) async {
    try {
      final response = await _dio.get(AppEndpoints.symbolDetail(symbol));
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Response>> getCandleData(
      String symbol, String interval) async {
    try {
      final response = await _dio
          .get(AppEndpoints.candlesUrl(symbol: symbol, interval: interval));
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}
