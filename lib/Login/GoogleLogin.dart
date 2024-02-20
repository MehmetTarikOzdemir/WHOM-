import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core paketini ekleyin
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whomii/Menu/WhoiiMennu.dart';
import 'package:whomii/firebase_options.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// GoogleSignIn'in yapılandırılması
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: DefaultFirebaseOptions
      .currentPlatform.iosClientId, // Doğru client ID'yi almak için kullanıldı.
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

class GoogleLogin extends StatefulWidget {
  @override
  _GoogleLoginState createState() => _GoogleLoginState();
}

class _GoogleLoginState extends State<GoogleLogin> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() async {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/whomanalytic_logo.png', // Resmin yolunu belirtin
                width: 200, // İsteğe bağlı: Resmin genişliği
                height: 200, // İsteğe bağlı: Resmin yüksekliği
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  onPressed: () async {
                    // Giriş işlemi başarılıysa kullanıcıyı bir sonraki sayfaya yönlendir
                    User? user = await signInWithGoogle();
                    if (user != null) {
                      print("Kullanıcı Var" + user.displayName.toString());
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WhoiiMenu(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Giriş yap",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: 300,
                height: 70,
                child: OutlinedButton(
                  onPressed: () async {
                    // Giriş işlemi başarılıysa kullanıcıyı bir sonraki sayfaya yönlendir
                    User? user = await signInWithGoogle();
                    if (user != null) {
                      print("Kullanıcı Var" + user.displayName.toString());
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WhoiiMenu(),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Kayıt ol",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
