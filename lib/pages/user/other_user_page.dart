import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/add_event_page.dart';
import 'package:event_app/pages/user/edit_user_page.dart';
import 'package:event_app/pages/events/event_list_page.dart';
import 'package:event_app/pages/user/notification_page.dart';
import 'package:event_app/pages/sign/sign_in.dart';
import 'package:event_app/pages/sign/sign_up_photo.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../functions/hive_model.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_route.dart';
import '../chat/chat_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class OtherUserPage extends StatefulWidget {
  final user_doc;
  const OtherUserPage({Key? key,required this.user_doc}) : super(key: key);

  @override
  State<OtherUserPage> createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var model = hive_example();

  
  bool RequestSended=false;
  bool RequestAccepted=false;
  bool russian_language=false;

  List UserNotify=[];
  List MyRequset=[];
  List Events=[];
  List EventDocsData=[];

  
  String Phone="";
  String NickName="";
  String ChatDoc="";
  String AppBar="";
  String Instagram="";

  bool friend_exist=false;
  bool request_exist=false;
  bool wait_bool=false;
  bool delete_friend_wait_bool=false;
  bool allow_events_for_all=false;


  Map EnglMonths={1:"January", 2:"February", 3:"March", 4:"April", 5:"May", 6:"June", 6:"Jule", 8:"August", 9:"September", 10:"October", 11:"November", 12:"December",};
  Map RusMonths={1:"января", 2:"феварля", 3:"марта", 4:"апреля", 5:"мая", 6:"июня", 6:"июля", 8:"августа", 9:"сентября", 10:"октября", 11:"ноября", 12:"декабря",};
  Map RusDays={"Monday":"Понедельник", "Tuesday":"Вторник", "Wednesday":"Среда", "Thursday":"Четверг", "Friday":"Пятница", "Saturday":"Суббота", "Sunday":"Воскресенье"};


  void getData() async{
    setState(() {
      EventDocsData=[];
      EventDocsData.clear();
      friend_exist=false;
      request_exist=false;
      wait_bool=false;
      delete_friend_wait_bool=false;
      allow_events_for_all=false;
    });

    var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var data=await firestore.collection("UsersCollection").doc(widget.user_doc).get();

    setState(() {
      AppBar=data.data()!['nickname'];
      Phone=data.data()!['phone'];
      NickName=data.data()!['firstname']+" "+data.data()!['lastname'];
      allow_events_for_all=(data.data() as Map).containsKey("show_events_for_friends_only") ? !data.data()!['show_events_for_friends_only'] : false;
      Instagram=(data.data() as Map).containsKey("instagram") ? data.data()!['instagram'] : "";
    });

    var OrgEventsCollection=await firestore.collection("UsersCollection").doc(widget.user_doc).collection("OrganizerEvents").get();
    var EventsCollection=await firestore.collection("UsersCollection").doc(widget.user_doc).collection("Events").get();

    // print(OrgEventsCollection.docs.length);
    // print(EventsCollection.docs.length);
    await Future.forEach(OrgEventsCollection.docs, (EventDoc) async{
      if(EventDoc.data()!=null) {
        var data=await firestore.collection("Events").doc(EventDoc.id).get();
        if(data.data()!=null){
          var NewData=data.data() as Map; NewData['doc_id']=EventDoc.id;
          Events.add(NewData);
        }
      }

    });

    await Future.forEach(EventsCollection.docs, (EventDoc) async{
      if(EventDoc.data()!=null){
        var data=await firestore.collection("Events").doc(EventDoc.id).get();
        if(data.data()!=null) {
          var NewData=data.data() as Map; NewData['doc_id']=EventDoc.id;
          Events.add(NewData);
        }
      }

    });
    setState(() {delete_friend_wait_bool=false;});

  }

  bool IsDateCurrent(Date){
    return DateTime.now().compareTo(DateTime.fromMillisecondsSinceEpoch(Date))==-1;
  }

  void IsFriendExist() async{
    // print("check");
    var MyFriendsCollections=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Friends").get();
    var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();

    var MyFriendDocs=MyFriendsCollections.docs;
    var MyFriendRequest=my_data.data()!['friends_requests'];
    // friend_exist=(MyFriendDoc as List).contains(widget.user_doc);


    await Future.forEach(MyFriendDocs, (friends) async{
      if(friends.id==widget.user_doc){
        friend_exist=true;

        // print("friend_exist "+friend_exist.toString());
        ChatDoc=(friends.data() as Map)!['chat'];
      }
    });

    await Future.forEach(MyFriendRequest, (friends) async{
      if((friends as Map)!['user_id']==widget.user_doc){
        request_exist=true;
      }
    });

  }


  void SendFriendRequst() async{
    var MyData=await firestore.collection("UsersCollection").doc(_auth.currentUser?.phoneNumber.toString()).get();

    MyRequset.add({
      "user_id":widget.user_doc,
      "status":"wait",
      "date":DateTime.now().millisecondsSinceEpoch,
    });

    await firestore.collection("UsersCollection").doc(widget.user_doc).collection("Notifications").add({
      "title":MyData.data()!['nickname'].toString()+" sent you a friend request",
      "title_rus":MyData.data()!['nickname'].toString()+" отправил вам заявку в друзья",
      "photo_link":MyData.data()!['avatar_link'],
      "type":"friends_request",
      "check":false,
      "user_id":_auth.currentUser!.phoneNumber,
      "date":DateTime.now().millisecondsSinceEpoch,
    });

    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
      "friends_requests":MyRequset
    });



    setState(() { request_exist=true; wait_bool=false; });
  }

  void ToChat(){
    final page = ChatPage(appbar: NickName,doc_id: ChatDoc, phone: widget.user_doc,);
    Navigator.of(context).push(CustomPageRoute(page));
  }


  void ChatButton() async{
    setState(() {wait_bool=true;});

    if(!request_exist){
      if(!friend_exist){
        SendFriendRequst();
      } else {
        setState(() {wait_bool=false;});
        ToChat();
      }
    } else {
      if(friend_exist){
        setState(() {wait_bool=false;});
        ToChat();
      }
    }

  }

  DeleteFriend() async{
    setState(() {delete_friend_wait_bool=true;});

    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Friends").doc(widget.user_doc.toString()).delete();
    await firestore.collection("UsersCollection").doc(widget.user_doc.toString()).collection("Friends").doc(_auth.currentUser!.phoneNumber).delete();

    getData();
  }

  @override
  void initState() {

    getData();
    IsFriendExist();
    GetLanguage();

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarOtherUser(title: AppBar,instagram: Instagram),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4,),
                ProfileAvatarSquare(widget.user_doc),
                SizedBox(height: 16,),
                if(NickName.length!=0) ...[
                  BigText(NickName),
                  SizedBox(height: 24,),
                  ButtonPro(!friend_exist ? request_exist ? AppLocalizations.of(context)!.requested : AppLocalizations.of(context)!.add_friend : AppLocalizations.of(context)!.chat,ChatButton, wait_bool,),
                  if(friend_exist) SizedBox(height: 12,),
                  if(friend_exist) ButtonProOutLine(AppLocalizations.of(context)!.delete_friend,DeleteFriend ,delete_friend_wait_bool,),
                ] else ...[
                  SizedBox(height: 24,),
                  Center(child: CupertinoActivityIndicator(color: Colors.black,radius: 16,))
                ],
                SizedBox(height: 24,),
                if(allow_events_for_all||friend_exist) ListView.separated(
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  itemCount: Events.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index) {
                    var DateEpoch=DateTime.fromMillisecondsSinceEpoch(Events[index]['date']);
                    var DateName=DateFormat('EEEE').format(DateEpoch);
                    var DateNameMonth=DateFormat('MMMM').format(DateEpoch);

                    Widget DayWidget(){
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16,),
                          if(DateEpoch.day==DateTime.now().day) ...[
                            Text(AppLocalizations.of(context)!.today,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black54),),
                            // Text("Today",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black54),),
                          ] else ...[

                            Text((russian_language ? RusDays[DateName.toString()] : DateName.toString())+" "+DateEpoch.day.toString()+" "+( russian_language ? RusMonths[DateEpoch.month] : EnglMonths[DateEpoch.month]),style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.w600),),
                          ],

                          SizedBox(height: 16,),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(index!=0&&DateEpoch.day!=DateTime.fromMillisecondsSinceEpoch(Events[index-1]['date']).day) DayWidget(),
                        if(index==0) DayWidget(),
                        EventCard(context: context,data: Events[index],getData: (){ },russian_language: russian_language),
                      ],
                    );
                  },
                  separatorBuilder: (context,index) {
                    return Divider(height: 16,color: Color.fromRGBO(0, 0, 0, 0),);
                  },

                ),
                // ButtonPro(RequestAccepted ? "Chat with user" : !RequestSended ? "Send chat request" : "Wait for accept the request",ChatButton, false)
              ]
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBarPro(context,2),
    );
  }

  void GetLanguage() async{
    var lang = await model.GetLanguage();
    setState(() { russian_language=lang=="ru"; });
  }
}
