// File ini berisi form untuk memasukan quotes.
// Dalam file ini terdapat widget yang mendukung
// Operasi input data text melalui widget TextFormField. 

import 'dart:async';

import 'package:flutter/material.dart';

import 'src/widgets.dart';

class Quotes extends StatefulWidget{
  const Quotes({super.key, required this.addMessage});

  final FutureOr<void> Function(String message) addMessage;

  @override
  State<StatefulWidget> createState() => _QuotesState();
}

class _QuotesState extends State<Quotes> {

// _formKey yang digunakan untuk mendeteksi error yang terjadi dalam form, dengan menggunakan "key" yang terdapat dalam form 
  final _formKey = GlobalKey<FormState>(debugLabel: '_QuotesState');

  // _controller digunakan untuk merekam dan mendengarkan inputan dari user dari field
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,

        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter a new quote',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quote';
                    
                  }
                  return null;
                }
              ),
            ),

            const SizedBox(width: 8,),
            StyledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await widget.addMessage(_controller.text);
                    _controller.clear();
                    print(_formKey);
                  }
                },
                child: Row(
                  children: const [
                    Icon(Icons.send),
                    SizedBox(width: 4),
                    Text('Send'),
                  ],
                ),
            )
          ],
        ),
      )
    );
  }
}