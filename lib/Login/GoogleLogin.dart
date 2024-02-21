import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core paketini ekleyin
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whomii/Login/UserInfoPage.dart';
import 'package:whomii/Menu/WhoiiMennu.dart';
import 'package:whomii/data_model_class.dart';
import 'package:whomii/firebase_options.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// GoogleSignIn'in yapılandırılması
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: DefaultFirebaseOptions
      .currentPlatform.iosClientId, // Doğru client ID'yi almak için kullanıldı.
);

Future<User?> signInWithGoogle(BuildContext context) async {
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
      _saveUser(context);

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
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
              Text(
                'Merhaba! WhoMii Hoş Geldiniz!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  onPressed: () async {
                    // Giriş işlemi başarılıysa kullanıcıyı bir sonraki sayfaya yönlendir
                    User? user = await signInWithGoogle(context);
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
                    User? user = await signInWithGoogle(context);
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

void _saveUser(BuildContext context) async {
  String email = _auth.currentUser!.email.toString();

  UserFirebase user = UserFirebase(
      username: _auth.currentUser!.displayName.toString(),
      birthDate: DateTime.now(),
      location: '',
      email: _auth.currentUser!.email.toString());

  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection('users')
      .where('email', isEqualTo: email)
      .get();

  if (snapshot.docs.isNotEmpty) {
    // Eğer e-posta adresiyle kayıtlı bir kullanıcı varsa, bu kullanıcıyı güncelle
    FirebaseFirestore.instance
        .collection('users')
        .doc(snapshot.docs.first.id)
        .update(user.toMap())
        .then((value) {
      print("Kullanıcı bilgileri başarıyla güncellendi!");
    }).catchError((error) {
      print("Kullanıcı bilgilerini güncellerken bir hata oluştu: $error");
    });
  } else {
    // Eğer e-posta adresiyle kayıtlı bir kullanıcı yoksa, yeni bir kullanıcı oluştur
    FirebaseFirestore.instance.collection('users').add(user.toMap()).then(
      (value) async {
        print("Yeni kullanıcı başarıyla kaydedildi!");
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserInfoPage(),
          ),
        );
      },
    ).catchError(
      (error) {
        print("Yeni kullanıcı oluştururken bir hata oluştu: $error");
      },
    );
  }
}
