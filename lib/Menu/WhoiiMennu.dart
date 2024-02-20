import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whomii/Login/GoogleLogin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class WhoiiMenu extends StatefulWidget {
  @override
  WhoiiMenuPage createState() => WhoiiMenuPage();
}

class QuestionService {
  final CollectionReference _questionsCollection =
      FirebaseFirestore.instance.collection('Questions');
  Future<List<Map<String, dynamic>>> getQuestions2() async {
    QuerySnapshot querySnapshot = await _questionsCollection.get();
    List<Map<String, dynamic>> questions = [];
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String,
          dynamic>; // Belge verilerini doğru veri yapısına dönüştürüyoruz
      if (data.containsKey('question')) {
        questions.add({
          'question': data['question'], // Alanı "question" olarak alıyoruz
        });
      }
    });
    return questions;
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    QuerySnapshot querySnapshot = await _questionsCollection.get();
    List<Map<String, dynamic>> questions = [];
    querySnapshot.docs.forEach((doc) {
      questions.add({
        'question': doc['question'],
        // Burada diğer belge alanlarını da ekleyebilirsiniz
      });
    });
    return questions;
  }
}

class WhoiiMenuPage extends State<WhoiiMenu> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    _questions = await QuestionService().getQuestions2();
    await QuestionService().getQuestions2();
    setState(() {});
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
                  " --",
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
              signOutGoogle(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _questions.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_questions[_currentQuestionIndex]['question']),
                      // Cevapları göstermek için gerekli widget'lar ekleyin
                      // Örneğin: ElevatedButton, RadioListTile, vs.
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        child: Text('Sonraki Soru'),
                      ),
                    ],
                  ),
            Text(
              'Sorular Burada Olacak',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  void signOutGoogle(BuildContext context) async {
    try {
      await googleSignIn.signOut();
      _auth.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return GoogleLogin();
          },
        ),
      );
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
}
