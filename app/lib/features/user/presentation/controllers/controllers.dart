import 'package:lensai/features/user/domain/repositories/auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'controllers.g.dart';

@Riverpod()
class AuthController extends _$AuthController {
  @override
  Future<void> build() {
    return Future.value();
  }

  Future<void> authWithPassword(String user, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider.notifier)
          .authWithPassword(user, password),
    );
  }

  Future<void> registerWithPassword(String user, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final repo = ref.read(authRepositoryProvider.notifier);
      return repo
          .createUserWithPassword(user, password)
          .then((_) => repo.authWithPassword(user, password));
    });
  }

  void clearState() {
    state = const AsyncValue.data(null);
  }
}
