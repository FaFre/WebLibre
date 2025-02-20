import 'package:lensai/features/user/domain/entities/auth_exception.dart';
import 'package:lensai/features/user/domain/providers.dart';
import 'package:lensai/features/user/extensions/client_exception.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

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
