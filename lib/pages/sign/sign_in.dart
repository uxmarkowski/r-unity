import 'package:event_app/pages/sign/sign_up.dart';
import 'package:event_app/pages/sign/sign_verification.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/custom_route.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  TextEditingController PhoneController=TextEditingController();
  FocusNode PhoneNode=FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("Sign in"),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height-100,
        padding: EdgeInsets.all(24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 56,),
                  BigText("Sign up with phone"),
                  SizedBox(height: 8,),
                  Center(child: Text("Please enter your phone number",textAlign: TextAlign.center,style: TextStyle(height: 1.4),)),
                  SizedBox(height: 24,),
                  PhoneFormPro(PhoneController,PhoneNode,"Phone number"),
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 12),
                child: ButtonPro("Continue",(){
                  final page = SignVerificationPage(nomber: "+"+PhoneController.text,data: null,is_sign_in: true,);
                  Navigator.of(context).push(CustomPageRoute(page));
                },false),
              )
            ]
        ),
      ),
    );
  }
}
