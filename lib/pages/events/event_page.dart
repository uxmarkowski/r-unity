import 'dart:async';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/add_event_page.dart';
import 'package:event_app/pages/chat/chat_page.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:event_app/widgets/app_bar.dart';
import 'package:event_app/widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GM;
import 'package:map_launcher/map_launcher.dart';

import '../../screens/card_form_screen.dart';
import '../../widgets/custom_route.dart';
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

  var EventUsersList=[]; var EventUsersWaitList=[]; var EventOrganizerList=[]; var EventUsersListData=[]; var MessageList=[];

  bool IsUserIn=false;
  bool IAmOrganizer=false;
  bool IAmAdmin=false;
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
    EventUsersListData=[]; EventOrganizerList=[]; EventUsersList=[]; EventUsersWaitList=[];

    var EventData=await firestore.collection("Events").doc(widget.data['doc_id']).get();
    var Mydata=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    if(Mydata["admin"]){setState(() {IAmAdmin=true;});}

    EventUsersList=EventData.data()!['users']; EventOrganizerList=EventData.data()!['organizers'];
    if((EventData.data() as Map).containsKey("wait_list")) EventUsersWaitList=EventData.data()!['wait_list'];

    // await Future.forEach(EventOrganizerList, (element) async{
    //   if(element==_auth.currentUser!.phoneNumber){ setState(() {IsUserIn=true;});} // Проверка юзера на наличие в мероприятии
    // });

    await Future.forEach(EventUsersWaitList, (element) async{
      var data=await firestore.collection("UsersCollection").doc(element).get();
      var userdata=data.data();
      userdata!["role"]=-1;
      userdata!["doc_id"]=data.id;
      EventUsersListData.add(userdata);
    });

    await Future.forEach(EventOrganizerList, (element) async{
      if(element==_auth.currentUser!.phoneNumber){ setState(() {IAmOrganizer=true;});} // Проверка юзера на наличие в мероприятии
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
      (EventUsersListData.any((user) => user['phone']==element)) // проверка себя в списке организаторов
      // (element==_auth.currentUser!.phoneNumber&&IAmOrganizer) // проверка себя в списке организаторов
          ?  null : EventUsersListData.add(userdata);
    });


    EventUsersListData.sort((a,b){
      if(a['role']>b['role']) return -1;
      return 1;
    });

    setState(() {show_buttons=true;});
  }

  void JoinButton(UserIn) async{
  bool pay_with_my_wallet=false;

  var UserEventsDoc=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
  var UserEvents=(UserEventsDoc.data()!['events'] as List);
  if((widget.data as Map).containsKey("pay_with_my_wallet")) pay_with_my_wallet=widget.data["pay_with_my_wallet"];

    // if(EventUsersList.length!=0){
      if(UserIn){
        print("Удаление юзера");
        bool success=await ChangeBalance(false,pay_with_my_wallet);
        if(success){
          EventUsersList.removeWhere((element) => element==_auth.currentUser!.phoneNumber);
          EventUsersListData.removeWhere((element) => element['phone']==_auth.currentUser!.phoneNumber);
          UserEvents.removeWhere((element) => element==widget.data['doc_id']);
          setState(() {
            IsUserIn=!UserIn;
            peoples_length=EventUsersList.length;
          });
          widget.data['price']!=0 ? ScaffoldMessa("You left the event, your money has been returned") : ScaffoldMessa("You left the event");
        }

      } else {
        print("Добавление юзера");

        bool success=widget.data['price']!="0" ? await ChangeBalance(true,pay_with_my_wallet) : true;

        if(success){

          EventUsersList.add(_auth.currentUser!.phoneNumber);
          UserEvents.add(widget.data['doc_id']);
          setState(() {
            IsUserIn=!UserIn;
            peoples_length=EventUsersList.length;
          });
          ScaffoldMessa("You have been added to the event, welcome!");
        }

      }


    await firestore.collection("Events").doc(widget.data['doc_id']).update({"users":EventUsersList,"peoples":EventUsersList.length}); // Добавляем юзера в список
    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"events":UserEvents});
    GetEventUsers();

  }




  void ScaffoldMessa(message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: PrimaryCol,
    ));
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

      await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"balance":UserBalance+(int.parse(widget.data['price']))});
      return true;
    }

    return false;

  }

  Future<bool> PayForOrganizerWallet(IsSpent,pay_with_my_wallet)async {


    var UserEventsDoc=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Send money to organizer wallet and wait for accept"),
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

        return true;
      } else {
        return false;
      };
    }

    return false;

  }

  void DeleteUser(user_id,organizer) async{
    print("Удаление юзера");
    var UserEventsDoc=await firestore.collection("UsersCollection").doc(user_id).get();
    var UserEvents=(UserEventsDoc.data()!['events'] as List);

    SendDeleteNotification(user_id);

    EventUsersList.removeWhere((element) => element==_auth.currentUser!.phoneNumber);
    EventUsersListData.removeWhere((element) => element['phone']==_auth.currentUser!.phoneNumber);
    UserEvents.removeWhere((element) => element==widget.data['doc_id']);
    setState(() {peoples_length=EventUsersList.length;});

    await firestore.collection("Events").doc(widget.data['doc_id']).update({"users":EventUsersList,"peoples":EventUsersList.length}); // Добавляем юзера в список
    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
      "events":UserEvents,
      "balance":!organizer ? (int.parse(widget.data['price'])+UserEventsDoc.data()!['balance']) : UserEventsDoc.data()!['balance']
    });

  }

  void SendDeleteNotification(doc_id) async{

    await firestore.collection("UsersCollection").doc(doc_id).collection("Notifications").add(
        {
          "title":"The organizer has removed you from the "+widget.data["header"]+". The money has been refunded to the balance",
          "photo_link": widget.data["photo_link"].toString(),
          "type":"delete_notification",
          "check":false,
          "date":DateTime.now().millisecondsSinceEpoch
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
      appBar: AppBarPro(widget.data['header'].toString()),
      backgroundColor: groupValue!=2 ? Colors.white : Color.fromRGBO(236, 236, 242, 1),
      body: Stack(
        children: [
          if(groupValue==0) ...[
            EventDetails(data: widget.data,join_button:(){
              if(IAmOrganizer){
                final page = AddEventPage(data: widget.data,is_new: false,);
                Navigator.of(context).push(CustomPageRoute(page));
              } else {
                JoinButton(IsUserIn);
              }
            }, peoples: peoples_length, IsUserIn: IsUserIn, IAmOrganizer: IAmOrganizer,show_buttons: show_buttons, IAmAdmin: IAmAdmin,),
          ] else if(groupValue==1) ...[
            ListView.separated(
                padding: EdgeInsets.only(top: 86,left: 16,right: 16), itemCount: EventUsersListData.length, shrinkWrap: true,
                separatorBuilder: (context,index){return Divider(height: 16,color: Colors.white,);},
                itemBuilder: (contex,index){
                  return EventUserCard(context, EventUsersListData[index]['nickname'], EventUsersListData[index]['role']==0 ? "Online" : "Organizer", EventUsersListData[index]['avatar_link'], EventUsersListData[index]['doc_id'],IAmOrganizer,(){
                    DeleteUser(EventUsersListData[index]['doc_id'],EventUsersListData[index]['role']!=0);
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
  final peoples;
  Function() join_button;
  final show_buttons;
  EventDetails({Key? key,required this.data,required this.IsUserIn,required this.peoples,required this.join_button,required this.IAmOrganizer,required this.IAmAdmin,required this.show_buttons}) : super(key: key);

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
                                      color: CupertinoColors.systemGrey3,
                                      borderRadius: BorderRadius.circular(12),
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
              ] else ...[
                FullScreenWidget(
                  disposeLevel: DisposeLevel.Medium,
                  backgroundIsTransparent: true,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    height: 160,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: CupertinoColors.systemGrey3,
                        image: DecorationImage(
                            image: NetworkImage(widget.data['photo_link']),fit: BoxFit.cover
                        )
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
                              widget.join_button();
                            },
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black
                              ),
                              child: Center(
                                child: Text(widget.IAmOrganizer ? "Edit" : widget.IsUserIn ? "Leave" : "Join",style: TextStyle(fontSize: 16,color: Colors.white),),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12,),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              final page = FriendListPage();
                              Navigator.of(context).push(CustomPageRoute(page));
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
                        await firestore.collection("Events").doc(widget.data['doc_id']).update({"approved":true});
                        setState(() {
                          IsApproved=true;
                        });
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
