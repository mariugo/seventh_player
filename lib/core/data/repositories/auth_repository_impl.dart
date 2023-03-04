import 'dart:convert';

import 'package:seventh_player/core/constants/server.dart';
import 'package:seventh_player/core/data/server/http_client_adapter.dart';
import 'package:seventh_player/core/domain/repositories/auth_repository.dart';
import 'package:seventh_player/core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final HttpClientAdapter httpClient;

  AuthRepositoryImpl({
    required this.httpClient,
  });

  @override
  Future login(userModel) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/login'),
        body: userModel.toJson(),
      );

      final responseDecoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseDecoded['token'];
      }
      return httpClient.returnResponse(response);
    } catch (_) {
      throw AppException(message: "Server error");
    }
  }
}