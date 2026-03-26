import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/dio_client.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final DioClient _dioClient;

  AuthCubit(this._repository, this._dioClient) : super(AuthInitial());

  /// Try to restore session from secure storage on app start
  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      await _repository.restoreSession();
      final user = await _repository.getMe();
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  /// Called after WebView OAuth completes — persist cookie and load user
  Future<void> onOAuthComplete() async {
    emit(AuthLoading());
    try {
      await _repository.persistSession();
      final user = await _repository.getMe();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> continueAsGuest() async {
    emit(const AuthGuest());
  }
}
