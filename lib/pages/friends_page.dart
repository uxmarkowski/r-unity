import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';



class FriendListPage extends StatefulWidget {
  const FriendListPage({Key? key}) : super(key: key);

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {

  List FriendList=[];

  bool NoChat=false;

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  Future <bool> CheckReadedOrNot(ChatInfo) async{
    await Future.forEach(ChatInfo.data()!['messages'], (message) {
      if((message as Map)!['user']!=_auth.currentUser&&(message as Map).containsKey("status")){
        if((message as Map)!['status']=="sent"){
          return true;
        };
      }
    });

    return false;
  }

  void GetFriends() async{

    FriendList = [];
    var MyData = await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var FriendsDocs = MyData.data()!['friends'];

    await Future.forEach(FriendsDocs, (friend_doc) async{
      // var ChatInfo=await firestore.collection("Chats").doc(doc as String?).get();
      // var UnReaded=await CheckReadedOrNot(ChatInfo);
      // var LastMessage=(ChatInfo.data()!['messages'] as List).where((element) => element['user']!=_auth.currentUser&&!(element['message'].toString().startsWith("http"))).last['message'];
      //
      // var UserrDoc=ChatInfo.data()!['getter']==_auth.currentUser!.phoneNumber ? ChatInfo.data()!['sender'] : ChatInfo.data()!['getter'];
      var UserInfo=await firestore.collection("UsersCollection").doc((friend_doc as Map)!['phone']).get();

      // var NewDocData=doc.data(); NewDocData['doc_id']=doc.id;
      // ChatList.add(NewDocData);

      FriendList.add({
        "name":UserInfo.data()!['nickname'],
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
                    return FriendCard(context,FriendList[index]["name"],FriendList[index]["last_message"],FriendList[index]["photo"],FriendList[index]["id"],);
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
