import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelo/data/FirebaseServices/helper.dart';
import 'package:travelo/data/models/AuthResult.dart';

class Repository extends FirebaseHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential usr = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = usr.user;

      if (user != null) {
        return AuthResult(
          success: true,
          uid: user.uid,
          email: user.email,
          name: user.displayName,
        );
      } else {
        return AuthResult(
          success: false,
          message: "User not found",
        );
      }
    } on FirebaseAuthException catch (e) {
      final message = getErrorMessage(e);
      return AuthResult(success: false, message: message);
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential usr = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = usr.user;

      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.reload();

        return AuthResult(
          success: true,
          uid: user.uid,
          email: user.email,
          name: fullName,
        );
      } else {
        return AuthResult(
          success: false,
          message: "Failed to create user",
        );
      }
    } on FirebaseAuthException catch (e) {
      final message = getErrorMessage(e);
      return AuthResult(success: false, message: message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
