import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_route.dart';
import '../global_variables.dart';
import 'event_page.dart';



class EventListPage extends StatefulWidget {
  final IsMyEvents;
  final IsMyOrganizerEvents;
  final ApproveWidgets;
  const EventListPage({Key? key,required this.IsMyEvents,required this.IsMyOrganizerEvents,required this.ApproveWidgets}) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final storageRef = FirebaseStorage.instance.ref();

  int groupValue=0;
  bool no_events=false;

  List EventsList = [];
  List MyEvents = [];
  List OrganizerEvents = [];


  bool IsDateCurrent(Date){
    return DateTime.now().compareTo(DateTime.fromMillisecondsSinceEpoch(Date))==-1;
  }


  void getData(groupValue) async{

    EventsList = [];
    MyEvents = [];
    OrganizerEvents = [];

    if(widget.IsMyEvents||widget.IsMyOrganizerEvents){
      var my_data=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
      MyEvents=my_data.data()!['events'] as List;
      OrganizerEvents=my_data.data()!['organizer_events'] as List;
    }

    var EventCollection = await firestore.collection("Events").get();
    var EventDocs = EventCollection.docs;

    await Future.forEach(EventDocs, (doc) {
      var NewDocData=doc.data() as Map; NewDocData['doc_id']=doc.id;

      if(widget.IsMyEvents){
        if(groupValue==0){
          (MyEvents as List).contains(doc.id)&&IsDateCurrent(doc.data()['date']) ? EventsList.add(NewDocData) : null;
        } else {
          (MyEvents as List).contains(doc.id)&&!IsDateCurrent(doc.data()['date']) ? EventsList.add(NewDocData) : null;
        }
      } else if(widget.IsMyOrganizerEvents){
        if(groupValue==0){
          (OrganizerEvents as List).contains(doc.id)&&IsDateCurrent(doc.data()['date']) ? EventsList.add(NewDocData) : null;
        } else {
          (OrganizerEvents as List).contains(doc.id)&&!IsDateCurrent(doc.data()['date']) ? EventsList.add(NewDocData) : null;
        }
      } else if(widget.ApproveWidgets){
        if(NewDocData.containsKey("approved")) {
          !NewDocData["approved"] ? EventsList.add(NewDocData) : null;
        }

      } else {
        if(NewDocData.containsKey("approved")) {
          NewDocData["approved"] ? EventsList.add(NewDocData) : null;
        } else {
          IsDateCurrent(doc.data()['date']) ? EventsList.add(NewDocData) : null;
        }

      }
    });


    EventsList.sort((a,b){
      return (DateTime.fromMillisecondsSinceEpoch(a['date']) as DateTime).compareTo((DateTime.fromMillisecondsSinceEpoch(b['date']) as DateTime));
    });


    setState(() {no_events=EventsList.length==0;});
  }

  @override
  void initState() {

    getData(groupValue);

    // TODO: implement initState
    super.initState();

    // Future.delayed(Duration(seconds: 0)).then((value) {
    //   final globalProvider = Provider.of<GlobalProvider>(context);
    //   final globalData = globalProvider.notifications_lenght_get;
    //   final globalInitData = globalProvider.app_init_get;
    //   if(globalInitData==false){
    //     globalProvider.AppEnsureInit(true);
    //     print("Активируем");
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 248, 255, 1),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 56,),
                if((widget.IsMyEvents||widget.IsMyOrganizerEvents)&&!widget.ApproveWidgets) ...[
                  Container(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<int>(
                      backgroundColor:  CupertinoColors.systemGrey5,
                      thumbColor: CupertinoColors.white,
                      padding: EdgeInsets.all(2),
                      groupValue: groupValue,
                      children: {
                        0: buildSegment("Current"),
                        1: buildSegment("Past"),
                      },
                      onValueChanged: (value){
                        setState(() {
                          groupValue = value!;
                          getData(groupValue);
                        });

                      },
                    ),
                  ),
                  SizedBox(height: 16,),
                ],
                if(EventsList.length!=0) ...[
                  ListView.separated(
                    padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      itemCount: EventsList.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index) {
                        var DateEpoch=DateTime.fromMillisecondsSinceEpoch(EventsList[index]['date']);
                        var DateName=DateFormat('EEEE').format(DateEpoch);
                        var DateNameMonth=DateFormat('MMMM').format(DateEpoch);

                        Widget DayWidget(){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16,),
                              if(DateEpoch.day==DateTime.now().day) ...[
                                Text("Today",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black54),),
                              ] else ...[
                                Text(DateName.toString()+" "+DateEpoch.day.toString()+" "+DateNameMonth.toString(),style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.w600),),
                              ],

                              SizedBox(height: 16,),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(index!=0&&DateEpoch.day!=DateTime.fromMillisecondsSinceEpoch(EventsList[index-1]['date']).day) DayWidget(),
                            if(index==0) DayWidget(),

                            EventCard(context,EventsList[index],(){
                              getData(groupValue);
                            }),


                          ],
                        );
                      },
                      separatorBuilder: (context,index) {
                        return Divider(height: 16,color: Color.fromRGBO(0, 0, 0, 0),);
                      },

                  ),
                ] else ...[
                  no_events ?
                  Padding(
                    padding: EdgeInsets.only(top: 36),
                    child: Center(child: Text("No events")),
                  ) :
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 48.0),
                    child: CupertinoActivityIndicator(color: Colors.black,),
                  ))
                ]
              ]
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBarPro(context,(widget.ApproveWidgets||widget.IsMyOrganizerEvents||widget.IsMyEvents) ? 2:0),
    );
  }


  Widget buildSegment(String text){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(text,style: TextStyle(fontSize: 15, color: Colors.black87,),),
    );
  }
}
