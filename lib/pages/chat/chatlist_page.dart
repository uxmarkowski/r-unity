import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';



class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  List ChatList=[];

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

  void GetChats() async{

    ChatList = [];
    var MyData = await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var ChatsDocs = MyData.data()!['friends'];

    await Future.forEach(ChatsDocs, (doc) async{
      var ChatInfo=await firestore.collection("Chats").doc((doc as Map)!['chat'] as String?).get();
      var UnReaded=await CheckReadedOrNot(ChatInfo);
      var LastMessage= (ChatInfo.data()!['messages'] as List).length==0 ? "" : (ChatInfo.data()!['messages'] as List).where((element) => element['user']!=_auth.currentUser&&!(element['message'].toString().startsWith("http"))).last['message'];

      var UserrDoc=ChatInfo.data()!['getter']==_auth.currentUser!.phoneNumber ? ChatInfo.data()!['sender'] : ChatInfo.data()!['getter'];
      var UserInfo=await firestore.collection("UsersCollection").doc(UserrDoc).get();

      // var NewDocData=doc.data(); NewDocData['doc_id']=doc.id;
      // ChatList.add(NewDocData);
      (ChatInfo.data()!['messages'] as List).length!=0 ? ChatList.add({
        "name":UserInfo.data()!['nickname'],
        "last_message":LastMessage.toString(),
        "unreaded":UnReaded,
        "photo":UserInfo.data()!['avatar_link'],
        "id":doc,
      }) : null;
    });


    setState(() {NoChat=ChatList.length==0 ? true : false; });
  }

  @override
  void initState() {
    GetChats();

    // TODO: implement initState
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("Chat list"),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height-100,
        padding: EdgeInsets.all(24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoSearchTextField(),
              SizedBox(height: 24,),
              ChatList.length==0&&NoChat==false ?
              Center(child: CupertinoActivityIndicator(color: Colors.black,)) :
              NoChat ?
              Text("No chats") :
              ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: ChatList.length,
                  itemBuilder: (context,index) {
                    return ChatCard(context,ChatList[index]["name"],ChatList[index]["last_message"],ChatList[index]["photo"],"dUNAuwaxqNtx0aiwMZkl",ChatList[index]["unreaded"]);
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
