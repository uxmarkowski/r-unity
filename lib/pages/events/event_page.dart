import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/add_event_page.dart';
import 'package:event_app/pages/chat/chat_page.dart';
import 'package:event_app/pages/events/add_user_manualy.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:event_app/widgets/app_bar.dart';
import 'package:event_app/widgets/bottom_nav_bar.dart';
import 'package:event_app/widgets/voice_mes/user_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GM;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import '../../functions/hive_model.dart';
import '../../screens/card_form_screen.dart';
import '../../widgets/custom_route.dart';
import '../../functions/event_page_functions.dart';
import '../user/friends_page.dart';



class EventPage extends StatefulWidget {
  final data;
  const EventPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  int? groupValue = 0;
  int FinalGroupValue = 0;
  int peoples_length=0;
  int after_discount_price_percent=100;



  var my_nickname="";
  var RussianLanguage=false;
  var model = hive_example();
  var EventData=Map();


  var EventUsersListManual=[]; var EventUsersList=[]; var EventUsersWaitList=[]; var EventUsersInviteList=[]; var EventOrganizerList=[]; var EventOrganizerListData=[]; var EventUsersListData=[]; var MessageList=[];

  bool IsUserIn=false;
  bool IAmOrganizer=false;
  bool IAmAdmin=false;
  bool IAmInWaitList=false;
  bool IAmInvited=false;
  bool show_buttons=false;
  bool join_wait_bool=false;
  bool add_friend_wait_bool=false;
  bool russian_language=false;

  TextEditingController MessageController = TextEditingController();
  FocusNode MessageNode = FocusNode();
  late StreamSubscription stream;
  late StreamSubscription event_data_stream;

  var RightPromoCode="";


  void SendMessage(Message) async{firestore.collection("Events").doc(widget.data['doc_id']).collection("Messages").add(Message);}


  void GetAllMessage() async{
    MessageList=[];

    var MessagesCollection=await firestore.collection("Events").doc(widget.data['doc_id']).collection("Messages").get();
    print("Получаем сообщения "+widget.data['doc_id'].toString());
    await Future.forEach(MessagesCollection.docs, (message) => MessageList.add(message.data()));
    // MessageList=messages.data()!['messages'] as List;
    MessageList.sort((a,b){
      return DateTime.fromMillisecondsSinceEpoch(a["time"]).compareTo(DateTime.fromMillisecondsSinceEpoch(b["time"]));
    });
    setState(() { });
    // UpDateMessage(messages);
  }


