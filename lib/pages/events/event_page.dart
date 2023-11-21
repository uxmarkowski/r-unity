import 'dart:async';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/add_event_page.dart';
import 'package:event_app/pages/chat/chat_page.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:event_app/widgets/app_bar.dart';
import 'package:event_app/widgets/bottom_nav_bar.dart';
import 'package:event_app/widgets/user_message.dart';
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
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../screens/card_form_screen.dart';
import '../../widgets/custom_route.dart';
import '../../widgets/event_page_functions.dart';
import '../friends_page.dart';



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
  int peoples_length=0;

  var EventUsersList=[]; var EventUsersWaitList=[]; var EventUsersInviteList=[]; var EventOrganizerList=[]; var EventUsersListData=[]; var MessageList=[];

  bool IsUserIn=false;
  bool IAmOrganizer=false;
  bool IAmAdmin=false;
  bool IAmInWaitList=false;
  bool IAmInvited=false;
  bool show_buttons=false;

  TextEditingController MessageController = TextEditingController();
  FocusNode MessageNode = FocusNode();


  void SendMessage(MessageList) async{
    firestore.collection("Events").doc(widget.data['doc_id']).update(
        {"messages":MessageList});
  }

  void GetAllMessage() async{
    var messages=await firestore.collection("Events").doc(widget.data['doc_id']).get();
    print("Получаем сообщения");
    UpDateMessage(messages);
  }

  void UpDateMessage(messages){
    MessageList=messages.data()!['messages'] as List;
    setState(() { });
  }

  void GetEventUsers() async{
    EventUsersListData=[]; EventOrganizerList=[]; EventUsersList=[]; EventUsersWaitList=[]; var EventUsersInviteList=[];

    var EventData=await firestore.collection("Events").doc(widget.data['doc_id']).get();
    var Mydata=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    if(Mydata["admin"]){setState(() {IAmAdmin=true;});}

    EventUsersList=EventData.data()!['users']; EventOrganizerList=EventData.data()!['organizers'];
    if((EventData.data() as Map).containsKey("wait_list")) EventUsersWaitList=EventData.data()!['wait_list'];
    if((EventData.data() as Map).containsKey("invited_users_list")) EventUsersInviteList=EventData.data()!['invited_users_list'];

    // await Future.forEach(EventOrganizerList, (element) async{
    //   if(element==_auth.currentUser!.phoneNumber){ setState(() {IsUserIn=true;});} // Проверка юзера на наличие в мероприятии
    // });

    await Future.forEach(EventUsersInviteList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IAmInvited=true;});} // Проверка себя на наличие в вейтлисте
    });

    await Future.forEach(EventUsersWaitList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IAmInWaitList=true;});} // Проверка себя на наличие в вейтлисте
      var data=await firestore.collection("UsersCollection").doc(element).get();
      var userdata=data.data();
      userdata!["role"]=-1;
      userdata!["doc_id"]=data.id;
      EventUsersListData.add(userdata);
    });

    await Future.forEach(EventOrganizerList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IAmOrganizer=true;});} // Проверка организатора на наличие в мероприятии
      var data=await firestore.collection("UsersCollection").doc(element).get();
      var userdata=data.data();
      userdata!["role"]=1;
      userdata!["doc_id"]=data.id;
      EventUsersListData.add(userdata);
    });


    await Future.forEach(EventUsersList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IsUserIn=true;});} // Проверка юзера на наличие в мероприятии
      var data=await firestore.collection("UsersCollection").doc(element).get();
      var userdata=data.data();
      userdata!["role"]=0;
      userdata!["doc_id"]=data.id;
      (EventUsersListData.any((user) => user['phone']==element)) // проверка себя в списке людей
          ?  null : EventUsersListData.add(userdata);
    });


    EventUsersListData.sort((a,b){
      if(a['role']>b['role']) return -1;
      return 1;
    });

    setState(() {show_buttons=true;});
  }

  void JoinButton(UserIn,DocId) async{
  bool pay_with_my_wallet=false; if((widget.data as Map).containsKey("pay_with_my_wallet")) pay_with_my_wallet=widget.data["pay_with_my_wallet"];

  var UserEventsDoc=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
  var UserEvents=(UserEventsDoc.data()!['events'] as List);

      if(UserIn){
        print("Удаление юзера (себя)");
        bool success=await DeleteMySelfDialog();
        if(success) success = await ChangeBalance(false,pay_with_my_wallet);
        if(success) {
          EventUsersList.removeWhere((element) => element==_auth.currentUser!.phoneNumber);
          EventUsersListData.removeWhere((element) => element['phone']==_auth.currentUser!.phoneNumber);
          EventUsersWaitList.removeWhere((element) => element==_auth.currentUser!.phoneNumber);
          UserEvents.removeWhere((element) => element==widget.data['doc_id']);
          setState(() {
            IsUserIn=false;
            IAmInWaitList=false;
            peoples_length=EventUsersList.length;
          });
          (widget.data['price']==0||pay_with_my_wallet) ? ScaffoldMessa("You left the event",context) : ScaffoldMessa("You left the event, your money has been returned",context);
        }

      } else if(!UserIn) {
        print("Добавление юзера (себя)");

        bool success=widget.data['price']!="0" ? // Мероприятие платное
        (pay_with_my_wallet ? // Оплатить
        await PayForOrganizerWallet() :
        await ChangeBalance(true,pay_with_my_wallet)
        ) :
        true; // Пустить

        if((success&&!pay_with_my_wallet)||IAmInvited){

          EventUsersList.add(_auth.currentUser!.phoneNumber);
          UserEvents.add(widget.data['doc_id']);
          setState(() {IsUserIn=!UserIn; peoples_length=EventUsersList.length;});
          ScaffoldMessa("You have been added to the event, welcome!",context);

        } else if(success&&pay_with_my_wallet){

          EventUsersWaitList.add(_auth.currentUser!.phoneNumber);
          setState(() { IAmInWaitList=true; });
          ScaffoldMessaLong("Thank you for your application, after payment wait for the organizer to accept you to the event. You will receive a notification",context);

        }
      }

    await firestore.collection("Events").doc(widget.data['doc_id']).update(
        {"users":EventUsersList,
          "peoples":EventUsersList.length,
          "wait_list":EventUsersWaitList,
          "invited_users_list":EventUsersInviteList,
        }); // Добавляем юзера в список

    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"events":UserEvents});
    GetEventUsers();

  }



  Future<bool> ChangeBalance(IsSpent,pay_with_my_wallet)async {


    var UserEventsDoc=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var UserBalance=UserEventsDoc.data()!['balance'];
    if(IsSpent){

      if(UserBalance>=int.parse(widget.data!['price'])){
        await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"balance":UserBalance-(int.parse(widget.data['price']))});
        return true;
      } else {

        var Lacking=int.parse(widget.data!['price'])-UserBalance;
        var OverLacking=int.parse(widget.data!['price'])-UserBalance;
        var result=await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("Please add \$$Lacking to your wallet"),
            content: null,
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
          var success=false;
          final page = CardFormScreen(type: "event",price: widget.data!['price'],);
          await Navigator.of(context).push(CustomPageRoute(page)).then((value) => success=value);
          if(success) {
            await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"balance":UserBalance-(int.parse(widget.data['price']))});
            return true;
          } else {
            return false;
          };
        }
      }

    } else {
      if(!pay_with_my_wallet) {
        await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"balance":UserBalance+(int.parse(widget.data['price']))});
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
        title: Text("Pay to organizer wallet"),
        content: Column(
          children: [
            SizedBox(height: 16),
            Text("Send money to the organizer and put your ID number as a comment so that the organizer can add you to the roster"),
            SizedBox(height: 12,),
            Text("Instruction: "+widget.data['my_wallet_instructions']),
            if(widget.data['my_wallet'].length!=0)...[
              SizedBox(height: 12,),
              Text("Organizer wallet: "+widget.data['my_wallet']),
            ],
            Divider(height: 32,color: Colors.black26,),
            Material(
              color: Color.fromRGBO(0, 0, 0, 0),
              child: InkWell(
                onTap: () async{
                  await Clipboard.setData(ClipboardData(text: DateTime.now().millisecondsSinceEpoch.toString()));
                  ScaffoldMessa("Text copied",context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ID "+DateTime.now().millisecondsSinceEpoch.toString()+"   ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
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
              child: Text("Pay link"),
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

  void AddUserFromWaitList(user_id) async{
    var EventData=await firestore.collection("Events").doc(widget.data['doc_id']).get();
    var _WaitList=EventData.data()!['wait_list'] as List;
    var _UsersList=EventData.data()!['users'] as List;
    int _EventUsersList=EventData.data()!['peoples'];

    _WaitList.removeWhere((element) => element==user_id);
    _UsersList.add(user_id);

    await firestore.collection("Events").doc(widget.data['doc_id']).update({"wait_list":_WaitList,"users":_UsersList,"peoples":_EventUsersList+1});
    SendAcceptNotification(data: widget.data, doc_id: user_id);
    GetEventUsers();
  }


  void DeleteUserDialog(user_id,organizer) async{
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Removing the user"),
        content: Text("Are you sure you want to delete a user?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Cancel"),
            isDefaultAction: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text("Yes"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),

        ],
      ),
    );

    if(result){
      DeleteUser(user_id, organizer);
    }
  }

  Future<bool> DeleteMySelfDialog() async{
    // bool reuslt=false;

    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Are you sure you want to get out from this event?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Cancel"),
            isDefaultAction: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text("Yes"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),

        ],
      ),
    );

    return result;
  }


  void DeleteUser(user_id,organizer) async{
    print("Удаление юзера");
    var UserEventsDoc=await firestore.collection("UsersCollection").doc(user_id).get();
    var UserEvents=(UserEventsDoc.data()!['events'] as List);

    SendDeleteNotification(doc_id: user_id,data: widget.data);

    EventUsersList.removeWhere((element) => element==user_id);
    EventUsersListData.removeWhere((element) => element['phone']==user_id);
    UserEvents.removeWhere((element) => element==widget.data['doc_id']);
    setState(() {peoples_length=EventUsersList.length;});

    await firestore.collection("Events").doc(widget.data['doc_id']).update({"users":EventUsersList,"peoples":EventUsersList.length}); // Добавляем юзера в список
    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
      "events":UserEvents,
      "balance":!organizer ? (int.parse(widget.data['price'])+UserEventsDoc.data()!['balance']) : UserEventsDoc.data()!['balance']
    });

  }





  @override
  void initState() {

    GetEventUsers();
    GetAllMessage();
    peoples_length=widget.data['peoples'];

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EventAppBarPro(title: widget.data['header'].toString(),data: widget.data),
      backgroundColor: groupValue!=2 ? Colors.white : Color.fromRGBO(236, 236, 242, 1),
      body: Stack(
        children: [
          if(groupValue==0) ...[
            EventDetails(data: widget.data,join_button:(doc_id){

              // PayForOrganizerWallet();
              // print(widget.data['doc_id']);

              if(IAmOrganizer){
                final page = AddEventPage(data: widget.data,is_new: false,);
                Navigator.of(context).push(CustomPageRoute(page));
              } else {
                JoinButton(IsUserIn||IAmInWaitList,doc_id);
              }
            }, peoples: peoples_length, IsUserIn: IsUserIn, IAmOrganizer: IAmOrganizer,IInWaitList: IAmInWaitList,show_buttons: show_buttons, IAmAdmin: IAmAdmin,),
          ] else if(groupValue==1) ...[
            ListView.separated(
                padding: EdgeInsets.only(top: 86,left: 16,right: 16), itemCount: EventUsersListData.length, shrinkWrap: true,
                separatorBuilder: (context,index){return Divider(height: 16,color: Colors.white,);},
                itemBuilder: (contex,index){
                  return EventUserCard(context, EventUsersListData[index]['nickname'], EventUsersListData[index]['role']==0 ? "Online" : EventUsersListData[index]['role']==1 ? "Organizer" : "Wait for accept", EventUsersListData[index]['avatar_link'], EventUsersListData[index]['doc_id'],IAmOrganizer,(){
                    // print(EventUsersListData[index]['doc_id']);
                    DeleteUserDialog(EventUsersListData[index]['doc_id'], EventUsersListData[index]['role']!=0);
                    // DeleteUser(EventUsersListData[index]['doc_id'],EventUsersListData[index]['role']!=0);
                  },(){
                    AddUserFromWaitList(EventUsersListData[index]['doc_id']);
                  });
                }
            ),
          ] else if(groupValue==2) ...[
            ChatWidget(MessageController: MessageController,MessageNode: MessageNode, MessageList: MessageList,SendMessage: (value){SendMessage(value);}, IsEventChat: true,),
          ] else if(groupValue==3) ...[
            EventAddress(data: widget.data,)
          ],
          Container(
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
                      0: buildSegment("Details"),
                      1: buildSegment("Users"),
                      2: buildSegment("Chat"),
                      3: buildSegment("Address"),
                    } : {
                      0: buildSegment("Details"),
                      1: buildSegment("Users"),
                      2: buildSegment("Chat"),
                    },
                    onValueChanged: (value){
                      setState(() {
                        groupValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget buildSegment(String text){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(text,style: TextStyle(fontSize: 15, color: Colors.black87,),),
    );
  }
}



class EventDetails extends StatefulWidget {
  final data;
  final IsUserIn;
  final IAmOrganizer;
  final IAmAdmin;
  final IInWaitList;
  final peoples;
  Function(String) join_button;
  final show_buttons;
  EventDetails({Key? key,required this.data,required this.IsUserIn,required this.peoples,required this.join_button,required this.IAmOrganizer,required this.IAmAdmin,required this.IInWaitList,required this.show_buttons}) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool IsApproved=false;

  OrderHasBeenPlaced(){
    print("sts");
    TextEditingController LinkController=TextEditingController();
    FocusNode LinkNode=FocusNode();

    showCupertinoModalPopup(
      // useRootNavigator: true,
        barrierDismissible: true,
        filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
        barrierColor: Colors.black.withOpacity(0.7),
        context: context,
        builder: (BuildContext builder) {
          return CupertinoPopupSurface(
            isSurfacePainted: false,
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height-150,
              width: double.infinity,
              child: Material(
                color: Colors.white,
                child: CarouselSlider(
                  options: CarouselOptions(height: MediaQuery.of(context).size.height-150,aspectRatio: 16/12),
                  items: ((widget.data as Map)['additional_photo_links'] as List<dynamic>).map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            // margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                                // borderRadius: BorderRadius.circular(12),
                                color: Colors.black12
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey3,
                                  // borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                      image: NetworkImage(i),
                                      fit: BoxFit.cover
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
          );
        }
    ).then((value) => setState((){print("s");}));
  }

  bool big=false;

  @override
  void initState() {
    if((widget.data as Map).containsKey("approved")){
      IsApproved=widget.data['approved'];
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 72,),

          if(!(widget.data as Map).containsKey("additional_photo_links"))...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              height: 160,
              decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey3,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                      image: NetworkImage(widget.data['photo_link']),fit: BoxFit.cover
                  )
              ),
            ),
          ],
            if((widget.data as Map).containsKey("additional_photo_links"))...[
              if((widget.data as Map)['additional_photo_links'].length!=0)...[
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
                      items: ((widget.data as Map)['additional_photo_links'] as List<dynamic>).map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.black12
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: CupertinoColors.black,
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
                          color: CupertinoColors.systemGrey3,
                          image: DecorationImage(
                              image: NetworkImage(widget.data['photo_link']),fit: BoxFit.cover
                          )
                      ),
                    ),
                  ),
                ),
              ]
            ],
            SizedBox(height: 24,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.data['header'],style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700,height: 1.4),),
                  Divider(height: 32,color: Colors.black26,),
                  Row(
                    children: [
                      IconText(DateTime.fromMillisecondsSinceEpoch(widget.data['date']).hour.toString()+":"+(DateTime.fromMillisecondsSinceEpoch(widget.data['date']).minute>9 ? DateTime.fromMillisecondsSinceEpoch(widget.data['date']).minute.toString() : "0"+DateTime.fromMillisecondsSinceEpoch(widget.data['date']).minute.toString() )+
                          " | "+widget.data['duration'].toString()+" min.","TimeSquare.svg"),
                      SizedBox(width: 16,),
                      widget.data['price']=="0" ? IconText("Free".toString(),"Wallet.svg") :
                      IconText("\$"+widget.data['price'].toString(),"Wallet.svg"),
                      SizedBox(width: 16,),
                      IconText(widget.peoples.toString()+"/"+widget.data['max_peoples'].toString(),"Users.svg"),
                    ],
                  ),
                  // Divider(height: 32,color: Colors.black26,),
                  // Wrap(
                  //   spacing: 12,
                  //   runSpacing: 8,
                  //   children: [
                  //     for(var item in widget.data['tags']) TagPro(item)
                  //   ],
                  // ),
                  Divider(height: 32,color: Colors.black26,),
                  if(widget.show_buttons) ...[
                    Row(
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
                                child: Text(widget.IAmOrganizer ? "Edit" : // Я организатор?
                                widget.IsUserIn||widget.IInWaitList ? // Я внутри?
                                "Leave" : // Выйти
                                "Join", // Войти
                                  style: TextStyle(fontSize: 16,color: Colors.white),),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12,),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              final page = FriendListPage(need_to_add_friend: true);
                              Navigator.of(context).push(CustomPageRoute(page)).then((value) => print(value));
                            },
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black
                              ),
                              child: Center(
                                child: Text("Add friend",style: TextStyle(fontSize: 16,color: Colors.white),),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if(widget.IAmAdmin) ...[
                    SizedBox(height: 12,),
                    InkWell(
                      onTap: () async{
                        setState(() {
                          IsApproved=true;
                        });
                        await firestore.collection("Events").doc(widget.data['doc_id']).update({"approved":true});
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black
                        ),
                        child: Center(
                          child: Text(!IsApproved ? "Approve" : "Successfully approved",style: TextStyle(fontSize: 16,color: Colors.white),),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 24,),
                  Text("About",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                  SizedBox(height: 12,),
                  Text(widget.data['about'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.5),),
                  if((widget.data as Map).containsKey("header1"))...[
                    SizedBox(height: 24,),
                    Text(widget.data['header1'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                    SizedBox(height: 12,),
                    Text(widget.data['about1'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.5),),
                  ],
                  if((widget.data as Map).containsKey("header2"))...[
                    SizedBox(height: 24,),
                    Text(widget.data['header2'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                    SizedBox(height: 12,),
                    Text(widget.data['about2'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.5),),
                  ],
                  SizedBox(height: 24,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EventAddress extends StatefulWidget {
  final data;
  const EventAddress({Key? key,required this.data}) : super(key: key);

  @override
  State<EventAddress> createState() => _EventAddressState();
}

class _EventAddressState extends State<EventAddress> {
  bool AllowMySelfGeo=true; final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  bool AllowMap=false; final Set<Marker> _markers = new Set();
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

    if((widget.data as Map).containsKey("geo_point")){
      var _GeoPoint=(widget.data as Map)['geo_point'] as GeoPoint;
      AllowMap=true;
      _kGooglePlex=CameraPosition(target: LatLng(_GeoPoint.latitude,_GeoPoint.longitude),   zoom: 14.4746,);


      _markers.add(Marker(
        markerId: MarkerId("place.id"),
        position: LatLng(_GeoPoint.latitude,_GeoPoint.longitude),
        infoWindow: InfoWindow(
          title: widget.data['header'],
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    }
    setState(() {

    });
    // TODO: implement initState
    super.initState();
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
                    // polygons: _polygon,
                    markers: Set<Marker>.of(_markers as Iterable<Marker>),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ButtonPro("Показать на карте", (){
                OpenMap();
              }, false),
            ],
            SizedBox(height: 24,),
            Text("Addres",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            SizedBox(height: 8,),
            Text(widget.data['address'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
            SizedBox(height: 16,),
            if(widget.data['location_info'].length!=0)...[
              Text("Location info",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
              SizedBox(height: 8,),
              Text(widget.data['location_info'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
              SizedBox(height: 16,),
            ],
            if(widget.data['parking_info'].length!=0)...[
              Text("Parking info",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
              SizedBox(height: 8,),
              Text(widget.data['parking_info'],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black54,height: 1.4),),
            ]

          ],
        ),
      ),
    );
  }
}
