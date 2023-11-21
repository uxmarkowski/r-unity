import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/add_event_page.dart';
import 'package:event_app/pages/edit_user_page.dart';
import 'package:event_app/pages/events/event_list_page.dart';
import 'package:event_app/pages/notification_page.dart';
import 'package:event_app/pages/sign/sign_in.dart';
import 'package:event_app/pages/sign/sign_up_photo.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:event_app/screens/card_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_route.dart';
import '../widgets/local_notification_servise.dart';
import 'friends_page.dart';
import 'global_variables.dart';



class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  var NickName="";
  var MyEvents=[];
  var MyOrgEvents=[];
  var Phone="";
  var IsAdmin=false;
  var RussianLanguage=false;
  var balance=0;

  void SignOut() async{
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Log out"),
        content: Text("Are you sure you want to log out?"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Cancel"),

            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text("OK"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if(result) {
      await _auth.signOut();
      final page = SignInPage();
      Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
    }
  }

  void DeleteAccount() async{

    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Attention"),
        content: Text("This will delete your account data, including your responses and ratings."),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Cancel"),

            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text("OK"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if(result) {
      // await storageRef.child(AvatarLinkPath).delete();

      var UserNomber=_auth.currentUser?.phoneNumber.toString();
      await firestore.collection("UsersCollection").doc(UserNomber).delete();

      _auth.currentUser?.delete();

      final page = WelcomePage();
      Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
    }
  }

  void GetData() async{
    var data=await firestore.collection("UsersCollection").doc(_auth.currentUser?.phoneNumber.toString()).snapshots().first;
    setState(() {
      NickName=data.get("nickname");
      Phone=data.get("phone");
      IsAdmin=data.get("admin");

      balance=data.get("balance");
    });
  }

  late final LocalNotificationService service; // Сервис

  @override
  void initState() {
    service = LocalNotificationService();
    service.intialize();
    GetData();

    // TODO: implement initState
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    // final globalData = GlobalData.of(context).data;
    final globalProvider = Provider.of<GlobalProvider>(context);
    final UnreadedNotifcations = globalProvider.notifications_lenght_get;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 56,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ProfileButton("Setting.svg",() async{



                      await firestore.collection("UsersCollection").doc("+79788759240").update({
                        "balance":1,
                      });


                    },0),
                    InkWell(
                      onTap: (){
                        final page = SignUpPhotoPage(nomber: Phone,type: "Edit",);
                        Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                      },
                      child: Stack(
                        children: [
                          Positioned(
                              child: ProfileAvatar(_auth.currentUser!.phoneNumber),
                            top: 5,
                            left: 5,
                          ),
                          SvgPicture.asset("lib/assets/AddPhotoBackLine.svg",width: 110,),
                        ],
                      ),
                    ),
                    ProfileButton("Notification.svg",(){
                      final page = NotificationPage();
                      Navigator.of(context).push(CustomPageRoute(page));
                    },UnreadedNotifcations),
                  ],
                ),
                SizedBox(height: 24,),
                InkWell(
                  onTap: (){
                    // globalProvider.updateData(2);
                  },
                    child: BigTextCenter(NickName)
                    // child: BigTextCenter(NickName+globalData.toString())
                ),
                SizedBox(height: 4),
                // Text(Phone,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 16),),
                InkWell(
                  onTap: (){
                    final page = CardFormScreen(type: "balance",price: "0");
                    Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                  },
                    child: Text("Balance: "+balance.toString()+"\$",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 16),)
                ),
                SizedBox(height: 36,),

                ListView.separated(
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    itemCount: 10,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context,index) {
                      switch (index){
                        case 0:
                          return ProfileButtons("User.svg","Edit account",(){
                            final page = EditUserPage(appbar: "Edit account");
                            Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                          });
                          case 1:
                          return ProfileButtons("tabler_users.svg","Friends",(){
                            final page = FriendListPage(need_to_add_friend: false,);
                            Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                          });
                        case 2:
                          return ProfileButtons("Event.svg","My events",(){
                            final page = EventListPage(IsMyEvents: true, IsMyOrganizerEvents: false, ApproveWidgets: false,);
                            Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                          });
                          case 3:
                          return ProfileButtons("Event.svg","My created events",(){
                            final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: true, ApproveWidgets: false,);
                            Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                          });
                        case 4:
                          return ProfileButtons("Event.svg","Add event",(){
                            final page = AddEventPage(data: null,is_new: true,);
                            Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                          });
                        case 5:
                          return ProfileButtons("Event.svg","Approve events",(){
                            final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: true,);
                            Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                          });
                        case 6:
                          return ProfileButtons("Mail.svg","Invite Your Friends",() async{
                            await FlutterShare.share(
                                title: 'Join me on EventApp',
                                text: 'Download EventApp and text me!',
                                // linkUrl: Platform.isAndroid ? 'https://play.google.com/store/apps/details?id=app.soulmatcher' : 'https://apps.apple.com/us/app/soulmatcher/id1668358918',
                                // chooserTitle: 'Join me on SoulMatcher'
                            );
                          });
                        case 7:
                          return ProfileButtons("World.svg",(RussianLanguage ? "Russian":"English")+" language",() async{
                            setState(() {
                              RussianLanguage=!RussianLanguage;
                            });
                          });
                        case 8:
                          return ProfileButtons("Exit.svg","Sign out",(){SignOut();});

                        case 9:
                          return ProfileButtons("Exit.svg","Delete account",(){DeleteAccount();});
                      }
                      return ProfileButtons("Exit.svg","Sign out",(){});

                    },
                    separatorBuilder: (context,index) {
                      return Divider(height: 32,color: Colors.black45,);
                    },
                ),

              ]
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBarPro(context,2),
    );
  }
}
