import 'package:flutter/material.dart';

import '../../pages/sign/welcome_page.dart';


void UserMessage(message,context){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: 3),
    backgroundColor: Colors.red,
  ));
}




void ScaffoldMessa(message,context){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: 3),
    backgroundColor: PrimaryCol,
  ));
}

void ScaffoldMessaLong(message,context){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: 6),
    backgroundColor: PrimaryCol,
  ));
}