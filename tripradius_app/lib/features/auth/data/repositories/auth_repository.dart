import '../../data/models/user_model.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/dio_client.dart';

class AuthRepository {
  final ApiService _api;
  final DioClient _dioClient;

  AuthRepository(this._api, this._dioClient);

  Future<UserModel> getMe() => _api.getMe();

  Future<void> persistSession() => _dioClient.persistSession();

  Future<void> restoreSession() => _dioClient.restoreSession();

  Future<void> logout() async {
    try {
      await _dioClient.dio.get('/logout');
    } catch (_) {}
    await _dioClient.clearSession();
  }
}
