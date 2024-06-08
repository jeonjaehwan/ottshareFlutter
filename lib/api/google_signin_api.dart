import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    // clientId: "792630821956-174o7po8bef7uk5j7a6dkd6l39t99eq3.apps.googleusercontent.com"
  );

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future logout() => _googleSignIn.disconnect();
}