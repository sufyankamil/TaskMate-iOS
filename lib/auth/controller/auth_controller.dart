import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../model/user_model.dart';
import '../../provider/failure.dart';
import '../../provider/providers.dart';
import '../repository/auth_repository.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final userProviders = Provider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.currentUser;
});

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

  User? _currentUser;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); // loading state

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  User? get currentUser => _currentUser;

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

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = true;
    final user =
        await _authRepository.signUpWithEmailAndPassword(email, password);
    state = false;

    user.fold(
      (failure) {
        Fluttertoast.showToast(
          msg: failure.message,
          backgroundColor: Colors.red,
          timeInSecForIosWeb: 6,
        );
      },
      (user) {
        _ref.read(userProvider.notifier).update((state) => user);
      },
    );
  }

  Future<bool> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      state = true;

      final user = await _authRepository.signInWithEmailAndPassword(
          email, password, context);

      state = false;

      if (user != null) {
        _ref
            .read(userProvider.notifier)
            .update((state) => UserModel.fromUser(user));
      } else {}
    } on FirebaseAuthException catch (e) {
      state = false; // Reset loading state

      switch (e.code) {
        case 'user-not-found':
          Fluttertoast.showToast(
            msg: 'User not found',
            backgroundColor: Colors.red,
            timeInSecForIosWeb: 6,
          );
          break;
        case 'wrong-password':
          Fluttertoast.showToast(
            msg: 'Incorrect password',
            backgroundColor: Colors.red,
            timeInSecForIosWeb: 6,
          );
          break;
        default:
          Fluttertoast.showToast(
            msg: 'Authentication failed: ${e.message}',
            backgroundColor: Colors.red,
            timeInSecForIosWeb: 6,
          );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error during sign-in: $e',
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 6,
      );
      state = false;
    }
    return false;
  }

  Future<void> deleteAccount(String uid, String email, String password) async {
    state = true;
    try {
      await _authRepository.deleteAccount(uid, email, password);
      _ref.read(userProvider.notifier).update((state) => null);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error deleting account. Please try again later.',
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 6,
      );
    } finally {
      state = false;
    }
  }

  Future<void> deleteAccountWithApple(
      BuildContext context, String email, String password) async {
    state = true;
    try {
      final userModel = _ref.read(userProvider);

      if (userModel != null) {
        await _authRepository.deleteAccountWithApple(userModel, password);
        _ref.read(userProvider.notifier).update((state) => null);
      } else {
        throw Failure('User is null');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error deleting account. Please try again later.',
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 6,
      );
    } finally {
      state = false;
    }
  }

  void logout() async {
    _authRepository.logout();
  }
}
