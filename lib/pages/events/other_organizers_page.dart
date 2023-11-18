import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';



class OtherOrganizersPage extends StatefulWidget {
  const OtherOrganizersPage({Key? key}) : super(key: key);

  @override
  State<OtherOrganizersPage> createState() => _OtherOrganizersPageState();
}

class _OtherOrganizersPageState extends State<OtherOrganizersPage> {

  List OrganizersList=[];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void GetOrganizers() async {

    OrganizersList = [];
    var Data = await firestore.collection("UsersCollection").get();
    var MyData = await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var Friends = MyData.data()!["friends"] as List;
    print(Friends.toString());
    var OrganizersDocs = Data.docs;

    await Future.forEach(OrganizersDocs, (doc) async{

      var UserInfo=await firestore.collection("UsersCollection").doc(doc.id).get();


      if(UserInfo.data()!['role']==1&&(_auth.currentUser!.phoneNumber!=UserInfo.id)&&Friends.where((element) => element['phone']==doc.id).length>0){
        OrganizersList.add({
          "name":UserInfo.data()!['nickname'],
          "status":"status",
          "photo":UserInfo.data()!['avatar_link'],
          "id":doc,
          "phone":UserInfo.id,
        });
      }

    });
    setState(() { });
  }

  @override
  void initState() {
    GetOrganizers();

    // TODO: implement initState
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("Friends organizers"),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height-100,
        padding: EdgeInsets.all(24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoSearchTextField(),
              SizedBox(height: 24,),
              OrganizersList.length==0 ?
              Center(child: CupertinoActivityIndicator(color: Colors.black,) ):
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: OrganizersList.length,
                itemBuilder: (context,index) {
                  return AddOrganizerCard(context,OrganizersList[index]["name"],"Organizer",OrganizersList[index]["photo"],(){
                    Navigator.pop(context,OrganizersList[index]);
                  },"Plus");
                },
                separatorBuilder: (context,index) {
                  return Divider(height: 32,color: Colors.black45,);
                },

              ),

            ]
        ),
      ),
      bottomNavigationBar: BottomNavBarPro(context,1),
    );
  }
}