  void GetEventUsersCollection() async{
    EventUsersListData=[]; EventOrganizerList=[]; EventOrganizerListData=[]; EventUsersList=[]; EventUsersListManual=[]; EventUsersWaitList=[]; var EventUsersInviteList=[];
    
    var Mydata=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get(); if(Mydata["admin"]){setState(() {IAmAdmin=true;});} setState(() {my_nickname=Mydata["nickname"];});
    var EventDoc=await firestore.collection("Events").doc(widget.data['doc_id']).get();
    setState(() {peoples_length=EventDoc.data()!['peoples']; });
    var UsersCollection=await firestore.collection("Events").doc(widget.data['doc_id']).collection("Users").get();
    var PromoUserCollection=await firestore.collection("Events").doc(widget.data['doc_id']).collection("PromoUsers").get();
    var UsersWaitListCollection=await firestore.collection("Events").doc(widget.data['doc_id']).collection("WaitList").get();
    var UsersInvitedUsersCollection=await firestore.collection("Events").doc(widget.data['doc_id']).collection("InvitedUsers").get();
    var UsersOrganizersCollection=await firestore.collection("Events").doc(widget.data['doc_id']).collection("Organizers").get();

    
    await Future.forEach(UsersCollection.docs, (UserDoc) {UserDoc.data()['active'] ? EventUsersList.add(UserDoc.id) : EventUsersListManual.add(UserDoc.data());  });
    await Future.forEach(UsersOrganizersCollection.docs, (UserDoc) {  EventOrganizerList.add(UserDoc.id);  });
    await Future.forEach(UsersInvitedUsersCollection.docs, (UserDoc) {  EventUsersInviteList.add(UserDoc.id);  });
    await Future.forEach(UsersWaitListCollection.docs, (UserDoc) {  EventUsersWaitList.add(UserDoc.id);  });

    await Future.forEach(EventUsersInviteList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IAmInvited=true;});} // Проверка себя на наличие в инвайтлисте
    });

    await Future.forEach(EventUsersWaitList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IAmInWaitList=true;});} // Проверка себя на наличие в вейтлисте
      var data=await firestore.collection("UsersCollection").doc(element).get(); var userdata=data.data();
      userdata!["role"]=-1; userdata!["doc_id"]=data.id;
      EventUsersListData.add(userdata);
    });

    await Future.forEach(EventOrganizerList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IAmOrganizer=true;});} // Проверка организатора на наличие в мероприятии
      var data=await firestore.collection("UsersCollection").doc(element).get(); var userdata=data.data();
      userdata!["role"]=1; userdata!["doc_id"]=data.id;
      EventUsersListData.add(userdata);
      EventOrganizerListData.add(userdata);
    });

    await Future.forEach(EventUsersList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IsUserIn=true;});} // Проверка юзера на наличие в мероприятии
      var data=await firestore.collection("UsersCollection").doc(element).get(); var userdata=data.data();
      userdata!["role"]=0; userdata!["doc_id"]=data.id;
      (EventUsersListData.any((user) => user['phone']==element))  ?  null : EventUsersListData.add(userdata);
    });

    await Future.forEach(EventUsersListManual, (element) async{
      var userdata=element;
      userdata!["role"]=-2;
      (EventUsersListData.any((user) => user['phone']==element))  ?  null : EventUsersListData.add(userdata);
    });


    EventUsersListData.sort((a,b){
      if(a['role']>b['role']) return -1;
      return 1;
    });

    setState(() {show_buttons=true;join_wait_bool=false;add_friend_wait_bool=false;});
  }

  void JoinButtonCollectionsEdition(UserIn,user_id) async{


    setState(() {join_wait_bool=true;add_friend_wait_bool=false;});
    bool its_me=user_id==_auth.currentUser!.phoneNumber;
    bool pay_with_my_wallet=false; if((widget.data as Map).containsKey("pay_with_my_wallet")) pay_with_my_wallet=widget.data["pay_with_my_wallet"];
    var MyData=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();



    if(UserIn){
      print("Удаление юзера (себя)");
      bool success=await DeleteMySelfDialog();
      if(success) success = await ChangeBalance(false,pay_with_my_wallet);
      if(success) {

        EventUsersListData.removeWhere((element) => element['phone']==_auth.currentUser!.phoneNumber);
        await firestore.collection("Events").doc(widget.data['doc_id']).collection("Users").doc(_auth.currentUser!.phoneNumber).delete();
        await firestore.collection("Events").doc(widget.data['doc_id']).collection("WaitList").doc(_auth.currentUser!.phoneNumber).delete();
        await firestore.collection("Events").doc(widget.data['doc_id']).collection("InvitedUsers").doc(_auth.currentUser!.phoneNumber).delete();
        await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Events").doc(widget.data['doc_id']).delete();
        var IAmWereWaitList=IAmInWaitList;
        setState(() {
          IsUserIn=false;
          IAmInWaitList=false;
          // peoples_length=EventUsersList.length;
        });
        (widget.data['price']=="0"||pay_with_my_wallet||widget.data['free_admission']) ? ScaffoldMessa(IAmWereWaitList ? AppLocalizations.of(context)!.you_left_the_wait_list : AppLocalizations.of(context)!.you_left_the_wait_list,context) : ScaffoldMessa(AppLocalizations.of(context)!.you_left_the_event_your_money_has_been_returned,context);
        await firestore.collection("Events").doc(widget.data['doc_id']).update({"peoples":peoples_length-1,}); // Добавляем юзера в список
        // (widget.data['price']==0||pay_with_my_wallet||widget.data['free_admission']) ? ScaffoldMessa(IAmWereWaitList ? "You left the wait list" : "You left the event",context) : ScaffoldMessa("You left the event, your money has been returned",context);
      }

    } else if(!UserIn) {
      print("Добавление юзера (себя)"); // Поправить добавление в бесплатное

      if(MyData['gender']+1==widget.data['gender']||widget.data['gender']==0){
        bool success=widget.data['price']!="0" ? // Мероприятие платное
        (pay_with_my_wallet ? // Оплатить
        await PayForOrganizerWallet() :
        await ChangeBalance(true,pay_with_my_wallet)
        ) :
        true; // Пустить

        if((success&&!pay_with_my_wallet)||(IAmInvited)||widget.data['price']=="0"){
        // if((success&&!pay_with_my_wallet)||(IAmInvited&&!its_me)||widget.data['price']=="0"){

          if(its_me) {
            EventUsersList.add(_auth.currentUser!.phoneNumber);

            await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Events").doc(widget.data['doc_id']).set({"active":true});
            await firestore.collection("Events").doc(widget.data['doc_id']).collection("Users").doc(_auth.currentUser!.phoneNumber).set({"active":true});
            await firestore.collection("Events").doc(widget.data['doc_id']).update({"peoples":peoples_length+1,}); // Добавляем юзера в список
          } else {SendFriendInviteNotification(doc_id: user_id,data: widget.data);};
          setState(() {if(its_me){IsUserIn=true;}; });
          (its_me) ? ScaffoldMessa(AppLocalizations.of(context)!.you_have_been_added,context) : ScaffoldMessa(AppLocalizations.of(context)!.your_friend_have_been,context);
          // (its_me) ? ScaffoldMessa("You have been added to the event, welcome!",context) : ScaffoldMessa("Your friend have been invited to the event!",context);

        } else if(success&&pay_with_my_wallet){

          await firestore.collection("Events").doc(widget.data['doc_id']).collection("WaitList").doc(user_id).set({"active":"true"});
          if(its_me){ setState(() { IAmInWaitList=true; }); } else {SendFriendInviteNotification(doc_id: user_id,data: widget.data);};
          ScaffoldMessaLong(AppLocalizations.of(context)!.thank_you_for_your_application+(user_id==_auth.currentUser!.phoneNumber ? AppLocalizations.of(context)!.you : AppLocalizations.of(context)!.your_friend)+" "+AppLocalizations.of(context)!.to_the_event+". "+(user_id==_auth.currentUser!.phoneNumber ? AppLocalizations.of(context)!.you : AppLocalizations.of(context)!.your_friend)+" "+AppLocalizations.of(context)!.will_receive_a_notification,context);
          // ScaffoldMessaLong("Thank you for your application, after payment wait for the organizer to accept "+(user_id==_auth.currentUser!.phoneNumber ? "you":"your friend")+" to the event. "+(user_id==_auth.currentUser!.phoneNumber ? "You":"Your friend")+" will receive a notification",context);

        }
      } else {
        UserMessage(AppLocalizations.of(context)!.other_gender_indicated_at_event, context);
        // UserMessage("Other gender indicated at event", context);

      }


    }


    // await firestore.collection("Events").doc(widget.data['doc_id']).update({"peoples":EventUsersList.length,}); // Добавляем юзера в список
    // GetEventUsers();
    GetEventUsersCollection();
  }


  Future<bool> ChangeBalance(IsSpent,pay_with_my_wallet)async {


    var UserEventsDoc=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var UserBalance=UserEventsDoc.data()!['balance'];
    if(IsSpent){

      if(UserBalance>=int.parse(widget.data!['price'])||widget.data['free_admission']){ // Поправить
        await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"balance":UserBalance-(int.parse(widget.data['price'])*(after_discount_price_percent/100))});
        return true;
      } else {

        var Lacking=int.parse(widget.data!['price'])-UserBalance;
        var OverLacking=int.parse(widget.data!['price'])-UserBalance;
        var result=await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.please_add+" \$$Lacking "+AppLocalizations.of(context)!.to_your_wallet),
            // title: Text("Please add \$$Lacking to your wallet"),
            content: null,
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
          var success=false;
          bool video_exist=(widget.data as Map).containsKey("my_video_link") ? (widget.data['my_video_link']!="") : false ;
          if(video_exist) video_controller.dispose();

          final page = CardFormScreen(type: "event",price: widget.data!['price'],);
          await Navigator.of(context).push(CustomPageRoute(page)).then((value) {
            if(video_exist) LoadVideo();
            success=value;
          });
          if(success) {
            await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"balance":UserBalance-(int.parse(widget.data['price'])*(after_discount_price_percent/100))});
            return true;
          } else {
            return false;
          };
        }
      }

    } else {
      if(!pay_with_my_wallet) {
        await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"balance":UserBalance+(int.parse(widget.data['price'])*(after_discount_price_percent/100))});
      }
      return true;
    }

    return false;

  }

  Future<bool> PayForOrganizerWallet()async {


    var UserEventsDoc=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.pay_to_organizer_wallet),
        // title: Text("Pay to organizer wallet"),
        content: Column(
          children: [
            SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.send_money_to_the_organizer_and_put_special_text),
            // Text("Send money to the organizer and put special text (tap copy button) as a comment so that the organizer can add you to the roster"),
            SizedBox(height: 12,),
            Text(AppLocalizations.of(context)!.instruction+": "+widget.data['my_wallet_instructions']),
            // Text("Instruction: "+widget.data['my_wallet_instructions']),
            if(widget.data['my_wallet'].length!=0)...[
              SizedBox(height: 12,),
              Text(AppLocalizations.of(context)!.organizer_wallet+": "+widget.data['my_wallet']),
              // Text("Organizer wallet: "+widget.data['my_wallet']),
            ],
            Divider(height: 32,color: Colors.black26,),
            Material(
              color: Color.fromRGBO(0, 0, 0, 0),
              child: InkWell(
                onTap: () async{
                  await Clipboard.setData(ClipboardData(text: my_nickname+" | "+widget.data['header'].toString()+" | "+
                      (DateTime.fromMillisecondsSinceEpoch(widget.data['date']).month<10 ? "0"+DateTime.fromMillisecondsSinceEpoch(widget.data['date']).month.toString() : DateTime.fromMillisecondsSinceEpoch(widget.data['date']).month.toString()).toString()+"."+
                      (DateTime.fromMillisecondsSinceEpoch(widget.data['date']).day<10 ? "0"+DateTime.fromMillisecondsSinceEpoch(widget.data['date']).day.toString() : DateTime.fromMillisecondsSinceEpoch(widget.data['date']).day.toString()).toString()
                  ));
                  ScaffoldMessa("Text copied",context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Copy button  ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                    // Text("ID "+DateTime.now().millisecondsSinceEpoch.toString()+"   ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                    Icon(Icons.copy,size: 20,),
                    // Row(
                    //   children: [
                    //     Text("Copy   ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                    //     Icon(Icons.copy,size: 20,),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("OK"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          if(widget.data['my_wallet_paylink'].length!=0) ...[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(AppLocalizations.of(context)!.pay_link),
              // child: Text("Pay link"),
              onPressed: () async{
                var url = widget.data['my_wallet_paylink'];
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                } else {
                throw 'Could not launch $url';
                }
              },
            ),
          ],
        ],
      ),
    );

    if(result) {
      return true;
    }

    return false;
  }

  Future<bool> AddUserWhenMaxPeoplesDialog() async{
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.add_a_user_over_the_limit),
        // title: Text("Add a user over the limit"),
        content: Text(AppLocalizations.of(context)!.the_user_limit_is_full),
        // content: Text("The user limit is full. Do you want to add a user anyway?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            // child: Text("Cancel"),
            isDefaultAction: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.yes),
            // child: Text("Yes"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),

        ],
      ),
    );

    return result;

  }

  void AddUserFromWaitList(user_id,index) async{
    var func_peoples_doc=await firestore.collection("Events").doc(widget.data['doc_id']).get();
    var func_peoples_length=func_peoples_doc.data()!['peoples'];

    if(!widget.data['unlimited_users']&&peoples_length>=widget.data['max_peoples']){
      var bol= await AddUserWhenMaxPeoplesDialog();
      if(bol){
        var EventData=await firestore.collection("Events").doc(widget.data['doc_id']).get();

        await firestore.collection("Events").doc(widget.data['doc_id']).collection("WaitList").doc(user_id).delete();
        await firestore.collection("Events").doc(widget.data['doc_id']).collection("Users").doc(user_id).set({"active": true});

        int people_length=EventData.data()!['peoples'];

        await firestore.collection("Events").doc(widget.data['doc_id']).update({"peoples":func_peoples_length+1});
        SendAcceptNotification(data: widget.data, doc_id: user_id);

        // GetEventUsers();
        GetEventUsersCollection();
        setState(() {  EventUsersListData.removeAt(index);  });
      }
    } else {
      var EventData=await firestore.collection("Events").doc(widget.data['doc_id']).get();

      await firestore.collection("Events").doc(widget.data['doc_id']).collection("WaitList").doc(user_id).delete();
      await firestore.collection("Events").doc(widget.data['doc_id']).collection("Users").doc(user_id).set({"active": true});

      int people_length=EventData.data()!['peoples'];

      await firestore.collection("Events").doc(widget.data['doc_id']).update({"peoples":func_peoples_length+1});
      SendAcceptNotification(data: widget.data, doc_id: user_id);

      // GetEventUsers();
      GetEventUsersCollection();
      setState(() {  EventUsersListData.removeAt(index);  });
    }



  }

  void DeleteUserDialog(user_id,organizer,index,manual_member) async{
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.removing_the_user),
        // title: Text("Removing the user"),
        content: Text(AppLocalizations.of(context)!.are_you_sure_you_want_to_delete_a_user),
        // content: Text("Are you sure you want to delete a user?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            // child: Text("Cancel"),
            isDefaultAction: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.yes),
            // child: Text("Yes"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),

        ],
      ),
    );

    if(result){
      setState(() {EventUsersListData.removeAt(index);peoples_length=peoples_length-1;});
      DeleteUser(user_id, organizer,manual_member);
    }
  }



  Future<bool> DeleteMySelfDialog() async{
    // bool reuslt=false;

    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(IAmInWaitList ? AppLocalizations.of(context)!.are_you_sure_you_want_to_get_out_from_wait_list : AppLocalizations.of(context)!.are_you_sure_you_want_to_get_out_from_wait_list),
        // title: Text(IAmInWaitList ? "Are you sure you want to get out from wait list?" : "Are you sure you want to get out from this event?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            // child: Text("Cancel"),
            isDefaultAction: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.yes),
            // child: Text("Yes"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),

        ],
      ),
    );

    return result;
  }

  void DeleteUser(user_id,organizer,manual_member) async{
    print("Удаление юзера");
    if(!manual_member){
      var UserEventsDoc=await firestore.collection("UsersCollection").doc(user_id).get();

      SendDeleteNotification(doc_id: user_id,data: widget.data);

      EventUsersList.removeWhere((element) => element==user_id);
      EventUsersListData.removeWhere((element) => element['phone']==user_id);


      await firestore.collection("Events").doc(widget.data['doc_id']).collection("Users").doc(user_id).delete(); // Удаляем юзера
      await firestore.collection("Events").doc(widget.data['doc_id']).update({"peoples":peoples_length-1});
      await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
        "balance":!organizer ? ((int.parse(widget.data['price'])*(after_discount_price_percent/100))+UserEventsDoc.data()!['balance']) : UserEventsDoc.data()!['balance']
      });
    } else {
      print("Удаляем ручного юзера "+user_id.toString());
      await firestore.collection("Events").doc(widget.data['doc_id']).collection("Users").doc(user_id.toString()).delete(); // Удаляем юзера
      await firestore.collection("Events").doc(widget.data['doc_id']).update({"peoples":peoples_length-1});
    }


  }

  FirebaseWebSocket(Switch){

    final MessagesRef = firestore.collection("Events").doc(widget.data['doc_id']).collection("Messages");

    if(Switch) { print("Слушаем стрим ");
    stream = MessagesRef.snapshots().listen((event) { GetAllMessage();},
      onError: (error) {print("Listen failed: $error");},
    );
    } else { print("Не слушаем"); stream.cancel();}

  }

  FirebaseWebSocketEventData(Switch){

    final MessagesRef = firestore.collection("Events").doc(widget.data['doc_id']);

    if(Switch) { print("Слушаем стрим ивента");
    stream = MessagesRef.snapshots().listen((event) {
      print("Обновление данных");

      var AllValues=(widget.data as Map).keys.toList();
      AllValues.forEach((keyy) {
        if(keyy!="doc_id") widget.data[keyy]=event.data()![keyy];
      });
      GetEventUsersCollection();
      setState(() { });
    },
      onError: (error) {print("Listen failed: $error");},
    );
    } else { print("Не слушаем ивент"); stream.cancel();}

  }

  late VideoPlayerController video_controller;
  bool video_load=false;

  
  @override
  void initState() {
    peoples_length=widget.data["peoples"];
    IsPromoCorrect();
    if((widget.data as Map).containsKey("my_video_link")) LoadVideo();

    // GetEventUsersCollection(); // Перенесено в FirebaseWebSocketEventData
    FirebaseWebSocket(true);
    FirebaseWebSocketEventData(true);
    GetLanguage();
    peoples_length=widget.data['peoples'];

    // TODO: implement initState
    super.initState();
  }

  void LoadVideo() {
    setState(() { video_load=false; });

    if(widget.data['my_video_link']!="") {
      video_controller = VideoPlayerController.networkUrl(Uri.parse(widget.data['my_video_link']))
        ..initialize().then((_) {
          video_controller.play();
          video_controller.setVolume(0);
          video_controller.setLooping(true);
          setState(() { video_load=true; });
          // Ensure the first frame is shown after the video is initialized
        });
      setState(() {
        print("Видео загружено");
      });
    }

  }


  void PromoIsCorrect(name,value) async{
    await firestore.collection("Events").doc(widget.data['doc_id']).collection("PromoUsers").add({
      "phone":_auth.currentUser!.phoneNumber.toString(),
      "promo_name":name.toString(),
      }
    );
    setState(() {after_discount_price_percent=value;});
  }

  void IsPromoCorrect() async{
    var data = await firestore.collection("Events").doc(widget.data['doc_id']).collection("PromoUsers").get();
    data.docs.forEach((element) {

      if(element.data()['phone']==_auth.currentUser!.phoneNumber.toString()){
        if(element.data().containsKey("promo_name")){
          if(element.data()['promo_name']=widget.data['promo_code_name']) setState(() {after_discount_price_percent=(widget.data as Map)['promo_code_value'];});
          if(element.data()['promo_name']=widget.data['promo_code_name2']) setState(() {after_discount_price_percent=(widget.data as Map)['promo_code_value2'];});
          if(element.data()['promo_name']=widget.data['promo_code_name3']) setState(() {after_discount_price_percent=(widget.data as Map)['promo_code_value3'];});
          if(element.data()['promo_name']=widget.data['promo_code_name4']) setState(() {after_discount_price_percent=(widget.data as Map)['promo_code_value4'];});
          if(element.data()['promo_name']=widget.data['promo_code_name5']) setState(() {after_discount_price_percent=(widget.data as Map)['promo_code_value5'];});
        } else {
          setState(() {after_discount_price_percent=(widget.data as Map)['promo_code_value'];});
        }
      };
    });


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: EventAppBarPro(title: widget.data['short_address'],data: widget.data),
      backgroundColor: groupValue!=2 ? Colors.white : Color.fromRGBO(236, 236, 242, 1),
      body: Stack(
        children: [
          if(FinalGroupValue==0) ...[

            EventDetails(data: widget.data,join_button:(doc_id){

              if(IAmOrganizer){
                bool video_exist=(widget.data as Map).containsKey("my_video_link") ? (widget.data['my_video_link']!="") : false ;
                if(video_exist) video_controller.dispose();

                final page = AddEventPage(data: widget.data,is_new: false, is_dublicate: false,);
                Navigator.of(context).push(CustomPageRoute(page)).then((value) {
                  if(video_exist) LoadVideo();
                });
              } else {
                if(doc_id==_auth.currentUser!.phoneNumber){
                  JoinButtonCollectionsEdition(IsUserIn||IAmInWaitList,doc_id);
                } else {
                  JoinButtonCollectionsEdition(false,doc_id);
                }

              }
            }, peoples: peoples_length,
              IsUserIn: IsUserIn,
              IAmInvited: IAmInvited,
              IAmOrganizer: IAmOrganizer,
              IInWaitList: IAmInWaitList,
              show_buttons: show_buttons,
              IAmAdmin: IAmAdmin,
              peoples_length: peoples_length,
              join_wait_bool: join_wait_bool,
              EventOrganizerListData:EventOrganizerListData,
              russian_language: russian_language,
              add_friend_wait_bool: add_friend_wait_bool,
              get_users: GetEventUsersCollection,
              after_discount_price_percent: after_discount_price_percent,
              PromoIsCorrect: PromoIsCorrect,
              video_controller: ((widget.data as Map).containsKey("my_video_link")) ? widget.data['my_video_link']!="" ? video_controller : null : null, load_video: LoadVideo, is_video_load: video_load,
            ),

          ] else if(FinalGroupValue==1) ...[
            ListView.separated(
                padding: EdgeInsets.only(top: 86,left: 16,right: 16), itemCount: EventUsersListData.length, shrinkWrap: true,
                separatorBuilder: (context,index){return Divider(height: 16,color: Colors.white,);},
                itemBuilder: (contex,index){
                  return EventUserCard(context, EventUsersListData[index]['nickname'], EventUsersListData[index]['role']==0 ? AppLocalizations.of(context)!.online : EventUsersListData[index]['role']==1 ? "Organizer" : EventUsersListData[index]['role']==(-2) ? "Member" : "Wait for accept", EventUsersListData[index]['avatar_link'], EventUsersListData[index]['doc_id'],IAmOrganizer,(){
                    DeleteUserDialog(EventUsersListData[index]['doc_id'], EventUsersListData[index]['role']!=0,index,EventUsersListData[index]['role']==(-2));

                  },(){
                    AddUserFromWaitList(EventUsersListData[index]['doc_id'],index);
                  },EventUsersListData[index].containsKey("safe_badge") ? EventUsersListData[index]["safe_badge"] : false);
                }
            ),
          ] else if(FinalGroupValue==2) ...[
            ChatWidget(MessageController: MessageController,MessageNode: MessageNode, MessageList: MessageList,SendMessage: (value){SendMessage(value);}, IsEventChat: true,),
          ] else if(FinalGroupValue==3) ...[
            EventAddress(data: widget.data,russian_language: russian_language, is_user_in: IsUserIn, i_am_organizer: IAmOrganizer,)
          ],
          if(widget.data.containsKey("infinity_users")) ...[
            if(widget.data["infinity_users"]) ...[
              if(!widget.data['is_online']) Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          spreadRadius: 20,
                          blurRadius: 20
                      )
                    ]
                ),
                height: 70,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(height: 16,),
                    Container(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<int>(
                        backgroundColor:  CupertinoColors.systemGrey5,
                        thumbColor: CupertinoColors.white,
                        padding: EdgeInsets.all(2),
                        groupValue: groupValue,
                        children:  {
                          0: buildSegment(AppLocalizations.of(context)!.details),
                          1: buildSegment(AppLocalizations.of(context)!.chat),
                          2: buildSegment(AppLocalizations.of(context)!.address),
                        },
                        onValueChanged: (value){

                          setState(() {
                            if(value==0) {
                                groupValue = 0;
                                FinalGroupValue = 0;
                              }
                              if(value==1) {
                                groupValue = 1;
                                FinalGroupValue = 2;
                              }
                              if(value==2) {
                                groupValue = 2;
                                FinalGroupValue = 3;
                              }
                            });
                        },
                      ),
                    ),
                  ],
                ),
              ) else Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          spreadRadius: 20,
                          blurRadius: 20
                      )
                    ]
                ),
                height: 70,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(height: 16,),
                    Container(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<int>(
                        backgroundColor:  CupertinoColors.systemGrey5,
                        thumbColor: CupertinoColors.white,
                        padding: EdgeInsets.all(2),
                        groupValue: groupValue,
                        children:  {
                          0: buildSegment(AppLocalizations.of(context)!.details),
                          1: buildSegment(AppLocalizations.of(context)!.chat),
                        },
                        onValueChanged: (value){

                          setState(() {
                            if(value==1) {
                                groupValue = 1;
                                FinalGroupValue = 2;
                              } else {
                                FinalGroupValue = 0;
                                groupValue = 0;
                              }
                            });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ] else GroupChoice(context)
          ] else ...[
            GroupChoice(context),
          ]

        ],
      ),
    );
  }

  Container GroupChoice(BuildContext context) {
    return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 20,
                      blurRadius: 20
                  )
                ]
            ),
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 16,),
                Container(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    backgroundColor:  CupertinoColors.systemGrey5,
                    thumbColor: CupertinoColors.white,
                    padding: EdgeInsets.all(2),
                    groupValue: groupValue,
                    children: !widget.data['is_online'] ? {
                      0: buildSegment(AppLocalizations.of(context)!.details),
                      1: buildSegment(AppLocalizations.of(context)!.users),
                      2: buildSegment(AppLocalizations.of(context)!.chat),
                      3: buildSegment(AppLocalizations.of(context)!.address),
                    } : {
                      0: buildSegment(AppLocalizations.of(context)!.details),
                      1: buildSegment(AppLocalizations.of(context)!.users),
                      2: buildSegment(AppLocalizations.of(context)!.chat),
                    },
                    onValueChanged: (value){

                      setState(() {
                        if(widget.data.containsKey("infinity_users")&&value==2) {
                          if(value==2&&widget.data['infinity_users']) UserMessage("Chat is not available for this event", context);
                          else {
                            if(!IsUserIn&&value==2&&!IAmAdmin) UserMessage(AppLocalizations.of(context)!.chat_only_for_members, context);
                            else {
                              FinalGroupValue = value!;
                              groupValue = value;
                      }
                    }
                        } else {
                          if(!IsUserIn&&value==2&&!IAmAdmin) UserMessage(AppLocalizations.of(context)!.chat_only_for_members, context);
                          else {
                            FinalGroupValue = value!;
                              groupValue = value;
                          }
                  }


                      });
                    },
                  ),
                ),
              ],
            ),
          );
  }
  
  

  void GetLanguage() async{
    var lang = await model.GetLanguage();
    setState(() { russian_language=lang=="ru"; });
  }

  void dispose() {

    ((widget.data as Map).containsKey("my_video_link") ? (widget.data['my_video_link']!="" ? video_controller.dispose() : null) : null);
    FirebaseWebSocket(false);
    FirebaseWebSocketEventData(false);
    super.dispose();
  }

  Widget buildSegment(String text){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(text,style: TextStyle(fontSize: 14, color: Colors.black87,),),
    );
  }
}



