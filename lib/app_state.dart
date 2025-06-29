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

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _quotesSubscription;
  List<QuotesMessage> _quotes = [];
  List<QuotesMessage> get quotes => _quotes;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        _quotesSubscription = FirebaseFirestore.instance
              .collection('quotes')
              .orderBy('timestamp', descending: true)
              .snapshots()
              .listen((snapshot) {
            _quotes = [];

            for(final document in snapshot.docs) {
              _quotes.add(
                QuotesMessage(
                  text: document.get('text') as String,
                  username: document.get('username') as String,
                ),
              );
            }
            notifyListeners();
        });

      } else {
        _loggedIn = false;
        _quotes = [];
        _quotesSubscription?.cancel();
      }
      notifyListeners();
    });
  }

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