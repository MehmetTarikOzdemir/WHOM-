import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whomii/data_model_class.dart';

class UserInfoPage extends StatefulWidget {
  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _UserInfoPageState extends State<UserInfoPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _selectedLocation = 'Düzce';

  final List<String> _cities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Kullanıcı Bilgileri'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Merhaba, ${_auth.currentUser!.displayName.toString()}!',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            Text('Doğum Tarihi Seçin:'),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _selectDateTime,
              child: Text('Tarih Seç'),
            ),
            SizedBox(height: 20.0),
            Text('Yaşadığınız Lokasyon:'),
            SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              items: _cities.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue!;
                });
              },
              decoration: InputDecoration(
                hintText: 'Şehir Seçiniz',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: _saveUserInfo,
              child: Text('Bilgileri Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveUserInfo() async {
    UserFirebase user = UserFirebase(
        username: _auth.currentUser!.displayName.toString(),
        birthDate: _selectedDate.toString(),
        location: _selectedLocation,
        email: _auth.currentUser!.email.toString(),
        answers: []);

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: _auth.currentUser!.email.toString())
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Eğer e-posta adresiyle kayıtlı bir kullanıcı varsa, bu kullanıcıyı güncelle
      FirebaseFirestore.instance
          .collection('users')
          .doc(snapshot.docs.first.id)
          .update(user.toMap())
          .then((value) {
        print("Kullanıcı bilgileri başarıyla güncellendi!");
        Navigator.of(context).pop();
      }).catchError((error) {
        print("Kullanıcı bilgilerini güncellerken bir hata oluştu: $error");
      });
    }
  }
}
