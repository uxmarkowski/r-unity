import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/l10n/l10n.dart';
import 'package:event_app/pages/events/event_list_page.dart';
import 'package:event_app/pages/global_variables.dart';
import 'package:event_app/pages/sign/sign_in.dart';
import 'package:event_app/pages/sign/sign_up.dart';
import 'package:event_app/pages/sign/sign_up_photo.dart';
import 'package:event_app/pages/user/change_number.dart';
import 'package:event_app/pages/user/user_page.dart';

import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:event_app/screens/card_form_screen.dart';
import 'package:event_app/screens/home_screen.dart';
import 'package:event_app/test_pdf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'blocs/payment/payment_bloc.dart';
import 'firebase_options.dart';
import 'functions/hive_model.dart';


void TestFunc(){
  print("ss");
  Future.delayed(Duration(seconds: 10)).then((value) => print("ss"));
}


void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);
  Stripe.publishableKey="pk_test_51O9GRSLy45iyimM2gujSUlZoWEizSkMSZ6U5MWPzQkX3vb7aQEV2sZ7piRxlVd7dPz5s2lhUVxNQGONJUpgGFFh200ycuppluD";
  await Stripe.instance.applySettings();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);


  var UserStatus=await FirebaseAuth.instance.currentUser;
  runApp(
      ChangeNotifierProvider(
        create: (context) => GlobalProvider(),
        child: MyApp(statuss: UserStatus,),
      )
  );

}


class MyApp extends StatefulWidget {
  final statuss;
  MyApp({Key? key,required this.statuss}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool OnlyOnce=false;
  Locale _locale=Locale.fromSubtags(languageCode: "en");
  var model = hive_example();

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  getLanguage() async{
    var loc=await model.GetLanguage();
    _locale=Locale.fromSubtags(languageCode: loc);
    setState(() {

    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500)).then((value) => getLanguage());
  }

  @override
  Widget build(BuildContext context) {

    if(OnlyOnce==false){
      FirebaseWebSocketNotify(true, context);
      OnlyOnce=true;
    }


    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PaymentBloc(),
        ),
      ],
      child: MaterialApp(
        locale: _locale,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: L10n.all,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff002DE3),
            secondary: Color(0xff002DE3),
          ),
          primaryColor: Colors.white,
          appBarTheme: const AppBarTheme(elevation: 1),
        ),
        home: widget.statuss==null ? WelcomePage() : EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: false, ),
        // home: ChangeNumberPage(),
      ),
    );
  }
}


// class MyApp extends StatelessWidget {
//   final statuss;
//   MyApp({super.key,required this.statuss});
//
//
//
//   bool OnlyOnce=false;
//   @override
//   Widget build(BuildContext context) {
//
//     if(OnlyOnce==false){
//       FirebaseWebSocketNotify(true, context);
//       OnlyOnce=true;
//     }
//
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => PaymentBloc(),
//         ),
//       ],
//       child: MaterialApp(
//         localizationsDelegates: [
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//           AppLocalizations.delegate,
//         ],
//         supportedLocales: L10n.all,
//         theme: ThemeData(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xff002DE3),
//             secondary: Color(0xff002DE3),
//           ),
//           primaryColor: Colors.white,
//           appBarTheme: const AppBarTheme(elevation: 1),
//         ),
//         home: statuss==null ? WelcomePage() : EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: false, ),
//         // home: SignUpPhotoPage(nomber: "7989897777", type: null,),
//       ),
//     );
//   }
// }




FirebaseWebSocketNotify(Switch,context){
  final globalProvider = Provider.of<GlobalProvider>(context);
  bool OnlyOnce=false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  if(_auth.currentUser!=null){
      var current_user=_auth.currentUser!.phoneNumber;
      final notifyRef = firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Notifications");
      final messagesRef = firestore.collection("Chats");

      if(Switch) { print("Слушаем стрим уведомлений ");
      notifyRef.snapshots().listen((event) {
          if(_auth.currentUser!.phoneNumber==current_user){

            var unreader_notify=event.docs.where((element) =>  element.data()['check']==false).length;
            globalProvider.updateNotifcations(unreader_notify);

            var EventData=event.docs;
            EventData.sort((a,b){
              // Выбор последнего уведомления
              return DateTime.fromMillisecondsSinceEpoch(b.data()['date']).compareTo(DateTime.fromMillisecondsSinceEpoch(a.data()['date']));});
            print(EventData.first.data()['title']);
          }
        },
        onError: (error) {print("Listen failed: $error");},
      );

    }


      if(Switch) { print("Слушаем стрим чатов ");
      messagesRef.snapshots().listen((event) async{
        if(_auth.currentUser!.phoneNumber==current_user){

          var chats_docs=event.docs.where((element) =>  (element.data()['sender']==current_user)||(element.data()['getter']==current_user));

          await Future.forEach(chats_docs, (chat) async{


            var messages=await firestore.collection("Chats").doc(chat.id).collection("Messages").get();
            await Future.forEach(messages.docs, (mess) {
              if(mess.data()['status']=="sent"&&mess.data()['user']!=current_user) {
                print("mess "+mess.data().toString());
                globalProvider.updateUncheckMessages(1);
              }
            });
          });
        }
      },
        onError: (error) {print("Listen failed: $error");},
      );

      }
  }
}