import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/sign_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/app_bar.dart';
import '../widgets/custom_route.dart';


class EditUserPage extends StatefulWidget {
  final appbar;
  const EditUserPage({Key? key,required this.appbar}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}


class _EditUserPageState extends State<EditUserPage> {

  TextEditingController NickNameController=TextEditingController();
  TextEditingController EmailController=TextEditingController();
  TextEditingController PhoneController=TextEditingController();
  TextEditingController AboutController=TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FocusNode NickNameNode=FocusNode();
  FocusNode EmailNode=FocusNode();
  FocusNode PhoneNode=FocusNode();
  FocusNode AboutNode=FocusNode();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro(widget.appbar),
      body: InkWell(
        onTap: (){
          PhoneNode.hasFocus ? PhoneNode.unfocus() : null;
          NickNameNode.hasFocus ? NickNameNode.unfocus() : null;
          EmailNode.hasFocus ? EmailNode.unfocus() : null;
          AboutNode.hasFocus ? AboutNode.unfocus() : null;
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height-100,
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16,),
                      FormPro(NickNameController,NickNameNode,"Nickname",16,true,""),
                      FormPro(EmailController,EmailNode,"Email",16,true,""),
                      FormPro(AboutController,AboutNode,"About",24,true,""),
                    ],
                  ),
                  ButtonPro("Save",() async{
                    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
                      "nickname": NickNameController.text,
                      "email": EmailController.text,
                      "about": AboutController.text,
                    });
                    Navigator.pop(context);
                  },false)
                ]
            ),
          ),
        ),
      ),
    );
  }
}