// Implementasi layouting dalam file ini terinsipirasi dari codelab
// https://codelabs.developers.google.com/codelabs/flutter-codelab-first#0

// Class ini mengimplementasikan NavigationRail untuk pengalamatan 3 Page utama dalam aplikasi
// 



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'src/authentication.dart';
import 'app_state.dart';
import 'quote.dart';
import 'quotes_message.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    // Logika pengaturan pengalamatan halaman dalam apliaksi
    Widget ?page;
    switch (selectedIndex) {
      case 0 :

        // Seperti yang disebutkan dalam class ApplicationState, setiap 
        // State login / belum login akan didengarkan di seluruh aplikasi.
        // Salah satu contoh implementasinya adalah 1 baris dibawah ini :
        if (context.watch<ApplicationState>().loggedIn) {
          page = ListQuotes(quotes: context.watch<ApplicationState>().quotes);
        } else {
        page = LoginPage();
        }

        break;
      case 1 :
        if (context.watch<ApplicationState>().loggedIn) {
          page = AddingQuotes();
        } else {
          page = LoginPage();
        }
        break;
      case 2 :
        page = LoginPage();
        break;
        default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(

      // Mengatur agar halaman utama dibagi menjadi dua bagian,
      // Sebelah kiri untuk  NavigationRail, dan menentukan areanya dengan safe area.
        builder: (context, constraints) {
          return Scaffold(
          body: Row(
          children: [
            SafeArea(
                child: NavigationRail(
                    destinations: [
                      NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                      ),
                      NavigationRailDestination(
                          icon: Icon(Icons.format_quote),
                          label: Text('Add quotes')
                      ),
                      NavigationRailDestination(
                          icon: Icon(Icons.logout),
                          label: Text('Logout')
                      ),

                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    }
                )
            ),
            Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                )
            )
          ],
         ),
        );
      }
    );
  }
}

// Widget // Halaman login, ini ditampilkan diseluruh aplikasi saat user belum login.

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(8.0),

                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset('assets/images/header.png'),
                ),
            ),

            const Divider(
              height: 8,
              thickness: 1,
              indent: 20),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => AuthFunc(
                  loggedIn: appState.loggedIn,
                  signOut: () {
                    FirebaseAuth.instance.signOut();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget yang akan menampilkan form untuk menambahkan quotes baru
class AddingQuotes extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 15, bottom: 8),
    child: Column(

      children: <Widget>[
        Padding(padding: EdgeInsets.all(8),
          child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Image.asset('assets/images/header.png')
          ),
        ),
        const Divider(
          height: 8,
          thickness: 1,
          indent: 20,
          endIndent: 20,
          color: Colors.deepPurple,
        ),

        // Mengatur agar widget tidak overflow 
        SingleChildScrollView(
          child:  Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loggedIn) ...[
                  Quotes(
                    addMessage: (message) =>
                        appState.addQuotes(message),
                  ),
                ]
              ],
            ),
          ),
        ),

      ],
     ),
    );
  }
}

// Widget yang akan menampilkan daftar quotes
class ListQuotes extends StatelessWidget {
  const ListQuotes({
    super.key,
    required this.quotes,
  });

  final List<QuotesMessage> quotes;

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (var quote in quotes)

        // Membungkus setiap quotes dengan card, 
          Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: ListTile(
              title: Text(quote.text, style: TextStyle(),),
              subtitle: Text('- ${quote.username}'),
            ),
          )
      ],
    ),
   );
  }
}