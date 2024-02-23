import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/widgets/voice_mes/user_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import '../sign/welcome_page.dart';



class OrganizersApplications extends StatefulWidget {
  const OrganizersApplications({Key? key}) : super(key: key);

  @override
  State<OrganizersApplications> createState() => _OrganizersApplicationsState();
}

class _OrganizersApplicationsState extends State<OrganizersApplications> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool wait_bool=false;

  List Applications=[];

  void LoadApplications() async{
    setState(() {Applications.clear();});

    var data_organizers=await firestore.collection("OrganizerRequests").get();
    var data_safe_badge=await firestore.collection("SafeBadgeRequests").get();

    await Future.forEach(data_organizers.docs, (doc) {
      var doc_data=doc.data() as Map;
      doc_data['id']=doc.id;
      doc_data['type']="organizer";
      Applications.add(doc_data);
    });

    await Future.forEach(data_safe_badge.docs, (doc) {
      var doc_data=doc.data() as Map;
      doc_data['id']=doc.id;
      doc_data['type']="safe_badge";
      Applications.add(doc_data);
    });
    print("Applications length "+Applications.length.toString());

    setState(() {accept_wait=false;cancel_wait=false;});
  }

  Future<bool> SendOrganizerAnswer({required doc_id,required accept}) async{

  await firestore.collection("UsersCollection").doc(doc_id).collection("Notifications").add(
      {
        "title":accept ? "Congratulations! Now you are able to create an event. Find “Create event” button in the user menu" :
        "Unfortunately we were unable to confirm your request for listing events on our platform. If you still interested in using our service as an organizer, please send your request again.",

        "title_rus": accept ? "Поздравляем! Теперь вы можете создавать мероприятия. Ищите кнопку «создать мероприятие» в меню пользователя" :
        "К сожалению, нам не удалось подтвердить ваш запрос на размещение событий на нашей платформе. Если вы по-прежнему заинтересованы в использовании нашего сервиса в качестве организатора, то отправьте запрос еще раз.",
        "photo_link": "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.upwork.com%2Fresources%2Foperations-manager-job-description&psig=AOvVaw3dbXrm92dXWJ-8zM_tbwZY&ust=1703728413405000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCPj10InBroMDFQAAAAAdAAAAABAQ",
        "type":"become_organizer",
        "check":false,
        // "id":data['id'],
        "date":DateTime.now().millisecondsSinceEpoch
      });
      return true;

  }

  Future<bool> SendSafeBadgeAnswer({required doc_id,required accept}) async{

    await firestore.collection("UsersCollection").doc(doc_id).collection("Notifications").add(
        {
          "title":accept ? "Congratulations! Your safe badge has been approved" :
          "Unfortunately, at the moment we cannot approve you a safe badge",

          "title_rus": accept ? "Поздравляем! Вам присвоен Safe Badge" :
          "К сожалению на данный момент мы не можем присовить вам статус safe badge",
          "photo_link": "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.upwork.com%2Fresources%2Foperations-manager-job-description&psig=AOvVaw3dbXrm92dXWJ-8zM_tbwZY&ust=1703728413405000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCPj10InBroMDFQAAAAAdAAAAABAQ",
          "type":"safe_badge",
          "check":false,
          // "id":data['id'],
          "date":DateTime.now().millisecondsSinceEpoch
        });
    return true;

  }

  bool accept_wait=false;
  bool cancel_wait=false;

  @override
  void initState() {
    LoadApplications();

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Become organizer"),),
      appBar: AppBarPro("Заявки"),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 16,),
              ListView.separated(
                  padding: EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),blurRadius: 20)]
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Applications[index]['type']=="organizer" ? "Заявка на организатора" : "Заявка Safe Badge",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
                              SizedBox(height: 16,),
                              if(Applications[index]['type']=="organizer") ...[

                                Text("Имя: "+Applications[index]['Name'].toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                                SizedBox(height: 8,),
                                Text("Почта: "+Applications[index]['EmailController'].toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                                SizedBox(height: 8,),
                                Text("Описание: "+Applications[index]['Describe'].toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                              ] else ...[
                                Text("Телефон: "+Applications[index]['Phone'].toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                              ],
                              SizedBox(height: 12,),
                              Row(
                                children: [
                                  ButtonProColoredWidth("Принять", () async{
                                    if(Applications[index]['type']=="organizer") {
                                      await AcceptOrganizer(index);
                                    } else {
                                      await AcceptSafeBadge(index);
                                    }

                                  }, false,Colors.green,(MediaQuery.of(context).size.width-32)/2-6-16),
                                  SizedBox(width: 12,),
                                  ButtonProColoredWidth("Отказать", () async{
                                    if(Applications[index]['type']=="organizer") {
                                      await DeclineOrganizer(index);
                                    } else {
                                      await DeclineSafeBadge(index);
                                    }

                                  }, false,Colors.red,(MediaQuery.of(context).size.width-32)/2-6-16),
                                ],
                              ),
                            ],
                          ),
                          width: double.infinity,
                        ),

                      ],
                    );
                  },
                  separatorBuilder: (context,index){
                    return SizedBox(height: 24,);
                  },
                  itemCount: Applications.length
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> DeclineOrganizer(int index) async {
    setState(() {cancel_wait=true;});
    await SendOrganizerAnswer(doc_id: Applications[index]['Phone'],accept: false);
    await firestore.collection("OrganizerRequests").doc(Applications[index]['id']).delete();
    LoadApplications();
  }

  Future<void> DeclineSafeBadge(int index) async {
    setState(() {cancel_wait=true;});
    SendSafeBadgeAnswer(doc_id: Applications[index]['Phone'],accept: false);
    print(Applications[index]['id'].toString());
    await firestore.collection("SafeBadgeRequests").doc(Applications[index]['id']).delete();
    LoadApplications();
  }

  Future<void> AcceptSafeBadge(int index) async {
    setState(() {accept_wait=true;});
    SendSafeBadgeAnswer(doc_id: Applications[index]['Phone'],accept: true);
    await firestore.collection("UsersCollection").doc(Applications[index]['Phone']).update({"safe_badge":true});
    await firestore.collection("SafeBadgeRequests").doc(Applications[index]['id']).delete();
    LoadApplications();
  }


  Future<void> AcceptOrganizer(int index) async {
    setState(() {accept_wait=true;});
    print("Applications[index]['id'] "+Applications[index]['id'].toString());

    await SendOrganizerAnswer(doc_id: Applications[index]['Phone'],accept: true);
    await firestore.collection("UsersCollection").doc(Applications[index]['Phone']).update({"role":1});
    await firestore.collection("OrganizerRequests").doc(Applications[index]['id']).delete();
    LoadApplications();
  }

}
