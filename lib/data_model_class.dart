class UserFirebase {
  final String email;
  final String username;
  final String birthDate;
  final String location;
  final List<AnswerClass> answers; // Yeni alan: Sorular listesi

  UserFirebase({
    required this.email,
    required this.username,
    required this.birthDate,
    required this.location,
    required this.answers, // Kurucu metoda da ekle
  });

  // Firestore'a veriyi dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'birthDate': birthDate,
      'location': location,
      'answers': answers
          .map((soru) => soru.toMap())
          .toList(), // Soruları da dönüştürerek ekleyin
    };
  }
}

// Soru sınıfını tanımlayın
class AnswerClass {
  final String questionText;
  final String answer;

  AnswerClass({
    required this.questionText,
    required this.answer,
  });

  // Firestore'a veriyi dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'answer': answer,
    };
  }
}
