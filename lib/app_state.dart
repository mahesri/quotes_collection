import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:quotes_collection/quote.dart';
import 'package:quotes_collection/quotes_message.dart';

import 'firebase_options.dart';

// Class Aplication state menyimpan logic dari aplikasi, class ini mengatur bagaimana data disimpan ke collection firestore dan menyimpan current state 
// aplikasi, sehingga saat objek dari kelas ini diinstansiasi, objek tersebut menyimpan kondisi terkini dari aplikasi/ user, apakah user dalam kondisi login, atau log-out
// semua terekam dalam objek kelas ini. 

// Kelas ini mewarisi ChangeNotifier, ini memungkinkan segala pembaruan state dalam class ini, dapat terekam oleh provider sehingga memungkinkan
// Segala perubahan state terkini terdengar dan tersedia di widget tree, atau dalam artian segala perubahan yang terjadi dari class ini dapat didengar
// oleh seluruh aplikasi

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }


  // Instansiasi variable yang merepresentasikan login state diaplikasi
  bool _loggedIn = false;

  // Getter properties di dart / flutter (mungkin) Tapi satu garis dibawah ini adalah getter, untuk mengakses properti dari _loggedIn, 
  bool get loggedIn => _loggedIn;

  // Inisiasi laganan saluran ke firestore database
  StreamSubscription<QuerySnapshot>? _quotesSubscription;

  // Inisiasi variable list yang akan digunakan untuk menyimpan quotes
  List<QuotesMessage> _quotes = [];
  // Getter properties di dart / flutter (mungkin) Tapi satu garis dibawah ini adalah getter, untuk mengakses properti dari _quotes,
  List<QuotesMessage> get quotes => _quotes;


 // Instansiasi aplikasi firebase 
  Future<void> init() async {
    await Firebase.initializeApp(

      // Current platform adalah penyesuaian platform yang sudah ditentukan di firebase_option.dart, dalam file tersebut
      // terdapat konfigurasi dan definisi untuk platform yang sudah ditentukan, yang mana konfigurasi tersebut juga ditentukan dalam SDK didalam firebase
        options: DefaultFirebaseOptions.currentPlatform);


    // Instansiasi Email authentikasi yang terdapat dari package firebase_ui_auth untuk mendukung email/password autentikasi
    FirebaseUIAuth.configureProviders([

      // Instansiasi objek yang mendukung operasi sing-in dan sign-out.

      EmailAuthProvider(),
    ]);


    // listener yang mencatat current login state 
    FirebaseAuth.instance.userChanges().listen((user) {

      if (user != null) {
        _loggedIn = true;

        // variable _quotesSubscription seperti halnya menyimpan saluran langgannan, dimana langganan tersebebut
        // kepada database firestore firestore menyimpan berbagai collection, dan variable ini akan mendapatkan 
        // Update-an terbaru dari collection quotes, sehingga setiap kali data di collection bertambah, variable
        // _quotesSubscription akan diupdate.

        _quotesSubscription = FirebaseFirestore.instance
              .collection('quotes')
              .orderBy('timestamp', descending: true)
              .snapshots()
              .listen((snapshot) {

            // Inisiasi variable list yang akan digunakan untuk menyimpan quotes
            _quotes = [];

            for(final document in snapshot.docs) {
              _quotes.add(

                // QuotesMessage adalah class yang kita representasikan sebagai model, dan kita jadikan sebagai blueprint
                // atau bisa kita analogikan model tersebut memparsing data yang didapatkan dari snapshot dan di fetch
                // dimasukan didalam list _quotes.    
                   
                QuotesMessage(
                  text: document.get('text') as String,
                  username: document.get('username') as String,
                ),
              );
            }

            // Memberi tahu provider, apabila terdapat sebuah perubahan.
            notifyListeners();
        });

      } else {

        // Apabila user logout, maka _loggIn sebagai state yang merepresentasikan login/logout aplikasi
        // akan kita atur dengan false.


        _loggedIn = false;

        // Merefress variabel list _quotes menjadi 0 index.
        _quotes = [];

        // menghentikan subscription dari database firestore.
        _quotesSubscription?.cancel();
      }
      notifyListeners();
    });
  }


 // Fungsi untuk menambahkan quotes baru kedalam collection

 
  Future<DocumentReference> addQuotes(String message) {
  if (!_loggedIn) {
    throw Exception('Must be logged in');
  }

  return FirebaseFirestore.instance
      .collection('quotes')
      .add(<String, dynamic> {
        'text' : message,
        'timestamp' : DateTime.now().millisecondsSinceEpoch,
        'username' : FirebaseAuth.instance.currentUser!.displayName,
        'userId' : FirebaseAuth.instance.currentUser!.uid,
  });
  }
}