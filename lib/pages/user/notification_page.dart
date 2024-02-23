import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/event_page.dart';
import 'package:event_app/widgets/voice_mes/user_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_route.dart';
import '../global_variables.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool RussianLanguage=false;

  List Notifications=[];
  List Friends=[];
  Map<String,dynamic> MyData=Map();
  

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void GetLanguage() async{
    print("Local "+AppLocalizations.of(context)!.localeName);
    setState(() {RussianLanguage=AppLocalizations.of(context)!.localeName=="ru";});

  }

  void GetNotifications() async{
    GetLanguage();
    Notifications=[];
    var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Notifications").get();
    var FriendsCollections=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Friends").get();
    var MyData=my_data.docs;
    MyData.forEach((element) {
      var data=element.data();
      data['id']=element.id;
      Notifications.add(data);
      if(element.data()['check']==false){
        firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Notifications").doc(element.id).update({"check":true});
      }
    });
    // print(Notifications.toString());

    await Future.forEach(FriendsCollections.docs, (friend_doc) => Friends.add(friend_doc.id));
    Notifications.sort((a,b){
      return DateTime.fromMillisecondsSinceEpoch(b["date"]).compareTo(DateTime.fromMillisecondsSinceEpoch(a["date"]));
    });

    setState(() {});
  }

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 10)).then((value) => GetNotifications());
  }

  NotificationTapp(type,user_id,doc_id){
    bool friend_exist=false;


    if(type=="friends_request"){
      Friends.length!=0 ? Friends.forEach((element) {
        if(element==user_id){
          friend_exist=true;
        }
      }) : null;
      !friend_exist ? FriendsRequest(user_id) : null;
    }

    if(type=="organizer_invite") EventRequest(doc_id);

    if(type=="friend_invite_to_event") GoToEventWhenIInvited(doc_id);

  }

  void GoToEventWhenIInvited(doc_id) async{
    var event_doc = await firestore.collection("Events").doc(doc_id).get();
    var event_data=event_doc.data();

    event_data!['doc_id']=doc_id;

    final page = EventPage(data: event_data);
    Navigator.of(context).push(CustomPageRoute(page));
  }

  void ScaffoldMessa(message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
    ));
  }

  void FriendsRequest(user_doc) async{
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.friends_request),
        // title: Text("Friends request"),
        content: Text(AppLocalizations.of(context)!.after_accepting_the_request),
        // content: Text("After accepting the request, this user will be in your friend list"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.accept),
            // child: Text("Accept"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if(result) {
      bool chat_exist=false;
      var user_chat_doc="";
      var chats=await firestore.collection("Chats").get();
      await Future.forEach(chats.docs, (doc) {
        if((doc.data()['sender']==user_doc&&doc.data()['getter']==_auth.currentUser!.phoneNumber)||(doc.data()['sender']==_auth.currentUser!.phoneNumber&&doc.data()['getter']==user_doc)){
          chat_exist=true;
          user_chat_doc=doc.id;
        };
      });

      if(chat_exist){
        await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Friends").doc(user_doc).set({
          "phone":user_doc,
          "chat":user_chat_doc,
        });

        await firestore.collection("UsersCollection").doc(user_doc).collection("Friends").doc(_auth.currentUser!.phoneNumber).set({
          "phone":_auth.currentUser!.phoneNumber,
          "chat":user_chat_doc,
        });

        UserMessage(AppLocalizations.of(context)!.friend_added, context);
        GetNotifications();
      } else {
        firestore.collection("Chats").add({
          "eventchat":false,
          "sender":_auth.currentUser!.phoneNumber,
          "getter":user_doc,
          "messages":[],
        }).then((doc) async{

          await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Friends").doc(user_doc).set({
            "phone":user_doc,
            "chat":doc.id,
          });

          await firestore.collection("UsersCollection").doc(user_doc).collection("Friends").doc(_auth.currentUser!.phoneNumber).set({
            "phone":_auth.currentUser!.phoneNumber,
            "chat":doc.id,
          });

          UserMessage(AppLocalizations.of(context)!.friend_added, context);
          // UserMessage("Friend added", context);

          GetNotifications();
        });
      }


    }
  }

  void EventRequest(doc_id) async{
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.invitation_to_become_an_organizer),
        // title: Text("Invitation to become an organizer"),
        content: Text(AppLocalizations.of(context)!.you_have_been_invited_to_become_another_organizer),
        // content: Text("You have been invited to become another organizer"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            // child: Text("Cancel"),

            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.accept),
            // child: Text("Accept"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if(result) {
      var event_doc = await firestore.collection("Events").doc(doc_id).get();
      var event_data=event_doc.data();

      await firestore.collection("Events").doc(doc_id).collection("Organizers").doc(_auth.currentUser!.phoneNumber).set({
        "active":true
      });


      event_data!['doc_id']=doc_id;
      final page = EventPage(data: event_data);
      Navigator.of(context).push(CustomPageRoute(page));

    } else {

      // await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
      //   "notifications"
      // });
    }
  }

  // deleteNotification(){}


  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      final globalProvider = Provider.of<GlobalProvider>(context,listen: false);
      globalProvider.updateNotifcations(0);
    });

    return Scaffold(
      appBar: AppBarPro(AppLocalizations.of(context)!.notifications),
      // appBar: AppBarPro("Notifications"),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: ListView.separated(
                      padding: EdgeInsets.only(top: 24),
                      shrinkWrap: true,
                      itemCount: Notifications.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index) {
                        final item=Notifications[index]["title"].toString();

                        return Dismissible(
                          key: Key(item),
                          onDismissed: (value) {
                            var NotId=Notifications[index]["id"];
                            Notifications.removeAt(index);
                            firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Notifications").doc(NotId).delete();
                          },
                          child: NotificationCard(RussianLanguage&&(Notifications[index] as Map).containsKey("title_rus") ? Notifications[index]["title_rus"] : Notifications[index]["title"],Notifications[index]["check"],Notifications[index]["photo_link"],(value){
                            NotificationTapp(Notifications[index]["type"],Notifications[index]["type"] == "organizer_invite" ? Notifications[index]["event_doc"] : Notifications[index]["user_id"],Notifications[index]["id"]);
                          }),
                        );
                      },
                      separatorBuilder: (context,index) {
                        return Divider(height: 32,color: Colors.black45,);
                      },

                  ),
                ),

              ]
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBarPro(context,2),
    );

  }
}
