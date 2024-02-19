import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core paketini ekleyin
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whomii/firebase_options.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

final GoogleSignIn googleSignIn = GoogleSignIn(
  // The OAuth client id of your app. This is required.
  clientId:
      '200260471892-obts6c4ds6ms5m9mrl7rth5tdffjq7d0.apps.googleusercontent.com',
  // If you need to authenticate to a backend server, specify its OAuth client. This is optional.
);

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    }
    return null; // Kullanıcı giriş yapmayı reddetti veya bir hata oluştu
  } catch (error) {
    print(error);
    return null; // Hata durumunda null döndürülüyor
  }
}

void signOutGoogle() async {
  try {
    await googleSignIn.signOut();
    print("User Signed Out");
  } catch (error) {
    print(error);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: 'Your App Title',
    home: GoogleLogin(title: 'Login'),
  ));
}

class GoogleLogin extends StatefulWidget {
  GoogleLogin({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _GoogleLoginState createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Google Sign-In Example"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Giriş işlemi başarılıysa kullanıcıyı bir sonraki sayfaya yönlendir
              User? user = await signInWithGoogle();
              if (user != null) {
                print("Kullanıcı Var" + user.displayName.toString());
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NextPage(),
                  ),
                );
              }
            },
            child: Text("Sign in with Google"),
          ),
        ),
      ),
    );
  }
}

// Kullanıcı giriş yaptıktan sonra yönlendirilecek olan sayfa
class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: Center(
        child: Text("Welcome!"), // Giriş yapan kullanıcıya hoş geldiniz mesajı
      ),
    );
  }
}
