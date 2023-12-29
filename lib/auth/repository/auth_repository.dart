import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common/constants.dart';
import '../../model/user_model.dart';
import '../../provider/failure.dart';
import '../../provider/providers.dart';
import '../../provider/type_defs.dart';
import '../controller/auth_controller.dart';

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

      if (kDebugMode) {
        print(userCredential.additionalUserInfo!.isNewUser);
      }

      if (userCredential.additionalUserInfo!.isNewUser) {
        // create user in firestore
        user = UserModel(
          name: userCredential.user!.displayName!,
          email: userCredential.user!.email!,
          photoUrl: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          lastSeen: DateTime.now().toString(),
          isAuthenticated: true, // user is not guest
          // emailVerified: false,
          karma: 0,
        );
        if (kDebugMode) {
          print('new user');
        }
        // print(user);
        await _users.doc(userCredential.user!.uid).set(user.toMap());
      } else {
        // get user from firestore
        if (kDebugMode) {
          print('user already exists');
          print(userCredential.user!);
        }
        user = await getUserData(userCredential.user!.uid).first;
      }
      return right(user);
      // await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return left(Failure(e.toString()));
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
          email: result.email ?? '',
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
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> isSignedInWithApple() async {
    try {
      // Check if the user is currently signed in with Apple
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
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
