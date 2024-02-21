import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whomii/Login/GoogleLogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class WhoiiMenu extends StatefulWidget {
  @override
  WhoiiMenuPage createState() => WhoiiMenuPage();
}

List<Map<String, dynamic>> _questions = [];
late int _currentQuestionIndex = 0;

class WhoiiMenuPage extends State<WhoiiMenu> {
  @override
  void initState() {
    super.initState();
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Tüm sorular çözüldü, işlem burada ele alınabilir.
        //_showEndScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Geri düğmesini devre dışı bırakır
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(_auth.currentUser!.photoURL.toString()),
            ),
            SizedBox(width: 10),
            Text(
              _auth.currentUser!.displayName.toString() +
                  "\n -- " +
                  _updateGreeting() +
                  " -- ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Metni merkeze hizalar
            ), // Kullanıcı adı
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Çıkış Onayı"),
                    content:
                        Text("Hesaptan çıkmak istediğinizden emin misiniz?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // İletişim kutusunu kapat
                        },
                        child: Text("İptal"),
                      ),
                      TextButton(
                        onPressed: () {
                          signOutGoogle(
                              context); // Hesaptan çıkış işlemini gerçekleştir
                          Navigator.pop(context); // İletişim kutusunu kapat
                        },
                        child: Text("Evet"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Hesap Silme Onayı"),
                    content: Text(
                        "Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // İletişim kutusunu kapat
                        },
                        child: Text("İptal"),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteAccount();
                        },
                        child: Text("Evet, Hesabımı Sil"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            QuestionCard(
              onPressed: (index) {
                print("Control : " + index.toString());
                setState(() {
                  if (set >= 2 && startingIndex >= 3) {
                    set = 1;
                    startingIndex = 0;
                    randomQuestion = true;
                  }
                });
              },
            ), // Doğrudan QuestionCard'ı burada eklemeyin
          ],
        ),
      ),
    );
  }

  void signOutGoogle(BuildContext context) async {
    try {
      await googleSignIn.signOut();
      _auth.signOut().whenComplete(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return GoogleLogin();
            },
          ),
        );
      });

      print("User Signed Out");
    } catch (error) {
      print(error);
    }
  }

  String _updateGreeting() {
    DateTime now = DateTime.now();
    if (now.hour >= 5 && now.hour < 12) {
      return 'Günaydın';
    } else if (now.hour >= 12 && now.hour < 18) {
      return 'İyi Günler';
    } else {
      return 'İyi Geceler';
    }
  }

  Future<void> _deleteAccount() async {
    try {
      // Kullanıcının kimlik doğrulama bilgilerini al
      User? user = _auth.currentUser;

      // Firebase Authentication üzerinde kullanıcıyı sil
      await user?.delete();
      googleSignIn.signOut();
      // Hesap başarıyla silindiğinde kullanıcıyı çıkış yapmaya zorla
      // Bu adım isteğe bağlıdır, gereksinimlerinize göre değiştirebilirsiniz
      await _auth.signOut().whenComplete(
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return GoogleLogin();
              },
            ),
          );
        },
      );

      print("Hesap başarıyla silindi.");
    } catch (e) {
      print("Hesap silinirken bir hata oluştu: $e");
    }
  }
}

int set = 1;
int startingIndex = 0; // Başlangıç indeksi
int numberOfItemsToShow = 5; // Göstermek istediğiniz öğe sayısı
bool randomQuestion = false;
int randomNumber = Random().nextInt(6);

class QuestionCard extends StatelessWidget {
  final Function(int) onPressed; // int tipinde parametre alan bir fonksiyon

  QuestionCard({required this.onPressed});

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection(
          randomQuestion ? 'RandomQuestions' : 'Questions-' + set.toString())
      .snapshots();
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("");
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
        int endingIndex = startingIndex + numberOfItemsToShow;
        if (endingIndex > documents.length) {
          endingIndex = documents.length;
        }
        if (randomQuestion) startingIndex = randomNumber;
        Map<String, dynamic> data =
            documents[startingIndex].data()! as Map<String, dynamic>;
        List<String> options = parseOptions(data['answer']);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    documents[startingIndex].id,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 400,
                  height: 200,
                  child: Card(
                    child: Center(
                      child: Text(
                        data['question'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (randomQuestion)
                  TextField(
                    controller: _controller,
                    maxLines:
                        null, // Birden fazla satıra izin vermek için null yapın
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter your text here',
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (randomQuestion)
                  SizedBox(
                    height: 10,
                  ),
                if (randomQuestion)
                  SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors
                                  .grey; // Color when button is disabled
                            }
                            return Colors.green; // Default color
                          },
                        ),
                      ),
                      child: Text(
                        "Süperrrr",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (!randomQuestion)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: options.map((option) {
                      return SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!randomQuestion) {
                              onPressed(startingIndex +=
                                  1); // Yeni index ile çağrıldı

                              if (startingIndex >= 3) {
                                set += 1;
                                startingIndex = 0;
                              }

                              print("Seçilen seçenek: $option " +
                                  (startingIndex).toString() +
                                  randomQuestion.toString());
                            } else {}
                          },
                          child: Text(
                            option,
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 48, 44, 44),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> parseOptions(String optionsString) {
    // "-" karakterlerine göre metni ayır
    List<String> options = optionsString.split("-");
    // Boşlukları ve * işaretlerini kaldır

    return options;
  }
}
