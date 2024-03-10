import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common/constants.dart';
import '../../model/user_model.dart';
import '../../provider/failure.dart';
import '../../provider/providers.dart';
import '../../provider/type_defs.dart';

// authRepo is a provider that returns an instance of AuthRepository
final authRepositoryProvider = Provider((ref) => AuthRepository(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(firebaseAuthProvider),
      googleSignIn: ref.read(googleSignInProvider),
    ));

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _firestore = firestore,
        _auth = auth,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(Constants.usersCollection);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final credential = GoogleAuthProvider.credential(
        accessToken: (await googleUser!.authentication).accessToken,
        idToken: (await googleUser.authentication).idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);

      UserModel user;

      bool userExists = await userExistsInFirestore(userCredential.user!.uid);

      if (userCredential.additionalUserInfo!.isNewUser || userExists) {
        // create user in firestore
        user = UserModel(
          name: userCredential.user!.displayName!,
          email: userCredential.user!.email!,
          photoUrl: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          lastSeen: DateTime.now().toString(),
          isAuthenticated: true,
          karma: 0,
        );
      } else {
        // get user from firestore
        user = await getUserData(userCredential.user!.uid).first;
      }

      return right(user);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel user = UserModel(
        name: userCredential.user?.displayName ?? 'DefaultName',
        email: userCredential.user?.email ?? 'DefaultEmail',
        photoUrl: userCredential.user?.photoURL ?? Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user?.uid ?? 'DefaultUID',
        lastSeen: DateTime.now().toString(),
        isAuthenticated: true,
        karma: 0,
      );

      await _users.doc(user.uid).set(user.toMap());

      return right(user);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return left(Failure(e.toString()));
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.code);
      }
      switch (e.code) {
        case 'ERROR_USER_NOT_FOUND':
          Fluttertoast.showToast(
            msg: 'User with this email doesn\'t exist.',
            timeInSecForIosWeb: 6,
            backgroundColor: Colors.red,
          );
          break;
        case 'ERROR_WRONG_PASSWORD':
          Fluttertoast.showToast(
            msg: 'Wrong password provided for that user.',
            timeInSecForIosWeb: 6,
            backgroundColor: Colors.red,
          );
          break;
        case 'ERROR_INVALID_EMAIL':
          Fluttertoast.showToast(
            msg: 'Your email address appears to be malformed.',
            timeInSecForIosWeb: 6,
            backgroundColor: Colors.red,
          );
          break;
        case 'ERROR_USER_DISABLED':
          Fluttertoast.showToast(
            msg: 'User with this email has been disabled.',
            timeInSecForIosWeb: 6,
            backgroundColor: Colors.red,
          );
          break;
        case 'too-many-requests':
          if (context.mounted) {
            await showPlatformDialog(
              context: context,
              builder: (_) => BasicDialogAlert(
                title: const Text("Too Many Requests"),
                content: const Text(
                    "Access to this account has been temporarily disabled due to many failed login attempts. You can try again later."),
                actions: <Widget>[
                  BasicDialogAction(
                    title: const Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
          break;
        case 'ERROR_OPERATION_NOT_ALLOWED':
          Fluttertoast.showToast(
            msg: 'Signing in with Email and Password is not enabled.',
            timeInSecForIosWeb: 6,
            backgroundColor: Colors.red,
          );
        case 'INVALID_LOGIN_CREDENTIALS':
          Fluttertoast.showToast(
            msg: 'Invalid login credentials',
            timeInSecForIosWeb: 6,
            backgroundColor: Colors.red,
          );
          break;
        default:
          Fluttertoast.showToast(
            msg: 'Unable to login. Please try again later.',
            timeInSecForIosWeb: 6,
            backgroundColor: Colors.purple,
          );
      }
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  Future<bool> userExists(String email) async {
    try {
      final user = await _auth.fetchSignInMethodsForEmail(email);
      return user.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException, e.g., show an error message
      if (kDebugMode) {
        print('Failed to send password reset email: ${e.message}');
      }
      throw Failure(e.message!);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending password reset email: $e');
      }
      throw Failure(e.toString());
    }
  }

  Future<void> deleteAccount(String uid, String email, String password) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Re-authenticate the user before deleting the account
        final credential =
            EmailAuthProvider.credential(email: email, password: password);
        await user.reauthenticateWithCredential(credential);

        // Delete the user document from Firestore
        await _users.doc(uid).delete();

        // Delete the user from Firebase Authentication
        await user.delete();

        // Sign out the user
        logout();

        Fluttertoast.showToast(
          msg: 'Account deleted successfully',
          backgroundColor: Colors.green,
        );
      } else {
        throw Failure('User is null');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Failure(e.toString());
    }
  }

  Future<bool> userExistsInFirestore(String uid) async {
    // Check if the user exists in Firestore based on the UID
    try {
      DocumentSnapshot userSnapshot = await _users.doc(uid).get();
      return userSnapshot.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user existence in Firestore: $e');
      }
      return false;
    }
  }

  // Stream is used to listen to changes in the user's authentication state (persisted in local storage)
  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  FutureEither<UserModel> isSignedInWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _users.doc(user.uid).get();
        if (userDoc.exists) {
          return right(
              UserModel.fromMap(userDoc.data() as Map<String, dynamic>));
        } else {
          return left(Failure('User does not exist'));
        }
      } else {
        return left(Failure('User is null'));
      }
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInWithApple() async {
    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");

      final AuthCredential credential = oAuthProvider.credential(
        idToken: result.identityToken,
        accessToken: result.authorizationCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserModel user;

      if (kDebugMode) {
        print(userCredential.additionalUserInfo!.isNewUser);
      }

      if (userCredential.additionalUserInfo!.isNewUser) {
        // create user in firestore

        // Helper method to extract Apple email from providerData
        String extractAppleEmail(UserCredential userCredential) {
          return userCredential.additionalUserInfo?.profile?['email'] ?? 'N/A';
        }

        user = UserModel(
          name: result.familyName ?? '',
          email: result.email ?? extractAppleEmail(userCredential),
          photoUrl: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          lastSeen: DateTime.now().toString(),
          isAuthenticated: true,
          karma: 0,
        );

        if (kDebugMode) {
          print('new user');
        }

        await _users.doc(userCredential.user!.uid).set(user.toMap());
      } else {
        // get user from firestore
        if (kDebugMode) {
          print(userCredential.additionalUserInfo?.profile?['email']);
          print('user already exists');
          print(userCredential.user!);
        }

        user = await getUserData(userCredential.user!.uid).first;
      }

      return right(user);
    } on SignInWithAppleException {
      Fluttertoast.showToast(
          msg: 'The operation couldn’t be completed. Try again later.',
          backgroundColor: Colors.red);

      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return left(Failure(e.toString()));
    }
  }

  Future<void> deleteAccountWithApple(UserModel user, String password) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Re-authenticate the user before deleting the account
        final result = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final OAuthProvider oAuthProvider = OAuthProvider("apple.com");

        final AuthCredential credential = oAuthProvider.credential(
          idToken: result.identityToken,
          accessToken: result.authorizationCode,
        );

        await user.reauthenticateWithCredential(credential);

        // Delete the user document from Firestore
        await _users.doc(user.uid).delete();

        // Delete the user from Firebase Authentication
        await user.delete();

        Fluttertoast.showToast(
          msg: 'Account deleted successfully',
          backgroundColor: Colors.green,
        );

        // Sign out the user
        logout();
      } else {
        throw Failure('User is null');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Failure(e.toString());
    }
  }

  FutureEither<UserModel> isSignedInWithApple() async {
    try {
      // Check if the user is currently signed in with Apple

      final user = _auth.currentUser;

      if (user != null) {
        final userDoc = await _users.doc(user.uid).get();

        if (userDoc.exists) {
          return right(
              UserModel.fromMap(userDoc.data() as Map<String, dynamic>));
        } else {
          return left(Failure('User does not exist'));
        }
      } else {
        return left(Failure('User is null'));
      }
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return left(Failure(e.toString()));
    }
  }

  Future<void> refreshUserData(Function(UserModel?) updateUserState) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        final userDoc = await _users.doc(user.uid).get();

        if (userDoc.exists) {
          final refreshedUser =
              UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          updateUserState(refreshedUser);
        } else {
          throw Failure('User does not exist');
        }
      } else {
        throw Failure('User is null');
      }
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  void logout() async {
    await _auth.signOut();
  }

  Future<void> logoutWithEmailAndPassword() async {
    try {
      // await _auth.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Failure(e.toString());
    }
  }
}