class EventDetails extends StatefulWidget {
  final data;
  final IsUserIn;
  final IAmOrganizer;
  final IAmAdmin;
  final IInWaitList;
  final IAmInvited;
  final peoples;
  Function(String) join_button;
  final show_buttons;
  final peoples_length;
  final join_wait_bool;
  final add_friend_wait_bool;
  final EventOrganizerListData;
  final russian_language;
  final get_users;
  final after_discount_price_percent;
  final video_controller;
  final load_video;
  final is_video_load;
  Function PromoIsCorrect;
  EventDetails({
    Key? key,
    required this.data,
    required this.IsUserIn,
    required this.peoples,
    required this.join_button,
    required this.IAmOrganizer,
    required this.IAmAdmin,
    required this.IAmInvited,
    required this.IInWaitList,
    required this.show_buttons,
    required this.peoples_length,
    required this.join_wait_bool,
    required this.add_friend_wait_bool,
    required this.EventOrganizerListData,
    required this.russian_language,
    required this.get_users,
    required this.after_discount_price_percent,
    required this.PromoIsCorrect,
    required this.video_controller,
    required this.load_video,
    required this.is_video_load,
  }) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {

  Map EnglMonths={1:"January", 2:"February", 3:"March", 4:"April", 5:"May", 6:"June", 6:"Jule", 8:"August", 9:"September", 10:"October", 11:"November", 12:"December",};
  Map RusMonths={1:"января", 2:"феварля", 3:"марта", 4:"апреля", 5:"мая", 6:"июня", 6:"июля", 8:"августа", 9:"сентября", 10:"октября", 11:"ноября", 12:"декабря",};
  Map RusDays={"Monday":"Понедельник", "Tuesday":"Вторник", "Wednesday":"Среда", "Thursday":"Четверг", "Friday":"Пятница", "Saturday":"Суббота", "Sunday":"Воскресенье"};

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool IsApproved=false;

  bool big=false;



  TextEditingController PromoController=TextEditingController();
  FocusNode PromoNode=FocusNode();




  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {


    if((widget.data as Map).containsKey("approved")){
      IsApproved=widget.data['approved'];
    }
    // TODO: implement initState
    super.initState();
  }

  bool sound_on=false;

  @override
  Widget build(BuildContext context) {
    var DateEpoch=DateTime.fromMillisecondsSinceEpoch(widget.data['date']);
    var DateName=DateFormat('EEEE').format(DateEpoch);
    var DateNameMonth=DateFormat('MMMM').format(DateEpoch);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // widget.data.containsKey("infinity_users") ? (widget.data['infinity_users'] ? 16 : 86) : 86 SizedBox(height: 72,),
                if(widget.data.containsKey("infinity_users")) ...[
                  if(!widget.data['infinity_users']&&!widget.data['is_online']) SizedBox(height: 72,)
                  else if (widget.data['infinity_users']&&!widget.data['is_online']) SizedBox(height: 72,)
                  else if (widget.data['infinity_users']&&widget.data['is_online']) SizedBox(height: 72,)
                  else SizedBox(height: 16,),
                ] else ...[
                  SizedBox(height: 72,)
                ],
                if((widget.data as Map)['additional_photo_links'].length!=0||((widget.data as Map).containsKey("my_video_link") ? widget.data['my_video_link']!="" : false))...[
                  InkWell(
                    onTap: (){
                      // OrderHasBeenPlaced();
                      setState(() {
                        big=!big;
                      });
                    },
                    child: AnimatedSize(
                      curve: Curves.fastLinearToSlowEaseIn,
                      alignment: Alignment.topCenter,
                      duration: Duration(milliseconds: 500),
                      child: CarouselSlider(
                        options: CarouselOptions(height:big ? 600 : 160.0),
                        items: ((
                            ((widget.data as Map).containsKey("my_video_link") ? widget.data['my_video_link']!="" : false) ?
                            (((widget.data as Map)['additional_photo_links'].length==0 ?
                            [widget.data['my_video_link'],widget.data['photo_link'],] :
                            [widget.data['my_video_link'],...widget.data['additional_photo_links']]))

                                :

                            widget.data['additional_photo_links']
                        ) as List<dynamic>).map((i) {
                          var ContainerWidth=(MediaQuery.of(context).size.width-(16*6));

                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black12
                                  ),
                                  child: ((widget.data as Map).containsKey("my_video_link") ? widget.data["my_video_link"]==i : false) ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      constraints: BoxConstraints(maxHeight: 160),
                                      height: 160,
                                      child: Stack(
                                        children: [
                                          Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: !big ?
                                                  (160-ContainerWidth*widget.data['video_size_index'])/2
                                                      :
                                                  widget.data['is_video_horizontal'] ?
                                                  ( ( 600-ContainerWidth*widget.data['video_size_index'] ) / 2 )
                                                      :
                                                  (600-ContainerWidth/widget.data['video_size_index'])/2 ,

                                                  horizontal: big ?
                                                    0
                                                      :
                                                  (widget.data['is_video_horizontal'] ?
                                                    0
                                                      :
                                                  ((ContainerWidth-160*widget.data['video_size_index'])/2)) ),

                                              color: Colors.black,
                                              child: VideoPlayer(widget.video_controller)
                                          ),
                                          if(widget.is_video_load) SoundButton(),
                                        ],
                                      ),
                                    ),
                                  ) : Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                            image: NetworkImage(i),
                                            fit: BoxFit.fitWidth
                                        )
                                    ),
                                  )
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ] else ...[
                  InkWell(
                    onTap: (){
                      setState(() {
                        big=!big;
                      });
                    },
                    child: AnimatedSize(
                      curve: Curves.fastLinearToSlowEaseIn,
                      alignment: Alignment.topCenter,
                      duration: Duration(milliseconds: 500),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        height:big ? 600 : 160.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black,
                            image: DecorationImage(
                                image: NetworkImage(widget.data['photo_link']),fit: BoxFit.fitWidth
                            )
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 24,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.separated(
                          padding: EdgeInsets.all(0), itemCount: widget.EventOrganizerListData.length, shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
                          separatorBuilder: (context,index){return Divider(height: 16,color: Colors.white,);},
                          itemBuilder: (contex,index){
                            return EventUserCard(context, widget.EventOrganizerListData[index]['nickname'], widget.EventOrganizerListData[index]['role']==0 ? "Online" : widget.EventOrganizerListData[index]['role']==1 ? "Organizer" : "Wait for accept", widget.EventOrganizerListData[index]['avatar_link'], widget.EventOrganizerListData[index]['doc_id'],false,(){

                            },(){

                            },(widget.EventOrganizerListData[index] as Map).containsKey("safe_badge") ? widget.EventOrganizerListData[index]["safe_badge"] : false);
                          }
                      ),
                      Divider(height: 32,color: Colors.black26,),
                      Text((widget.russian_language ? RusDays[DateName.toString()] : DateName.toString())+" "+DateEpoch.day.toString()+" "+( widget.russian_language ? RusMonths[DateEpoch.month] : EnglMonths[DateEpoch.month]),style: TextStyle(fontSize: 14,fontWeight: FontWeight.w700,color: Colors.black87,height: 1.4),),
                      Text(widget.russian_language&&widget.data['rus_header']!="" ? widget.data['rus_header'].toString().trim() : widget.data['header'].toString().trim(),style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700,height: 1.4),),

                      if((widget.data as Map).containsKey("primary_language")) ...[
                        SizedBox(height: 2,),
                        if (widget.data['primary_language']=="All languages"||widget.data['primary_language']=="Все языки") Text(AppLocalizations.of(context)!.primary_lang+" "+AppLocalizations.of(context)!.all.toLowerCase(),style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
                        // if (widget.data['primary_language']=="Все языки") Text(AppLocalizations.of(context)!.primary_lang+" все",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
                        if (widget.data['primary_language']=="English") Text(AppLocalizations.of(context)!.primary_lang+" English",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
                        if (widget.data['primary_language']=="American English") Text(AppLocalizations.of(context)!.primary_lang+" American English",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
                        if (widget.data['primary_language']=="Русский") Text(AppLocalizations.of(context)!.primary_lang+" Русский",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
                        if (widget.data['primary_language']=="Українська") Text(AppLocalizations.of(context)!.primary_lang+" Українська",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
                        if (widget.data['primary_language']=="Қазақ") Text(AppLocalizations.of(context)!.primary_lang+" Қазақ",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
                        if (widget.data['primary_language']=="հայերեն") Text(AppLocalizations.of(context)!.primary_lang+" հայերեն",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
                      ],
                      Divider(height: 32,color: Colors.black26,),
                      Wrap(
                        runSpacing: 12,
                        children: [
                          IconText(DateTime.fromMillisecondsSinceEpoch(widget.data['date']).hour.toString()+":"+(DateTime.fromMillisecondsSinceEpoch(widget.data['date']).minute>9 ? DateTime.fromMillisecondsSinceEpoch(widget.data['date']).minute.toString() : "0"+DateTime.fromMillisecondsSinceEpoch(widget.data['date']).minute.toString() )+
                              " | "+widget.data['duration'].toString()+" min.","TimeSquare.svg"),
                          SizedBox(width: 16,),
                          widget.data['price']=="0" ? IconText("Free".toString(),"Wallet.svg") :
                          IconText("\$"+(int.parse(widget.data['price'])*(widget.after_discount_price_percent/100)).toString(),"Wallet.svg"),
                          SizedBox(width: 16,),
                          if(widget.data.containsKey("infinity_users")) ...[
                            if(!widget.data['infinity_users']) ...[
                              widget.data['unlimited_users'] ? IconText(widget.data['max_peoples'].toString(),"Users.svg") : IconText(widget.peoples_length.toString()+"/"+widget.data['max_peoples'].toString(),"Users.svg"),
                              if((widget.data as Map).containsKey("kids_allowed")) ...[if(widget.data['kids_allowed']) IconText(AppLocalizations.of(context)!.you_can_come_with_children,"gameboy.svg")],
                            ]
                          ] else ...[
                            widget.data['unlimited_users'] ? IconText(widget.data['max_peoples'].toString(),"Users.svg") : IconText(widget.peoples_length.toString()+"/"+widget.data['max_peoples'].toString(),"Users.svg"),
                            if((widget.data as Map).containsKey("kids_allowed")) ...[if(widget.data['kids_allowed']) IconText(AppLocalizations.of(context)!.you_can_come_with_children,"gameboy.svg")],
                          ]

                        ],
                      ),

                      Divider(height: 32,color: Colors.black26,),

                      if(widget.show_buttons) ...[
                        if(widget.peoples_length>=widget.data['max_peoples']&&!widget.data['unlimited_users']&&!widget.IAmOrganizer&&!widget.IsUserIn&&!widget.IInWaitList&&!widget.IAmInvited)
                          InkWell(
                            onTap: () async{
                              // widget.join_button(_auth.currentUser!.phoneNumber.toString());
                            },
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.green
                              ),
                              child: Center(
                                child: Text(AppLocalizations.of(context)!.event_full, // Войти
                                // child: Text("Event Full", // Войти
                                  style: TextStyle(fontSize: 16,color: Colors.white),),
                              ),
                            ),
                          )
                        else Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async{
                                  widget.join_button(_auth.currentUser!.phoneNumber.toString());
                                },
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black
                                  ),
                                  child: Center(
                                    child: widget.join_wait_bool ? Center(child: CupertinoActivityIndicator(color: Colors.white,)) :
                                    Text(widget.IAmOrganizer ? AppLocalizations.of(context)!.edit : // Я организатор?
                                    widget.IsUserIn||widget.IInWaitList ? // Я внутри?
                                    widget.IInWaitList ? AppLocalizations.of(context)!.waiting : AppLocalizations.of(context)!.leave : // Выйти
                                    AppLocalizations.of(context)!.join, // Войти
                                      style: TextStyle(fontSize: 16,color: Colors.white),),
                                  ),
                                ),
                              ),
                            ),
                            if(widget.peoples_length<widget.data['max_peoples']) ...[
                              if(widget.data.containsKey("infinity_users")) ...[
                                if(!widget.data['infinity_users']) ...[
                                  SizedBox(width: 12,),
                                  AddFriendButton(context),
                                ]
                              ] else ...[
                                SizedBox(width: 12,),
                                AddFriendButton(context),
                              ]
                            ]
                          ],
                        ),
                      ],
                      if(widget.IAmAdmin&&!IsApproved) ...[
                        SizedBox(height: 12,),
                        InkWell(
                          onTap: () async{
                            if(!IsApproved){
                              setState(() {
                                IsApproved=true;
                              });
                              UserMessage(AppLocalizations.of(context)!.successfully_approved, context);
                              // UserMessage("Successfully approved", context);
                              await firestore.collection("Events").doc(widget.data['doc_id']).update({"approved":true});
                            }

                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black
                            ),
                            child: Center(
                              child: Text(!IsApproved ? AppLocalizations.of(context)!.approve : AppLocalizations.of(context)!.successfully_approved,style: TextStyle(fontSize: 16,color: Colors.white),),
                              // child: Text(!IsApproved ? "Approve" : "Successfully approved",style: TextStyle(fontSize: 16,color: Colors.white),),
                            ),
                          ),
                        ),
                      ],
                      if(widget.IAmOrganizer) ...[
                        if(widget.peoples_length<widget.data['max_peoples']) ...[
                          if(widget.data.containsKey("infinity_users")) ...[
                            if(!widget.data['infinity_users']) ...[
                              SizedBox(height: 12,),
                              AddUserManualyButton(context),
                            ]
                          ] else ...[
                            SizedBox(height: 12,),
                            AddUserManualyButton(context),
                          ]
                        ],

                        SizedBox(height: 12,),
                        InkWell(
                          onTap: () async{
                            bool video_exist=(widget.data as Map).containsKey("my_video_link") ? (widget.data['my_video_link']!="") : false ;
                            if(video_exist) widget.video_controller.dispose();

                            final page = AddEventPage(data: widget.data,is_new: false, is_dublicate: true,);
                            Navigator.of(context).push(CustomPageRoute(page)).then((value) {
                              if(video_exist) widget.load_video;
                            });
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black
                            ),
                            child: Center(
                              child: Text("Дублировать мероприятие",style: TextStyle(fontSize: 16,color: Colors.white),),
                              // child: Text("Add a user manually",style: TextStyle(fontSize: 16,color: Colors.white),),
                            ),
                          ),
                        ),
                      ],
                      if(widget.after_discount_price_percent!=100) ...[
                        SizedBox(height: 12,),
                        InkWell(
                          onTap: () async{
                            PastPromoCode();
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: CupertinoColors.systemGrey5
                            ),
                            child: Center(
                              child: Text("Promocode",style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.w500),),
                              // child: Text(!IsApproved ? "Approve" : "Successfully approved",style: TextStyle(fontSize: 16,color: Colors.white),),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 24,),
                      Text(AppLocalizations.of(context)!.about,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                      // Text("About",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                      SizedBox(height: 8,),
                      Text(widget.russian_language&&widget.data['rus_about']!='' ? widget.data['rus_about'] : widget.data['about'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.5),),
                      if(widget.data['additional_text_count']>0)...[
                        SizedBox(height: 24,),
                        Text(widget.russian_language&&widget.data['rus_header1']!='' ? widget.data['rus_header1'] : widget.data['header1'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                        SizedBox(height: 8,),
                        Text(widget.russian_language&&widget.data['rus_about1']!='' ? widget.data['rus_about1'] : widget.data['about1'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.5),),
                      ],
                      if(widget.data['additional_text_count']>1)...[
                        SizedBox(height: 24,),
                        Text(widget.russian_language&&widget.data['rus_header2']!='' ? widget.data['rus_header2'] : widget.data['header2'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                        SizedBox(height: 8,),
                        Text(widget.russian_language&&widget.data['rus_about2']!='' ? widget.data['rus_about2'] : widget.data['about2'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.5),),
                      ],
                      SizedBox(height: 24,),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        // Positioned(
        //   bottom: 24,
        //   right: 24,
        //   child: Container(
        //     height: 120,
        //     width: 200,
        //     decoration: BoxDecoration(
        //       color: CupertinoColors.systemGrey5,
        //       borderRadius: BorderRadius.circular(12)
        //     ),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(12),
        //       child: VideoPlayer(video_controller),
        //     ),
        //   ),
        // )
      ],
    );
  }

  InkWell AddUserManualyButton(BuildContext context) {
    return InkWell(
        onTap: () async{
          await AddUserManualyFunc(context);
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black
          ),
          child: Center(
            child: Text(AppLocalizations.of(context)!.add_a_user_manually,style: TextStyle(fontSize: 16,color: Colors.white),),
            // child: Text("Add a user manually",style: TextStyle(fontSize: 16,color: Colors.white),),
          ),
        ),
      );
  }

  Future<void> AddUserManualyFunc(BuildContext context) async {
    if(!widget.data['unlimited_users']&&widget.peoples_length>=widget.data['max_peoples']){
      var bol= await AddUserWhenMaxPeoplesDialog();
      if(bol){
        bool video_exist=(widget.data as Map).containsKey("my_video_link") ? (widget.data['my_video_link']!="") : false ;
        if(video_exist) widget.video_controller.dispose();

        final page = AddUserManualy(event_id: widget.data['doc_id'],);
        await Navigator.of(context).push(CustomPageRoute(page)).then((value) {
          widget.get_users();
          if(video_exist) widget.load_video;
        });
      }
    } else {
      bool video_exist=(widget.data as Map).containsKey("my_video_link") ? (widget.data['my_video_link']!="") : false ;
      if(video_exist) widget.video_controller.dispose();

      final page = AddUserManualy(event_id: widget.data['doc_id'],);
      await Navigator.of(context).push(CustomPageRoute(page)).then((value) {
        widget.get_users();
        if(video_exist) widget.load_video;
      });
    }
  }

  Expanded AddFriendButton(BuildContext context) {
    return Expanded(
                              child: InkWell(
                                onTap: (){
                                  bool video_exist=(widget.data as Map).containsKey("my_video_link") ? (widget.data['my_video_link']!="") : false ;
                                  if(video_exist) widget.video_controller.dispose();

                                  final page = FriendListPage(need_to_add_friend: true);
                                  Navigator.of(context).push(CustomPageRoute(page)).then((value) {
                                              value != null ? widget.join_button(value) : null;
                                              if(video_exist) widget.load_video;
                                            });
                                },
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black
                                  ),
                                  child: Center(
                                    child: widget.add_friend_wait_bool ? Center(child: CupertinoActivityIndicator(color: Colors.white,)) : Text(AppLocalizations.of(context)!.add_friend,style: TextStyle(fontSize: 16,color: Colors.white),),
                                  ),
                                ),
                              ),
                            );
  }

  Positioned SoundButton() {
    return Positioned(
        top: 12,
        right: 12,
        child: GestureDetector(
          onTap: (){
            setState(() {
              print("sound_on "+sound_on.toString());
              if(sound_on) (widget.video_controller as VideoPlayerController).setVolume(0);
              else (widget.video_controller as VideoPlayerController).setVolume(1);
              setState(() {
                sound_on=!sound_on;
              });
            });
          },
          child: Container(
            height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white
              ),
              child: sound_on ? Icon(Icons.music_note,color: Colors.black,) : Icon(Icons.music_off,color: Colors.black,)
          ),
        )
    );
  }

  @override
  void dispose() {

    // TODO: implement dispose
    super.dispose();
  }



  void PastPromoCode() async{

    var result= showCupertinoDialog(
      context: scaffoldKey.currentContext ?? context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Введите промокод"),
        // title: Text("Pay to organizer wallet"),
        content: Column(
          children: [
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Material(
                color: Colors.white,
                child: TextFormField(
                  maxLines: null, focusNode: PromoNode, controller: PromoController, keyboardType: TextInputType.text,
                  style: TextStyle(height: 1.4),
                  decoration: InputDecoration(
                    hintText: "code",
                    suffix: Text("",style: TextStyle(fontWeight: FontWeight.w700),),
                    border: InputBorder.none,
                  ),
                  onChanged: (value){
                    if(value==widget.data['promo_code_name']){
                      UserMessage("The promotional code is correct. Discount ${ widget.data['promo_code_value'].toString() }% assigned", context);
                      widget.PromoIsCorrect(widget.data['promo_code_name'],widget.data['promo_code_value']);Navigator.pop(context);
                    }
                    if(widget.data.containsKey("promo_code_name2")) {
                      if(value==widget.data['promo_code_name2']){
                        UserMessage("The promotional code is correct. Discount ${ widget.data['promo_code_value2'].toString() }% assigned", context);
                        widget.PromoIsCorrect(widget.data['promo_code_name2'],widget.data['promo_code_value2']);Navigator.pop(context);
                      }
                    }
                    if(widget.data.containsKey("promo_code_name3")) {
                      if(value==widget.data['promo_code_name3']){
                        UserMessage("The promotional code is correct. Discount ${ widget.data['promo_code_value3'].toString() }% assigned", context);
                        widget.PromoIsCorrect(widget.data['promo_code_name3'],widget.data['promo_code_value3']);Navigator.pop(context);
                      }
                    }
                    if(widget.data.containsKey("promo_code_name4")) {
                      if(value==widget.data['promo_code_name4']){
                        UserMessage("The promotional code is correct. Discount ${ widget.data['promo_code_value4'].toString() }% assigned", context);
                        widget.PromoIsCorrect(widget.data['promo_code_name4'],widget.data['promo_code_value4']);Navigator.pop(context);
                      }
                    }
                    if(widget.data.containsKey("promo_code_name5")) {
                      if(value==widget.data['promo_code_name5']){
                        UserMessage("The promotional code is correct. Discount ${ widget.data['promo_code_value5'].toString() }% assigned", context);
                        widget.PromoIsCorrect(widget.data['promo_code_name5'],widget.data['promo_code_value5']);Navigator.pop(context);
                      }
                    }
                    if(widget.data.containsKey("promo_code_name6")) {
                      if(value==widget.data['promo_code_name6']){
                        UserMessage("The promotional code is correct. Discount ${ widget.data['promo_code_value6'].toString() }% assigned", context);
                        widget.PromoIsCorrect(widget.data['promo_code_name6'],widget.data['promo_code_value6']);Navigator.pop(context);
                      }
                    }
                    if(widget.data.containsKey("promo_code_name7")) {
                      if(value==widget.data['promo_code_name7']){
                        UserMessage("The promotional code is correct. Discount ${ widget.data['promo_code_value7'].toString() }% assigned", context);
                        widget.PromoIsCorrect(widget.data['promo_code_name7'],widget.data['promo_code_value7']);Navigator.pop(context);
                      }
                    }


                  },
                ),
              ),
            ),
            Text("Уведомление закроется если промокод будет верным"),
            // Text("Send money to the organizer and put special text (tap copy button) as a comment so that the organizer can add you to the roster"),
            // SizedBox(height: 12,),
            // Text(""),
            // Text("Instruction: "+widget.data['my_wallet_instructions']),


          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Close"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),

        ],
      ),
    );

    // if(result) {
    //
    // }


  }



  Future<bool> AddUserWhenMaxPeoplesDialog() async{
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.add_a_user_over_the_limit),
        // title: Text("Add a user over the limit"),
        content: Text(AppLocalizations.of(context)!.the_user_limit_is_full),
        // content: Text("The user limit is full. Do you want to add a user anyway?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            // child: Text("Cancel"),
            isDefaultAction: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.yes),
            // child: Text("Yes"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),

        ],
      ),
    );

    return result;

  }
}

