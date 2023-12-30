import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';

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

  Future<void> deleteAccount(BuildContext context) async {
    state = true;

    try {
      final user = _ref.read(userProvider);

      print(user);

      // print(
      //     "Provider Ids: ${FirebaseAuth.instance.currentUser!.providerData.map((info) => info.providerId)}");
      print("---------");
      // print(FirebaseAuth.instance.currentUser);

      // await FirebaseAuth.instance.currentUser!.delete();

      // print(user);

      // if (user != null) {
      await _authRepository.deleteAccount(user!.uid);
    } on Either<Failure, void> catch (either) {
      // Handle the failure, show error message, etc.
      SnackBar(
          content: Text(either.fold((l) => l.message, (_) => 'Unknown error')));
    } finally {
      state = false;
    }
  }

  Future<void> deleteAccount1(BuildContext context) async {
    state = true;

    try {
      final user = _currentUser;

      if (user != null) {
        print(
            "Provider Ids: ${user.providerData.map((info) => info.providerId)}");
        // Pass the uid to deleteAccount
        await _authRepository.deleteAccount(user.uid);
        // After deleting the account, you might want to navigate to a different screen or perform other actions.
        // For example, you can use Navigator.pushReplacement to go to a login screen.
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } on Either<Failure, void> catch (either) {
      // Handle the failure, show error message, etc.
      SnackBar(
        content: Text(either.fold((l) => l.message, (_) => 'Unknown error')),
      );
    } finally {
      state = false;
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = true;
    final user =
        await _authRepository.signUpWithEmailAndPassword(email, password);
    state = false;

    user.fold((failure) {
      Fluttertoast.showToast(
        msg: failure.message,
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 6,
      );
    }, (user) {
      _ref.read(userProvider.notifier).update((state) => user);
    },);
  }

  void logout() async {
    _authRepository.logout();
  }
}
