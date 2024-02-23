import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/sign_up.dart';
import 'package:event_app/pages/sign/sign_verification.dart';
import 'package:event_app/widgets/voice_mes/user_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../functions/user_functions.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_route.dart';


class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController PhoneController=TextEditingController();
  FocusNode PhoneNode=FocusNode();

  bool wait_bool=false;

  Future<bool> CheckUserExist(phone) async{
    setState(() {wait_bool=true;});
    bool func_value=false;

    // print(phone);
    var users_collection=await firestore.collection("UsersCollection").get();
    await Future.forEach(users_collection.docs, (doc) {
      // print(doc.id);

      if(doc.id==phone){
        setState(() {wait_bool=false;});
        // UserMessage("")
        func_value=true;
      }
    });


    setState(() {wait_bool=false;});
    return func_value;
  }

  @override
  void initState() {
    PhoneController.text="1";
    // setState(() {
    //
    // });
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro(AppLocalizations.of(context)!.sign_in),
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
                  BigText(AppLocalizations.of(context)!.sign_in_with_phone),
                  // BigText("Sign in with phone"),
                  SizedBox(height: 8,),
                  Center(child: Text(AppLocalizations.of(context)!.please_enter_phone,textAlign: TextAlign.center,style: TextStyle(height: 1.4),)),
                  // Center(child: Text("Please enter your phone number",textAlign: TextAlign.center,style: TextStyle(height: 1.4),)),
                  SizedBox(height: 24,),
                  PhoneFormPro(PhoneController,PhoneNode,"Phone number"),
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 12),
                child: ButtonPro(
                    AppLocalizations.of(context)!.continuee,
                    // "Continue",
                        () async{
                  var user_exit=await CheckUserExist("+"+PhoneController.text);
                  if(user_exit){
                    print("User exist");
                    final page = SignVerificationPage(nomber: "+"+PhoneController.text,data: null,is_sign_in: true,);
                    Navigator.of(context).push(CustomPageRoute(page));
                  } else {
                    // UserMessage("User with this nomber don't exist", context);
                    NeedToRegisterAccount(context: context);

                    // final page = SignUpPage();
                    // Navigator.of(context).push(CustomPageRoute(page));
                  }

                },wait_bool),
              )
            ]
        ),
      ),
    );
  }
}
