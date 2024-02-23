import 'package:event_app/pages/sign/sign_in.dart';
import 'package:event_app/pages/sign/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../functions/hive_model.dart';
import '../../main.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_route.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


Color PrimaryCol=Color.fromRGBO(93, 42, 233, 1);



class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  bool eng_language=true;
  var model = hive_example();

  @override
  void initState() {
    debugLocalization();
    // _loadAndPrintLocaleFile();
    Intl.defaultLocale;
    // TODO: implement initState
    super.initState();
  }

  void _loadAndPrintLocaleFile() async {
    String localeData = await rootBundle.loadString('lib/l10n/app_en_US.arb');
    print(localeData); // Вывод содержимого файла в консоль
  }

  void debugLocalization() {
    print(Intl.systemLocale.toString());
    print(Intl.defaultLocale.toString());
    print(Intl.getCurrentLocale().toString());

    print(Intl.message('find_events_that'));
    print(Intl.message('welcome'));
    // Другие ключи для отладки
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Text(AppLocalizations.of(context)!.welcome,style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black54),),
        centerTitle: true,
        actions: [
          Row(
            children: [
              InkWell(
                onTap: (){
                  MyApp.of(context)!.setLocale(Locale.fromSubtags(languageCode: "ru"));
                  model.SaveLanguage("ru");
                },
                child: Container(
                  height: 20,
                  width: 28,
                  decoration: BoxDecoration(
                    color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        opacity: 0.92,
                          image: AssetImage("lib/assets/Flag/RusFlag.png"),
                        fit: BoxFit.cover
                      )
                  ),
                ),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: (){
                  MyApp.of(context)!.setLocale(Locale.fromSubtags(languageCode: "en"));
                  model.SaveLanguage("en");
                },
                child: Container(
                  height: 20,
                  width: 28,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    // color: Colors.grey,
                    image: DecorationImage(
                      image: AssetImage("lib/assets/Flag/UsFlag.png")
                    )
                  ),
                ),
              ),
              SizedBox(width: 12,)
            ],
          )
        ],
      ),
      // appBar: AppBarPro("Welcome!"),
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
                  // SizedBox(height: 8,),
                  // InkWell(
                  //   splashColor: Color.fromRGBO(0, 0, 0, 0),
                  //   focusColor: Color.fromRGBO(0, 0, 0, 0),
                  //   hoverColor: Color.fromRGBO(0, 0, 0, 0),
                  //   highlightColor: Color.fromRGBO(0, 0, 0, 0),
                  //   onTap: (){
                  //     setState(() {
                  //       eng_language=!eng_language;
                  //     });
                  //   },
                  //   child: Container(
                  //     height: 48,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         // Icon(Icons.expand_more),
                  //         Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text("Language ",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black54),),
                  //           ],
                  //         ),
                  //         SizedBox(width: 4),
                  //         Container(
                  //             width: 20,height: 20,margin: EdgeInsets.only(bottom: 4),decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(24)),
                  //             child: Opacity(child: Image.asset("lib/assets/"+(eng_language ? "usa" : "russia")+".png",),opacity: 0.95,)
                  //         ),
                  //
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 36,),
                  Image.asset("lib/assets/welcome_img.png"),
                ],
              ),
              Column(
                children: [
                  Text(AppLocalizations.of(context)!.find_events_that,style: TextStyle(fontSize: 24,color: Colors.black,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                  // Text("Find events that are interesting to you, chat with participants",style: TextStyle(fontSize: 24,color: Colors.black,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                ],
              ),

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
                    child: Text(Intl.message(AppLocalizations.of(context)!.sign_in),style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                    // child: Text("Sign in",style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                  ),
                  SizedBox(height: 16,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.dont_have_account),
                      // Text("Dont’t have an account?"),
                      SizedBox(width: 8,),
                      InkWell(
                          onTap: (){
                            final page = SignUpPage();
                            Navigator.of(context).push(CustomPageRoute(page));
                          },
                          child: Text(AppLocalizations.of(context)!.sign_up.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: PrimaryCol),)
                          // child: Text("Sign up",style: TextStyle(fontWeight: FontWeight.w600,color: PrimaryCol),)
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

