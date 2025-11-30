import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../components/toast/toats.dart';
import '../../../data/local_secure/secure_storage.dart';
import '../notifications_services/firebase_messaging_service.dart';

class FirebaseAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para registrar un usuario con Google
  Future<User?> signUpWithGoogle(String password) async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.updatePassword(password);
        await user.sendEmailVerification();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        showToast(message: 'An account already exists with a different credential.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

  // Método para iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {

      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      showToast(message: 'An error occurred: ${e.code}');
    }
    return null;
  }

  // Metodo para reestablecer contraseña
  Future<void> passwordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showToast(message: 'Password reset email has ben sent to $email.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast(message: 'User not found.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await FirebaseMessagingService().unregisterTokenOnLogout();
    await SecureStorageAgroSig().clearAllData();
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

}
