import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/sign_verification.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_route.dart';
import '../../widgets/voice_mes/user_message.dart';


class ChangeNumberPage extends StatefulWidget {

  const ChangeNumberPage({Key? key}) : super(key: key);

  @override
  State<ChangeNumberPage> createState() => _ChangeNumberPageState();
}


class _ChangeNumberPageState extends State<ChangeNumberPage> {

  TextEditingController NewNumberController=TextEditingController();
  FocusNode NewNumberNode=FocusNode();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  Future<bool> ChangeNumber(new_nomber) async{
    var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    var my_data_notifications=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Notifications").get();
    var my_data_friends=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Friends").get();
    var my_data_events=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Events").get();
    var my_data_organizer=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("OrganizerEvents").get();

    await firestore.collection("UsersCollection").doc(new_nomber).set(my_data.data() as Map<String, dynamic>); // Создание нового пользователя

    await Future.forEach(my_data_notifications.docs, (notifications) async{
      await firestore.collection("UsersCollection").doc(new_nomber).collection("Notifications").doc(notifications.id).set(notifications.data() as Map<String, dynamic>);});

    await Future.forEach(my_data_friends.docs, (friend) async{
      await firestore.collection("UsersCollection").doc(new_nomber).collection("Friends").doc(friend.id).set(friend.data() as Map<String, dynamic>);});

    await Future.forEach(my_data_events.docs, (event) async{
      await firestore.collection("UsersCollection").doc(new_nomber).collection("Events").doc(event.id).set(event.data() as Map<String, dynamic>);});

    await Future.forEach(my_data_organizer.docs, (org_event) async{
      await firestore.collection("UsersCollection").doc(new_nomber).collection("OrganizerEvents").doc(org_event.id).set(org_event.data() as Map<String, dynamic>);});

    var events_col=await firestore.collection("Events").get();
    var chat_col=await firestore.collection("Chats").get();

    await Future.forEach(chat_col.docs, (chat) async{
      if(chat.data()['sender']==_auth.currentUser!.phoneNumber){
        await firestore.collection("Chats").doc(chat.id).update({"sender":new_nomber});
      }
      if(chat.data()['getter']==_auth.currentUser!.phoneNumber){
        await firestore.collection("Chats").doc(chat.id).update({"getter":new_nomber});
      }

      var messages=await firestore.collection("Chats").doc(chat.id).collection("Messages").get();
      Future.forEach(messages.docs, (message) async{
        if(message.data()['user']==_auth.currentUser!.phoneNumber){
          await firestore.collection("Chats").doc(chat.id).collection("Messages").doc(message.id).update({
            "user":new_nomber
          });
        }
      });
    });

    await Future.forEach(events_col.docs, (event_doc) async{
      var event_users=await firestore.collection("Events").doc(event_doc.id).collection("Users").get();
      var event_wait_list=await firestore.collection("Events").doc(event_doc.id).collection("WaitList").get();
      var event_invited=await firestore.collection("Events").doc(event_doc.id).collection("InvitedUsers").get();
      var organizers_events=await firestore.collection("Events").doc(event_doc.id).collection("Organizers").get();

      await Future.forEach(organizers_events.docs, (element) async {
        if(element.id==_auth.currentUser!.phoneNumber){
          await firestore.collection("Events").doc(event_doc.id).collection("Organizers").doc(new_nomber).set({"active":true});
          await firestore.collection("Events").doc(event_doc.id).collection("Organizers").doc(_auth.currentUser!.phoneNumber).delete();
        }
      });

      await Future.forEach(event_users.docs, (element) async {
        if(element.id==_auth.currentUser!.phoneNumber){
          await firestore.collection("Events").doc(event_doc.id).collection("Users").doc(new_nomber).set({"active":true});
          await firestore.collection("Events").doc(event_doc.id).collection("Users").doc(_auth.currentUser!.phoneNumber).delete();
        }
      });

      await Future.forEach(event_wait_list.docs, (element) async{
        if(element.id==_auth.currentUser!.phoneNumber){
          await firestore.collection("Events").doc(event_doc.id).collection("WaitList").doc(new_nomber).set({"active":true});
          await firestore.collection("Events").doc(event_doc.id).collection("WaitList").doc(_auth.currentUser!.phoneNumber).delete();
        }
      });
      await Future.forEach(event_invited.docs, (element) async{
        if(element.id==_auth.currentUser!.phoneNumber){
          await firestore.collection("Events").doc(event_doc.id).collection("InvitedUsers").doc(new_nomber).set({"active":true});
          await firestore.collection("Events").doc(event_doc.id).collection("InvitedUsers").doc(_auth.currentUser!.phoneNumber).delete();
        }
      });

    });

    await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).delete();

