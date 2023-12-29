import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/user_model.dart';
import '../repository/auth_repository.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) => AuthController(
          authRepository: ref.watch(authRepositoryProvider),
          ref: ref,
        ));

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  authController.authStateChanges.listen((user) {
    if (user == null) {
      ref.read(userProvider.notifier).update((state) => null);
    }
  });
  return authController.authStateChanges;
});

class AuthController extends StateNotifier<bool> {
  final Ref _ref;

  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // loading state

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  Future<void> signInWithGoogle(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithGoogle();
    state = false;
    user.fold(
      (l) => SnackBar(content: Text(l.message)),
      (user) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }

  void isSignedInWithGoogle(BuildContext context) async {
    final user = await _authRepository.isSignedInWithGoogle();
    user.fold(
      (l) => SnackBar(content: Text(l.message)),
      (user) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  Future<void> signInWithApple(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInWithApple();
    state = false;
    user.fold(
      (l) => SnackBar(content: Text(l.message)),
      (user) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }

  void isSignedInWithApple(BuildContext context) async {
    final user = await _authRepository.isSignedInWithApple();
    user.fold(
      (l) => SnackBar(content: Text(l.message)),
      (user) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }

  void logout() async {
    _authRepository.logout();
  }
}
