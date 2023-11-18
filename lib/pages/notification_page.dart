import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/event_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_route.dart';
import 'global_variables.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  List Notifications=[];
  List Friends=[];
  Map<String,dynamic> MyData=Map();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void GetNotifications() async{
    Notifications=[];
    var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Notifications").get();
    var my_data_friends=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
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



    Friends=my_data_friends.data()!['friends'];

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
        if(element['phone']==user_id){
          friend_exist=true;
        }
      }) : null;
      !friend_exist ? FriendsRequest(user_id) : null;
    }
    if(type=="organizer_invite"){
      // Friends.length!=0 ? Friends.forEach((element) {
      //   if(element['phone']==user_id){
      //     friend_exist=true;
      //   }
      // }) : null;
      // !friend_exist ? FriendsRequest(user_id) : null;
      EventRequest(user_id);
      // Поправить
    }

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
        title: Text("Friends request"),
        content: Text("After accepting the request, this user will be in your friend list"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Cancel"),

            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text("Accept"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if(result) {

      firestore.collection("Chats").add({
        "eventchat":false,
        "sender":_auth.currentUser!.phoneNumber,
        "getter":user_doc,
        "messages":[],
      }).then((doc) async{

        var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
        var user_data=await firestore.collection("UsersCollection").doc(user_doc).get();
        var my_friends=my_data.data()!['friends'] as List;
        var user_friends=user_data.data()!['friends'] as List;

        user_friends.add({
          "phone":_auth.currentUser!.phoneNumber,
          "chat":doc.id,
        });
        my_friends.add({
          "phone":user_doc,
          "chat":doc.id,
        });

        firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"friends":my_friends});
        firestore.collection("UsersCollection").doc(user_doc).update({"friends":user_friends});

        GetNotifications();
      });
    } else {

      // await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
      //   "notifications"
      // });
    }
  }

  void EventRequest(doc_id) async{
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Invitation to become an organizer"),
        content: Text("You have been invited to become another organizer"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Cancel"),

            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text("Accept"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if(result) {
      var event_doc = await firestore.collection("Events").doc(doc_id).get();
      var event_data=event_doc.data();
      var organizers=event_doc.data()!['organizers'] as List;
      if(!organizers.contains(_auth.currentUser!.phoneNumber)){
        organizers.add(_auth.currentUser!.phoneNumber);
        await firestore.collection("Events").doc(doc_id).update({
          "organizers":organizers
        });
      }


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
      appBar: AppBarPro("Notifications"),
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
                          child: NotificationCard(Notifications[index]["title"],Notifications[index]["check"],Notifications[index]["photo_link"],(value){
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
