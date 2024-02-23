import 'dart:io';
import 'package:event_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/add_event_page.dart';
import 'package:event_app/pages/user/edit_user_page.dart';
import 'package:event_app/pages/events/event_list_page.dart';
import 'package:event_app/pages/user/notification_page.dart';
import 'package:event_app/pages/sign/sign_in.dart';
import 'package:event_app/pages/sign/sign_up_photo.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:event_app/pages/user/settings.dart';
import 'package:event_app/screens/card_form_screen.dart';
import 'package:event_app/widgets/voice_mes/user_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instant/instant.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../functions/hive_model.dart';
import '../../functions/user_functions.dart';
import '../../main.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_route.dart';
import '../../widgets/local_notification_servise.dart';
import 'become organizer.dart';
import 'change_number.dart';
import 'edit_categories_page.dart';
import 'friends_page.dart';
import '../global_variables.dart';
import 'organizers_applications.dart';



class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;



  String NickName="";
  String Phone="";
  String City="Los Angeles";

  var MyEvents=[];
  var MyOrgEvents=[];


  bool IsAdmin=false;
  bool RussianLanguage=false;
  bool ShowMyEventsForFriendsOnly=false;

  int balance=0;
  int role=0;

  bool verified=false;

  var userData=Map();

  late final LocalNotificationService service; // Сервис
  var model = hive_example();

  void GetLanguage() async{
    print("Local "+AppLocalizations.of(context)!.localeName);
    setState(() {RussianLanguage=AppLocalizations.of(context)!.localeName=="ru";});

  }

  void GetData() async{
    var data=await firestore.collection("UsersCollection").doc(_auth.currentUser?.phoneNumber.toString()).snapshots().first;


    setState(() {
      NickName=data.get("nickname");
      Phone=data.get("phone");
      IsAdmin=data.get("admin");
      role=data.get("role");
      verified=data.get("verified");
      balance=data.get("balance");
      ShowMyEventsForFriendsOnly=data.get("show_events_for_friends_only");
      City=data.get("city");
    });

    userData={
      "nickname":data.get("nickname"),
      "firstname":data.get("firstname"),
      "lastname":data.get("lastname"),
      "about":data.get("about"),
      "instagram":data.get("instagram"),
    };

    print("User data "+userData.toString());
  }


  @override
  void initState() {
    service = LocalNotificationService();
    service.intialize();
    GetData();

    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500)).then((value) => GetLanguage());
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
                      // print(DateTime.now().toString());
                      // print(dateTimeToZone(zone: "PST", datetime: DateTime.now()));
                      // print(dateTimeToZone(zone: "EST", datetime: DateTime.now()));

                      final page = OptionsPage();
                      Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());

                      // firestore.collection("UsersCollection").doc("+17148555075").update({"role":0});

                      // var EvColl=await firestore.collection("UsersCollection").get();
                      // EvColl.docs.forEach((element) {
                      //   firestore.collection("UsersCollection").doc(element.id).update({"verified":false});
                      // });

                      // await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
                      //   "verified": true,
                      // });

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BigTextCenter(NickName),
                    SizedBox(width: 4,),
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 2),
                    //   child: Icon(CupertinoIcons.star_fill,color: PrimaryCol,size: 20,),
                    // ),
                  ],
                ),
                SizedBox(height: 4),
                InkWell(
                  onTap: (){
                    final page = CardFormScreen(type: "balance",price: "0");
                    Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                  },
                    child: Text(AppLocalizations.of(context)!.balance+": "+balance.toString()+"\$",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 16),)
                    // child: Text("Balance: "+balance.toString()+"\$",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w600,fontSize: 16),)
                ),
                SizedBox(height: 36,),
                ProfileButtons("tabler_users.svg",AppLocalizations.of(context)!.friends,(){
                  final page = FriendListPage(need_to_add_friend: false,);
                  Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());}),
                Divider(height: 32,color: Colors.black45),
                ProfileButtons("tabler_users.svg",AppLocalizations.of(context)!.become_organizer,(){
                  final page = BecomeOrganizer();
                  Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());}),
                Divider(height: 32,color: Colors.black45),
                ProfileButtons("tabler_users.svg",AppLocalizations.of(context)!.get_safe_badge,(){
                  RequestSafeBadge(context: context);}),
                Divider(height: 32,color: Colors.black45),
                if(IsAdmin) ProfileButtons("tabler_users.svg",AppLocalizations.of(context)!.organizer_applications,(){
                  final page = OrganizersApplications();
                  Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());}),
                if(IsAdmin) Divider(height: 32,color: Colors.black45,),
                ProfileButtons("Event.svg",AppLocalizations.of(context)!.my_events,(){
                  final page = EventListPage(IsMyEvents: true, IsMyOrganizerEvents: false, ApproveWidgets: false,);
                  Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());}),
                Divider(height: 32,color: Colors.black45,),
                if(role==1) ProfileButtons("Event.svg",AppLocalizations.of(context)!.my_created_events,(){
                  final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: true, ApproveWidgets: false,);
                  Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());}),
                if(role==1) Divider(height: 32,color: Colors.black45,),

                if(role==1) ProfileButtons("Event.svg",AppLocalizations.of(context)!.add_event,(){
                  final page = AddEventPage(data: null,is_new: true, is_dublicate: false,);
                  Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());}),

                if(IsAdmin) Divider(height: 32,color: Colors.black45,),

                if(IsAdmin) ProfileButtons("Event.svg",AppLocalizations.of(context)!.approve_events,(){
                  final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: true,);
                  Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                }),

                if(role==1) Divider(height: 32,color: Colors.black45,),

                ProfileButtons("Mail.svg",AppLocalizations.of(context)!.invite_your_friends,() async{
                  await FlutterShare.share(title: 'Join me on R-Unity', text: 'Download R-Unity and text me!',);}),

                Divider(height: 32,color: Colors.black45,),

                ProfileButtons("World.svg",(RussianLanguage ? "Город:":"City:")+((City=="Los Angeles" ? " Los Angeles" : " New York")),() async{
                  // setState(() {City=City!="Los Angeles" ? "Los Angeles" : "New York";});
                  firestore.collection("UsersCollection").doc(_auth.currentUser?.phoneNumber.toString()).update({
                    "city":City=="Los Angeles" ? "Los Angeles" : "New York"});}),

                Divider(height: 32,color: Colors.black45,),

                ProfileButtons("World.svg",(RussianLanguage ? "Русский":"English")+(RussianLanguage ? " язык":" language"),() async{
                  setState(() {
                    MyApp.of(context)!.setLocale(Locale.fromSubtags(languageCode: RussianLanguage? 'en' : 'ru'));
                    RussianLanguage=!RussianLanguage;
                    model.SaveLanguage(RussianLanguage ? "ru":"en");
                  });}),
                if(IsAdmin) Divider(height: 32,color: Colors.black45,),
                if(IsAdmin) ProfileButtons("World.svg",AppLocalizations.of(context)!.categories,(){
                  // return ProfileButtons("World.svg","Categories",(){
                  final page = EditCategoriesPage(appbar: "Categories", nickname: "null",);
                  Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());}),
                Divider(height: 32,color: Colors.black45,),
                ProfileButtons("World.svg","Terms of use",() async{
                  const url = 'http://r-unity.tilda.ws/terms_of_use';
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {await launchUrl(uri);} else {throw 'Could not launch $url';}}),
              ]
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBarPro(context,2),
    );
  }


  void RequestSafeBadge({required context}) async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;


    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.attention),
        content: Text(AppLocalizations.of(context)!.verification_includes_id_verification),
        // content: Text("This will delete your account data, including your responses and ratings."),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.cancel),
            // child: Text("Cancel"),

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

      await firestore.collection("SafeBadgeRequests").add({
        "Phone":_auth.currentUser!.phoneNumber.toString(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.thanks_for_the_request_we_will.toString()),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ));
    }
  }
}