    final page = WelcomePage();
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
    setState(() {wait_bool=false;});
    return true;
  }

  Future<bool> ChangeNumberDebug(oldnumber,new_nomber) async{
    var my_data=await firestore.collection("UsersCollection").doc(oldnumber).get();
    var my_data_notifications=await firestore.collection("UsersCollection").doc(oldnumber).collection("Notifications").get();
    var my_data_friends=await firestore.collection("UsersCollection").doc(oldnumber).collection("Friends").get();
    var my_data_events=await firestore.collection("UsersCollection").doc(oldnumber).collection("Events").get();
    var my_data_organizer=await firestore.collection("UsersCollection").doc(oldnumber).collection("OrganizerEvents").get();
    var new_data=my_data.data() as Map<String, dynamic>;
    new_data['phone']==new_nomber;

    await firestore.collection("UsersCollection").doc(new_nomber).set(new_data); // Создание нового пользователя

    await Future.forEach(my_data_notifications.docs, (notifications) async{
      await firestore.collection("UsersCollection").doc(new_nomber).collection("Notifications").doc(notifications.id).set(notifications.data() as Map<String, dynamic>);});

    await Future.forEach(my_data_friends.docs, (friend) async{
      await firestore.collection("UsersCollection").doc(new_nomber).collection("Friends").doc(friend.id).set(friend.data() as Map<String, dynamic>);});

    await Future.forEach(my_data_events.docs, (event) async{
      await firestore.collection("UsersCollection").doc(new_nomber).collection("Events").doc(event.id).set(event.data() as Map<String, dynamic>);});

    await Future.forEach(my_data_organizer.docs, (org_event) async{
      await firestore.collection("UsersCollection").doc(new_nomber).collection("OrganizerEvents").doc(org_event.id).set(org_event.data() as Map<String, dynamic>);});

    var events_col=await firestore.collection("Events").get();
    var chat_col=await firestore.collection("Chats").get();

    await Future.forEach(chat_col.docs, (chat) async{
      if(chat.data()['sender']==oldnumber){
        await firestore.collection("Chats").doc(chat.id).update({"sender":new_nomber});
      }
      if(chat.data()['getter']==oldnumber){
        await firestore.collection("Chats").doc(chat.id).update({"getter":new_nomber});
      }

      var messages=await firestore.collection("Chats").doc(chat.id).collection("Messages").get();
      Future.forEach(messages.docs, (message) async{
        if(message.data()['user']==oldnumber){
          await firestore.collection("Chats").doc(chat.id).collection("Messages").doc(message.id).update({
            "user":new_nomber
          });
        }
      });
    });

    await Future.forEach(events_col.docs, (event_doc) async{
      var event_users=await firestore.collection("Events").doc(event_doc.id).collection("Users").get();
      var event_wait_list=await firestore.collection("Events").doc(event_doc.id).collection("WaitList").get();
      var event_invited=await firestore.collection("Events").doc(event_doc.id).collection("InvitedUsers").get();
      var organizers_events=await firestore.collection("Events").doc(event_doc.id).collection("Organizers").get();

      await Future.forEach(organizers_events.docs, (element) async {
        if(element.id==oldnumber){
          await firestore.collection("Events").doc(event_doc.id).collection("Organizers").doc(new_nomber).set({"active":true});
          await firestore.collection("Events").doc(event_doc.id).collection("Organizers").doc(oldnumber).delete();
        }
      });

      await Future.forEach(event_users.docs, (element) async {
        if(element.id==oldnumber){
          await firestore.collection("Events").doc(event_doc.id).collection("Users").doc(new_nomber).set({"active":true});
          await firestore.collection("Events").doc(event_doc.id).collection("Users").doc(oldnumber).delete();
        }
      });

      await Future.forEach(event_wait_list.docs, (element) async{
        if(element.id==oldnumber){
          await firestore.collection("Events").doc(event_doc.id).collection("WaitList").doc(new_nomber).set({"active":true});
          await firestore.collection("Events").doc(event_doc.id).collection("WaitList").doc(oldnumber).delete();
        }
      });
      await Future.forEach(event_invited.docs, (element) async{
        if(element.id==oldnumber){
          await firestore.collection("Events").doc(event_doc.id).collection("InvitedUsers").doc(new_nomber).set({"active":true});
          await firestore.collection("Events").doc(event_doc.id).collection("InvitedUsers").doc(oldnumber).delete();
        }
      });

    });

    await firestore.collection("UsersCollection").doc(oldnumber).delete();

    final page = WelcomePage();
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
    setState(() {wait_bool=false;});
    return true;
  }

  Future<bool> GetNumbers(new_nomber) async{
    setState(() {wait_bool=true;});

    bool result=false;
    var nicknamesCollection = await firestore.collection("UsersCollection").get();

    await Future.forEach(nicknamesCollection.docs, (doc) {
      if(new_nomber.toString().toLowerCase()==doc.id.toString().toLowerCase()) result=true;
    });


    return result;
  }


  bool wait_bool=false;


  @override
  void initState() {

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro(AppLocalizations.of(context)!.change_number),
      // appBar: AppBarPro("Change number"),
      body: InkWell(
        onTap: (){
          NewNumberNode.hasFocus ? NewNumberNode.unfocus() : null;
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height-100,
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16,),
                      PhoneFormPro(NewNumberController,NewNumberNode,AppLocalizations.of(context)!.new_number),
                      // PhoneFormPro(NewNumberController,NewNumberNode,"New number"),
                      SizedBox(height: 16,),
                    ],
                  ),
                  ButtonPro(AppLocalizations.of(context)!.save, () async{

                    // var my_data_organizer=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("OrganizerEvents").get();
                    // print(my_data_organizer.docs.toString());
                    // my_data_organizer.docs.forEach((element) {
                    //   print("Hello");
                    // });

                    var number_exist=await GetNumbers("+"+NewNumberController.text);

                    if(number_exist) {
                      UserMessage(AppLocalizations.of(context)!.nomber_already_exist, context);
                      // UserMessage("Nomber already exist", context);
                    } else if(NewNumberController.text.length<6){
                      UserMessage(AppLocalizations.of(context)!.fill_correct_number, context);
                      // UserMessage("Fill correct number", context);
                    } else {
                      ChangeNumber(NewNumberController.text);
                      // ChangeNumberDebug("79788759243","+"+NewNumberController.text);
                    }
                  },wait_bool)
                ]
            ),
          ),
        ),
      ),
    );
  }
}