import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginService {
  // Sign in with Google
  // Future<UserCredential> signInWithGoogle() async {
  //   try {
  //     // Trigger the authentication flow
  //     GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser!.authentication;

  //     // Create a new credential
  //     final GoogleAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     ) as GoogleAuthCredential;

  //     // Once signed in, return the UserCredential
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     print(userCredential.user!.displayName);

  //     return userCredential;
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }

  signinWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    print(userCredential.user!.displayName);
  }
}
