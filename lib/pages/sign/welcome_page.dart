import 'package:event_app/pages/sign/sign_in.dart';
import 'package:event_app/pages/sign/sign_up.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_route.dart';


Color PrimaryCol=Color.fromRGBO(0, 45, 227, 1);

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("Welcome!"),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height-100,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 24,),
                  Image.asset("lib/assets/welcome_img.png"),
                ],
              ),
              Text("Find events that are interesting to you, chat with participants",style: TextStyle(fontSize: 24,color: Colors.black,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(0, 45, 227, 1),
                      minimumSize: const Size.fromHeight(52), // NEW
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                      onPressed: (){
                        final page = SignInPage();
                        Navigator.of(context).push(CustomPageRoute(page));
                      },
                      child: Text("Sign in",style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                  ),
                  SizedBox(height: 16,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Dont’t have an account?"),
                      SizedBox(width: 8,),
                      InkWell(
                        onTap: (){
                          final page = SignUpPage();
                          Navigator.of(context).push(CustomPageRoute(page));
                        },
                          child: Text("Sign up",style: TextStyle(fontWeight: FontWeight.w600,color: PrimaryCol),)
                      ),
                    ],
                  ),
                  SizedBox(height: 24,),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
