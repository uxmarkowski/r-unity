import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/event_list_page.dart';
import 'package:event_app/pages/global_variables.dart';
import 'package:event_app/pages/sign/sign_in.dart';
import 'package:event_app/pages/sign/sign_up.dart';
import 'package:event_app/pages/sign/sign_up_photo.dart';
import 'package:event_app/pages/user_page.dart';

import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:event_app/screens/card_form_screen.dart';
import 'package:event_app/screens/home_screen.dart';
import 'package:event_app/test_pdf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'blocs/payment/payment_bloc.dart';
import 'firebase_options.dart';


void TestFunc(){
  print("ss");
  Future.delayed(Duration(seconds: 10)).then((value) => print("ss"));
}


void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
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

class MyApp extends StatelessWidget {
  final statuss;

  MyApp({super.key,required this.statuss});


  bool OnlyOnce=false;
  // This widget is the root of your application.
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
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff002DE3),
            secondary: Color(0xff002DE3),
          ),
          primaryColor: Colors.white,
          appBarTheme: const AppBarTheme(elevation: 1),
        ),
        home: statuss==null ? WelcomePage() : EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: false, ),
        // home: PdfTest(),
      ),
    );
  }
}


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
      messagesRef.snapshots().listen((event) {
        if(_auth.currentUser!.phoneNumber==current_user){

          var chats_docs=event.docs.where((element) =>  (element.data()['sender']==current_user)||(element.data()['getter']==current_user));

          chats_docs.forEach((chat) {
            var messages=chat.data()['messages'];
            (messages as List).forEach((mess) {
              if(mess['statsus']=="sent"&&mess['user']!=current_user) {
                print(mess.toString());
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