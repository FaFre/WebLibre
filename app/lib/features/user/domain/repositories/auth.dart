import 'package:lensai/features/user/domain/providers.dart';
import 'package:lensai/features/user/extensions/client_exception.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() {
    return message;
  }
}

@Riverpod()
class AuthRepository extends _$AuthRepository {
  late PocketBase _pb;

  Future<RecordAuth> authWithPassword(String user, String password) async {
    try {
      return await _pb.collection('users').authWithPassword(user, password);
    } on ClientException catch (e) {
      throw AuthException(e.errorMessage);
    }
  }

  Future<RecordModel> createUserWithPassword(
    String email,
    String password,
  ) async {
    try {
      return await _pb
          .collection('users')
          .create(
            body: {
              "email": email,
              "password": password,
              "passwordConfirm": password,
            },
          );
    } on ClientException catch (e) {
      throw AuthException(e.errorMessage);
    }
  }

  @override
  void build() {
    _pb = ref.watch(pocketBaseProvider);
  }
}
