import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/add_event_page.dart';
import 'package:event_app/pages/edit_user_page.dart';
import 'package:event_app/pages/events/event_list_page.dart';
import 'package:event_app/pages/notification_page.dart';
import 'package:event_app/pages/sign/sign_in.dart';
import 'package:event_app/pages/sign/sign_up_photo.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_route.dart';
import 'chat/chat_page.dart';



class OtherUserPage extends StatefulWidget {
  final user_doc;
  const OtherUserPage({Key? key,required this.user_doc}) : super(key: key);

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var NickName="";
  bool RequestSended=false;
  bool RequestAccepted=false;


  var UserNotify=[];
  var MyRequset=[];
  var Phone="";
  var ChatDoc="";
  bool friend_exist=false;
  bool request_exist=false;



  void getData() async{
    var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();

    var data=await firestore.collection("UsersCollection").doc(widget.user_doc).get();

    UserNotify=data.data()!['notifications'];
    MyRequset=my_data.data()!['chat_requests'];


    setState(() {
      NickName=data.data()!['nickname'];
      Phone=data.data()!['phone'];
    });
  }

  void CheckForRequest(List Requests){
    Requests.forEach((element) {
      if(element['phone']==widget.user_doc){

        setState(() {
          RequestSended=true;
        });
      }
    });
  }

  void IsFriendExist() async{
    // print("check");
    var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var MyFriendDoc=my_data.data()!['friends'];
    var MyFriendRequest=my_data.data()!['friends_requests'];
    // friend_exist=(MyFriendDoc as List).contains(widget.user_doc);


    await Future.forEach(MyFriendDoc, (friends) async{
      if((friends as Map)!['phone']==widget.user_doc){
        friend_exist=true;
        // print("friend_exist "+friend_exist.toString());
        ChatDoc=(friends as Map)!['chat'];
      }
    });

    await Future.forEach(MyFriendRequest, (friends) async{
      if((friends as Map)!['user_id']==widget.user_doc){
        request_exist=true;
      }
    });

  }

  // void SendRequst() async{
  //   var MyData=await firestore.collection("UsersCollection").doc(_auth.currentUser?.phoneNumber.toString()).get();
  //
  //   MyRequset.add({
  //     "phone":widget.user_doc,
  //     "status":"wait",
  //     "date":DateTime.now().millisecondsSinceEpoch,
  //   });
  //
  //   UserNotify.add({
  //     "title":MyData.data()!['nickaname']+" sent you a chat request",
  //     "type":"chat_request",
  //     "date":DateTime.now().millisecondsSinceEpoch,
  //   });
  //
  //   await firestore.collection("UsersCollection").doc(widget.user_doc).update({
  //     "notifications":MyRequset
  //   });
  //
  //   await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
  //     "chat_requests":UserNotify
  //   });
  //
  //
  //
  //   setState(() { RequestSended=true; });
  // }

  void SendFriendRequst() async{
    var MyData=await firestore.collection("UsersCollection").doc(_auth.currentUser?.phoneNumber.toString()).get();

    MyRequset.add({
      "user_id":widget.user_doc,
      "status":"wait",
      "date":DateTime.now().millisecondsSinceEpoch,
    });

    // UserNotify.add({
    //   "title":MyData.data()!['nickname'].toString()+" sent you a friend request",
    //   "photo":MyData.data()!['avatar_link'],
    //   "type":"friends_request",
    //   "check":false,
    //   "user_id":widget.user_doc,
    //   "date":DateTime.now().millisecondsSinceEpoch,
    // });

    await firestore.collection("UsersCollection").doc(widget.user_doc).collection("Notifications").add({
      "title":MyData.data()!['nickname'].toString()+" sent you a friend request",
      "photo_link":MyData.data()!['avatar_link'],
      "type":"friends_request",
      "check":false,
      "user_id":_auth.currentUser!.phoneNumber,
      "date":DateTime.now().millisecondsSinceEpoch,
    });

    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
      "friends_requests":MyRequset
    });



    setState(() { request_exist=true; });
  }

  void ToChat(){
    final page = ChatPage(appbar: NickName,doc_id: ChatDoc,);
    Navigator.of(context).push(CustomPageRoute(page));
  }

  // void ChatButton() async{
  //   if(!RequestSended){
  //     SendRequst();
  //   } else {
  //     RequestAccepted ? ToChat() : null;
  //   }
  // }

  void ChatButton() async{
    if(!request_exist){
      if(!friend_exist){
        SendFriendRequst();
      } else {
        ToChat();
      }
    } else {
      if(friend_exist){
        ToChat();
      }
    }

  }

  @override
  void initState() {
    getData();
    IsFriendExist();

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("User page"),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height-100,
        padding: EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 56,),
              Stack(
                children: [
                  Positioned(
                    child: ProfileAvatar(widget.user_doc),
                    top: 5,
                    left: 5,
                  ),
                  SvgPicture.asset("lib/assets/AddPhotoBackLine.svg",width: 110,),
                ],
              ),
              SizedBox(height: 24,),
              if(NickName.length!=0) ...[
                BigTextCenter(NickName),
                // SizedBox(height: 8),
                // Text(Phone,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 16),),
                SizedBox(height: 32,),
                ButtonPro(!friend_exist ? request_exist ? "Requested" : "Add friend" : "Chat",ChatButton, false)
              ] else ...[
                SizedBox(height: 24,),
                Center(child: CupertinoActivityIndicator(color: Colors.black,radius: 16,))
              ]

              // ButtonPro(RequestAccepted ? "Chat with user" : !RequestSended ? "Send chat request" : "Wait for accept the request",ChatButton, false)
            ]
        ),
      ),
      bottomNavigationBar: BottomNavBarPro(context,2),
    );
  }
}
