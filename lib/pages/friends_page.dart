import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';



class FriendListPage extends StatefulWidget {
  final need_to_add_friend;
  const FriendListPage({Key? key,required this.need_to_add_friend}) : super(key: key);

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {

  List FriendList=[];

  bool NoChat=false;

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  void GetFriends() async{

    FriendList = [];
    var MyData = await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var FriendsDocs = MyData.data()!['friends'];

    await Future.forEach(FriendsDocs, (friend_doc) async{
      var UserInfo=await firestore.collection("UsersCollection").doc((friend_doc as Map)!['phone']).get();

      FriendList.add({
        "name":UserInfo.data()!['nickname'],
        "phone":UserInfo.data()!['phone'],
        "last_message":"Online",
        "unreaded":false,
        "photo":UserInfo.data()!['avatar_link'],
        "id":(friend_doc as Map)!['phone'],
      });
    });


    setState(() {NoChat=FriendList.length==0 ? true : false; });
  }

  @override
  void initState() {
    GetFriends();

    // TODO: implement initState
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("Friends"),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height-100,
        padding: EdgeInsets.all(24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoSearchTextField(),
              SizedBox(height: 24,),
              FriendList.length==0&&NoChat==false ?
              Center(child: CupertinoActivityIndicator(color: Colors.black,)) :
              NoChat ?
              Text("No friends") :
              ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: FriendList.length,
                  itemBuilder: (context,index) {
                    return FriendCard(
                      Context: context,
                      Name: FriendList[index]["name"],
                      LastMessage: FriendList[index]["last_message"],
                      Img: FriendList[index]["photo"],
                      Phone: FriendList[index]["phone"],
                      DocId: FriendList[index]["id"],
                      NeedToAddFriend: widget.need_to_add_friend
                    );
                  },
                  separatorBuilder: (context,index) {
                    return Divider(height: 32,color: Colors.black45,);
                  },

              ),

            ]
        ),
      ),
      bottomNavigationBar: BottomNavBarPro(context,2),
    );
  }
}
