import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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


  Future <bool> CheckReadedOrNot(ChatDocs) async{
    bool result=false;

    await Future.forEach(ChatDocs, (chat_doc) {
      var chat_doc_data=chat_doc as  QueryDocumentSnapshot<Map<String, dynamic>>;
      if(chat_doc_data.data()['user']!=_auth.currentUser!.phoneNumber&&chat_doc_data.data()['status']=="sent"){
        result=true;
      }
    });

    return result;
  }

  void GetChats() async{

    ChatList = [];
    var MyFriendsCollections = await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Friends").get();
    var FriendsDocs = MyFriendsCollections.docs;

    await Future.forEach(FriendsDocs, (FrienDoc) async{
      var ChatInfo=await firestore.collection("Chats").doc((FrienDoc.data() as Map)!['chat'] as String?).get();
      var ChatMessageCollection=await firestore.collection("Chats").doc((FrienDoc.data() as Map)!['chat'] as String?).collection("Messages").get();
      var UnReaded=await CheckReadedOrNot(ChatMessageCollection.docs);
      var NotMyMessage=(ChatMessageCollection.docs).where((element) => element.data()['user']!=_auth.currentUser!.phoneNumber&&!(element.data()['message'].toString().startsWith("http")));
      var MyMessage=(ChatMessageCollection.docs).where((element) => element.data()['user']==_auth.currentUser!.phoneNumber&&!(element.data()['message'].toString().startsWith("http")));
      var ListOfMessageSort=(ChatMessageCollection.docs).where((element) => !(element.data()['message'].toString().startsWith("http"))).toList();
      ListOfMessageSort.sort((a,b) {return DateTime.fromMillisecondsSinceEpoch(a.data()['time']).compareTo(DateTime.fromMillisecondsSinceEpoch(b.data()['time']));});
      var LastMessage= ChatMessageCollection.docs.where((element) => !(element.data()['message'].toString().startsWith("http"))).length==0 ? "Chat empty" : NotMyMessage.length==0 ? "User has not yet responded" : ListOfMessageSort.last.data()['message'];
      var LastDate= ChatMessageCollection.docs.length==0 ? 0 : (NotMyMessage.length==0 ? MyMessage.first.data()['time'] : NotMyMessage.first.data()['time']);

      var UserrDoc=ChatInfo.data()!['getter']==_auth.currentUser!.phoneNumber ? ChatInfo.data()!['sender'] : ChatInfo.data()!['getter'];
      var UserInfo=await firestore.collection("UsersCollection").doc(UserrDoc).get();


      // var NewDocData=doc.data(); NewDocData['doc_id']=doc.id;
      // ChatList.add(NewDocData);
      ChatMessageCollection.docs.length!=0 ? ChatList.add({
        "name":UserInfo.data()!['nickname'],
        "last_message":LastMessage.toString(),
        "unreaded":UnReaded,
        "phone":UserInfo.data()!['phone'],
        "photo":UserInfo.data()!['avatar_link'],
        "id":FrienDoc['chat'],
        "last_date":LastDate,
      }) : null;
    });
    // print("test");
    ChatList.sort((a,b){
      if(a==0) return -1;
      return DateTime.now().compareTo(DateTime.fromMillisecondsSinceEpoch(a['last_date']));
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
      appBar: AppBarPro(AppLocalizations.of(context)!.chat_list),
      // appBar: AppBarPro("Chat list"),
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
                    return ChatCard(context,ChatList[index]["name"],ChatList[index]["last_message"],ChatList[index]["photo"],ChatList[index]["id"],ChatList[index]["unreaded"],GetChats,ChatList[index]["phone"]);
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
