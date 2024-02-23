import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../../functions/user_functions.dart';
import '../../widgets/custom_route.dart';
import '../sign/welcome_page.dart';
import 'change_number.dart';
import 'edit_user_page.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({Key? key}) : super(key: key);

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {

  String NickName="";
  String Phone="";
  String City="Los Angeles";

  var MyEvents=[];
  var MyOrgEvents=[];


  bool IsAdmin=false;
  bool IsOrganaizer=false;
  bool RussianLanguage=false;
  bool ShowMyEventsForFriendsOnly=false;

  var balance=0;
  var userData=Map();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void GetData() async{
    var data=await firestore.collection("UsersCollection").doc(_auth.currentUser?.phoneNumber.toString()).snapshots().first;


    setState(() {
      NickName=data.get("nickname");
      Phone=data.get("phone");
      IsAdmin=data.get("admin");
      IsOrganaizer=data.get("role")==1;
      balance=data.get("balance");
      ShowMyEventsForFriendsOnly=data.get("show_events_for_friends_only");
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
    GetData();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro(AppLocalizations.of(context)!.settings),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: 16,),
                ListView.separated(
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  itemCount: 4,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index) {
                    switch (index){
                      case 0:
                        return ProfileButtons("User.svg",AppLocalizations.of(context)!.edit_account,(){
                          // return ProfileButtons("User.svg","Edit account",(){
                          final page = EditUserPage(appbar: AppLocalizations.of(context)!.edit_account, nickname: NickName, data: userData, is_admin: IsOrganaizer,);
                          Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                        });
                      case 1:
                        return ProfileButtons("World.svg",AppLocalizations.of(context)!.change_number,(){
                          // return ProfileButtons("World.svg","Change number",(){
                          final page = ChangeNumberPage();
                          Navigator.of(context).push(CustomPageRoute(page)).then((value) => GetData());
                        });
                      case 2:
                        return ProfileButtons("Exit.svg",AppLocalizations.of(context)!.sign_out,(){SignOut(context: context);});

                      case 3:
                        return ShowMyEventsForFriendsOnlyToggle(context);
                    }
                    return ProfileButtons("Exit.svg","Sign out",(){});

                  },
                  separatorBuilder: (context,index) {
                    return Divider(height: 32,color: Colors.black45,);
                  },
                ),
              ],
            ),
            if(!IsOrganaizer) Column(
              children: [
                GestureDetector(
                  onTap: (){DeleteAccount(context: context);},
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset("lib/assets/Icons/Light/Exit.svg",color: Colors.red,),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.delete_account,style: TextStyle(fontSize: 16,color: Colors.red,fontWeight: FontWeight.w600),),
                            SizedBox(width: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 36,),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row ShowMyEventsForFriendsOnlyToggle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset("lib/assets/Icons/Light/World.svg"),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.show_event_i_participate_only_for_friends,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            // Text("Show event I participate\nonly for friends",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
          ],
        ),
        CupertinoSwitch(
            value: ShowMyEventsForFriendsOnly,
            activeColor: PrimaryCol,
            onChanged: (value) {
              setState(() {ShowMyEventsForFriendsOnly=!ShowMyEventsForFriendsOnly;});
              firestore.collection("UsersCollection").doc(_auth.currentUser?.phoneNumber.toString()).update({
                "show_events_for_friends_only":ShowMyEventsForFriendsOnly
              });
            }
        ),
      ],
    );
  }
}