class EventAddress extends StatefulWidget {
  final data;
  final russian_language;
  final is_user_in;
  final i_am_organizer;
  const EventAddress({Key? key,required this.data,required this.russian_language,required this.is_user_in,required this.i_am_organizer}) : super(key: key);

  @override
  State<EventAddress> createState() => _EventAddressState();
}

class _EventAddressState extends State<EventAddress> {
  bool AllowMySelfGeo=true; final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  bool AllowMap=false; final Set<Marker> _markers = new Set(); final Set<Marker> empty_markers = new Set(); final Set<Circle> circles = new Set(); final Set<Circle> circles_empty = new Set();

  CameraPosition _kGooglePlex = CameraPosition(target: LatLng(34.052235,-118.243683),   zoom: 14.4746,);
  bool HoldScreen=false;

  void OpenMap() async{
    if((widget.data as Map).containsKey("geo_point")){
      var _GeoPoint=(widget.data as Map)['geo_point'] as GeoPoint;
      final availableMaps = await MapLauncher.installedMaps;
      await availableMaps.first.showMarker(
        coords: Coords(_GeoPoint.latitude,_GeoPoint.longitude),
        title: widget.data['header'],
        description: widget.data['address'],
      );

    };

  }

  @override
  void initState() {


    InitMapSettings();

    // TODO: implement initState
    super.initState();
  }

