class UserFirebase {
  final String email;
  final String username;
  final DateTime birthDate;
  final String location;

  UserFirebase({
    required this.email,
    required this.username,
    required this.birthDate,
    required this.location,
  });

  // Firestore'a veriyi dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'birthDate': birthDate,
      'location': location,
    };
  }
}
