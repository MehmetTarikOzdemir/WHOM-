import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whomii/Login/GoogleLogin.dart';
import 'package:whomii/data_model_class.dart';
import 'package:flutter/material.dart';
import 'dart:math';

final FirebaseAuth _auth = FirebaseAuth.instance;

class WhoiiMenu extends StatefulWidget {
  @override
  WhoiiMenuPage createState() => WhoiiMenuPage();
}

class WhoiiMenuPage extends State<WhoiiMenu> {
  @override
  void initState() {
    super.initState();
    setState(() {});
    getSet();
    set = 0;
    print("Reset");
    answerClassList = []; // Başlangıç değeri atanıyor
    randomQuestion = false;
    questionComplite = false;
    startingIndex = 0;
    Timer(Duration(seconds: 1), () {
      setState(() {});
    });
  }

  late List<AnswerClass> answerClassList;
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
              _updateGreeting() +
                  " \n " +
                  _auth.currentUser!.displayName.toString(),
              style: TextStyle(
                fontSize: 18,
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
        child: set == 0
            ? SizedBox(
                width: 32.0,
                height: 32.0,
                child:
                    CircularProgressIndicator(), // set 0 olduğunda loading göster
              )
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView(
                  children: [
                    QuestionCard(
                      onPressed: (data) {
                        answerClassList.add(AnswerClass(
                            questionText: data.text, answer: data.value));
                        setState(() {
                          if (set >= 2 &&
                              startingIndex >= 3 &&
                              randomQuestion == false) {
                            set = 1;
                            startingIndex = 0;
                            randomQuestion = true;
                            saveAnswers();
                          }
                        });
                      },
                    ), // Doğrudan QuestionCard'ı burada eklemeyin
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> saveAnswers() async {
    String email = _auth.currentUser!.email.toString();

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    UserFirebase user = UserFirebase(
        username: _auth.currentUser!.displayName.toString(),
        birthDate: snapshot.docs.first.get('birthDate') == null
            ? "null"
            : snapshot.docs.first.get('birthDate'),
        location: snapshot.docs.first.get('location'),
        email: _auth.currentUser!.email.toString(),
        answers: answerClassList);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(snapshot.docs.first.id)
        .update(user.toMap())
        .then((value) {
      print("Kullanıcı bilgileri başarıyla güncellendi!");
    }).catchError((error) {
      print("Kullanıcı bilgilerini güncellerken bir hata oluştu: $error");
    });
  }

  void signOutGoogle(BuildContext context) async {
    try {
      await QuestionLogOut();
      try {
        await googleSignIn.signOut();
      } catch (e) {
        print(e);
      }

      _auth.signOut().whenComplete(() {
        //Hesap dan Çıkmadan Önce Tüm verileri temizler

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

      try {
        googleSignIn.signOut();
      } catch (e) {
        print(e);
      }

      // Kullanıcının Firestore verilerini sil
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user!.email)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          // Kullanıcıya ait belge bulunduğunda, bu belgeleri sil
          for (QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.docs) {
            await doc.reference.delete();
          }
        }
      });
      user.delete();
      // Hesap başarıyla silindiğinde kullanıcıyı çıkış yapmaya zorla
      await _auth.signOut().whenComplete(() {
        // Firebase Authentication üzerinde kullanıcıyı sil

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return GoogleLogin();
            },
          ),
        );
      });

      print("Hesap başarıyla silindi.");
    } catch (e) {
      print("Hesap silinirken bir hata oluştu: $e");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return GoogleLogin();
          },
        ),
      );
    }
  }
}

Future<void> saveRandomAnswer(String question, String answer) async {
  String email = _auth.currentUser!.email.toString();

  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection('users')
      .where('email', isEqualTo: email)
      .get();

  if (snapshot.docs.isNotEmpty) {
    // Eğer kullanıcı bulunduysa, yeni cevabı kaydet
    List<dynamic> answers = List.from(snapshot.docs.first.get('answers') ?? []);
    answers.add({
      'question': question,
      'answer': answer,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(snapshot.docs.first.id)
        .update({'answers': answers}).then((value) {
      print("Yeni cevap başarıyla kaydedildi!");
    }).catchError((error) {
      print("Yeni cevabı kaydederken bir hata oluştu: $error");
    });
  } else {
    print("Kullanıcı bulunamadı!");
  }
}

int set = 0;
int startingIndex = 0; // Başlangıç indeksi
bool randomQuestion = false, questionComplite = false;
int randomNumber = Random().nextInt(6);

class QuestionCardData {
  final String value;
  final String text;

  QuestionCardData(this.value, this.text);
}

class QuestionCard extends StatelessWidget {
  final Function(QuestionCardData) onPressed;

  QuestionCard({required this.onPressed});

//Sorular set ve startingIndex göre modüler olarak firebase den çekliyor.
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
                      hintText: 'Cevabınızı yazın.',
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
                      onPressed: () {
                        // Butona tıklandığında popup göster
                        saveRandomAnswer(data['question'], _controller.text);
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                  SizedBox(width: 10),
                                  Text("Bilgi"),
                                ],
                              ),
                              content: Text("Kaydınız alınmıştır."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    print(_controller.text);
                                    // Pop-up kapatıldığında uygulamadan çık
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                  },
                                  child: Text('Uygulamadan Ayrıl'),
                                ),
                              ],
                            );
                          },
                        );
                      },
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
                        "Cevapla",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (!randomQuestion)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: options.map(
                      (option) {
                        return SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              if (!randomQuestion) {
                                startingIndex += 1;
                                final data2 = QuestionCardData(
                                    option, data['question'].toString());
                                onPressed(data2);
                                if (startingIndex >= 3) {
                                  set += 1;
                                  startingIndex = 0;
                                  QuestionSetChange();
                                }
                              }
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
                      },
                    ).toList(),
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
    List<String> options = optionsString.split(
      "-",
    );
    // Boşlukları ve * işaretlerini kaldır
    for (var i = 0; i < options.length; i++) {
      options[i] = options[i].trim().replaceAll("*", "");
    }
    return options;
  }
}

QuestionSetChange() async {
  //Verileri localde kaydetmek için kullanılır
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // set value
  await prefs.setBool('Set1', true);
}

getSet() async {
  bool result = await _getQuestionSet();
  set = result == false ? 1 : 2;
}

Future<bool> _getQuestionSet() async {
  //Verileri localde çekmek için kullanılır
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print(prefs.getBool("Set1") == null ? false : prefs.getBool("Set1"));

  bool? result = prefs.getBool('Set1');

  // Eğer result null ise, varsayılan değeri belirleyin (örneğin false)
  bool value = result ?? false;

  return value;
}

QuestionLogOut() async {
  //Verileri hepsini localde silmek için kullanılır
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