  void InitMapSettings() {
    var widget_data=widget.data as Map;
    if(!widget_data['is_online']){
      var _GeoPoint=(widget.data as Map)['geo_point'] as GeoPoint;

      AllowMap=true;
      _kGooglePlex=CameraPosition(target: LatLng(_GeoPoint.latitude,_GeoPoint.longitude),   zoom: 14.4746,);
      _markers.clear();
      circles.clear();

      _markers.add(Marker(
        markerId: MarkerId("place.id"),
        position: LatLng(_GeoPoint.latitude,_GeoPoint.longitude),
        infoWindow: InfoWindow(
          title: widget.data['header'],
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));

      if((widget.data as Map)['aproximate_geo_point']!=""){
        var _GeoPointCircle=(widget.data as Map)['aproximate_geo_point'] as GeoPoint;
        if(!widget.is_user_in&&(widget.data as Map)["hide_exact_address"]&&!widget.i_am_organizer){
          print("Change");
          _kGooglePlex=CameraPosition(target: LatLng(_GeoPointCircle.latitude,_GeoPointCircle.longitude),   zoom: 14.4746,);
        }
        circles.add(
          Circle(
              circleId: CircleId("id"),
              center: LatLng(_GeoPointCircle.latitude,_GeoPointCircle.longitude),
              radius: 300,
              fillColor: Colors.black12,
              strokeWidth: 2,
              strokeColor: Colors.blueAccent
          ),
        );
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        physics: HoldScreen ? NeverScrollableScrollPhysics() : ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 96,),
            if(AllowMap) ...[
              Container(
                height: 300,
                width: MediaQuery.of(context).size.width-32,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    zoomControlsEnabled: false,
                    // zoomGesturesEnabled: false,
                    mapType: GM.MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: AllowMySelfGeo,
                    initialCameraPosition: _kGooglePlex,
                    gestureRecognizers: Set()..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    circles: widget.is_user_in ? circles_empty : ((widget.data as Map)["hide_exact_address"]) ? circles : circles_empty,
                    markers: !widget.is_user_in ? (widget.i_am_organizer||!(widget.data as Map)["hide_exact_address"] ? _markers : empty_markers) : _markers,

                  ),
                ),
              ),
              SizedBox(height: 24),
              if(widget.is_user_in) ButtonPro(AppLocalizations.of(context)!.show_on_map, (){ OpenMap(); }, false),
            ],
            SizedBox(height: 24,),
            if(widget.is_user_in) Text(AppLocalizations.of(context)!.address,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            // if(widget.is_user_in) Text("Addres",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            SizedBox(height: 8,),
            if(widget.is_user_in) Text(widget.russian_language&&widget.data['rus_address']!="" ? widget.data['rus_address'] : widget.data['address'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
            SizedBox(height: 16,),
            if(widget.data['location_info'].length!=0&&widget.is_user_in) ...[
              Text(AppLocalizations.of(context)!.location_info,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
              // Text("Location info",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
              SizedBox(height: 8,),
              Text(widget.russian_language&&widget.data['rus_location_info']!="" ? widget.data['rus_location_info'] : widget.data['location_info'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
              SizedBox(height: 16,),
            ],
            if(widget.data['parking_info'].length!=0&&widget.is_user_in)...[
              Text(AppLocalizations.of(context)!.parking_info,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
              // Text("Parking info",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
              SizedBox(height: 8,),
              Text(widget.russian_language&&widget.data['rus_parking_info']!=""? widget.data['rus_parking_info'] : widget.data['parking_info'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
            ],
            SizedBox(height: 36,),

          ],
        ),
      ),
    );
  }
}
