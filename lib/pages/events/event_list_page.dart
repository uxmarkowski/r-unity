import 'dart:ui';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../functions/hive_model.dart';
import '../../widgets/custom_route.dart';
import '../global_variables.dart';
import 'event_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EventListPage extends StatefulWidget {
  final IsMyEvents;
  final IsMyOrganizerEvents;
  final ApproveWidgets;
  const EventListPage({Key? key,required this.IsMyEvents,required this.IsMyOrganizerEvents,required this.ApproveWidgets}) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {

  var model = hive_example();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final storageRef = FirebaseStorage.instance.ref();
  String CurrentCategory="All categories";

  var RussianLanguage=false;
  Map EnglMonths={1:"January", 2:"February", 3:"March", 4:"April", 5:"May", 6:"June", 6:"Jule", 8:"August", 9:"September", 10:"October", 11:"November", 12:"December",};
  Map RusMonths={1:"января", 2:"феварля", 3:"марта", 4:"апреля", 5:"мая", 6:"июня", 6:"июля", 8:"августа", 9:"сентября", 10:"октября", 11:"ноября", 12:"декабря",};
  Map RusDays={"Monday":"Понедельник", "Tuesday":"Вторник", "Wednesday":"Среда", "Thursday":"Четверг", "Friday":"Пятница", "Saturday":"Суббота", "Sunday":"Воскресенье"};

  Map TranslatedCategory=Map();

  int groupValue=0;
  int CalendarIndex=0;

  bool no_events=false;
  bool filters=false;
  bool ShowCallendar=false;
  bool free_events=false;
  bool category_exist=false;
  bool only_once=false;


  List EventsList = [];
  List MyEvents = [];
  List Categories = [];
  List OrganizerEvents = [];

  List<DateTime?> dates=[DateTime.now()];
  List<DateTime?> dates_two=[];
  List<DateTime?> dates_three=[];




  @override
  void initState() {
    GetLanguage();

    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => getData(groupValue));
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await getData(groupValue);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    if(!only_once) LoadNotificationsAndMessages();

    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 248, 255, 1),
      body: Stack(
        children: [
          SmartRefresher(
            header: MaterialClassicHeader(color: Colors.black,),
            onRefresh: _onRefresh,
            controller: _refreshController ,
            child: SingleChildScrollView(
              child: Container(
              padding: EdgeInsets.only(left: 16,right: 16,bottom: 36,top: 56),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(!widget.IsMyEvents&&!widget.IsMyOrganizerEvents&&!widget.ApproveWidgets) FiltersWidget(context),
                    SizedBox(height: 8,),
                    if((widget.IsMyEvents||widget.IsMyOrganizerEvents)&&!widget.ApproveWidgets) GroupToggle(context),
                    if(EventsList.length!=0) ...[
                      ListView.separated(
                        padding: EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemCount: EventsList.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context,index) {
                            var DateEpoch=DateTime.fromMillisecondsSinceEpoch(EventsList[index]['date']);var DateName=DateFormat('EEEE').format(DateEpoch);var DateNameMonth=DateFormat('MMMM').format(DateEpoch);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(index!=0&&DateEpoch.day!=DateTime.fromMillisecondsSinceEpoch(EventsList[index-1]['date']).day) DayWidget(DateEpoch,DateName),
                                if(index==0) DayWidget(DateEpoch,DateName),
                                EventCard(context: context,data: EventsList[index],getData: (){getData(groupValue);},russian_language: RussianLanguage),
                              ],
                            );
                          },
                          separatorBuilder: (context,index) {return Divider(height: 16,color: Color.fromRGBO(0, 0, 0, 0),);},

                      ),
                    ] else no_events ? NoEventsText(context) : ActivityIndicator()
                  ]
              ),
            ),
            ),
          ),
          if(ShowCallendar) CalendarWidget(context)
        ],
      ),
      bottomNavigationBar: BottomNavBarPro(context,(widget.ApproveWidgets||widget.IsMyOrganizerEvents||widget.IsMyEvents) ? 2:0),
    );
  }

  Padding NoEventsText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 36),
      child: Center(child: Text(AppLocalizations.of(context)!.no_events)),
      // child: Center(child: Text("No events")),
    );
  }

  Center ActivityIndicator() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(top: 48.0),
      child: CupertinoActivityIndicator(color: Colors.black,),
    ));
  }

  Container GroupToggle(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      child: CupertinoSlidingSegmentedControl<int>(
        backgroundColor:  CupertinoColors.systemGrey5,
        thumbColor: CupertinoColors.white,
        padding: EdgeInsets.all(2),
        groupValue: groupValue,
        children: {
          0: buildSegment(AppLocalizations.of(context)!.current),
          // 0: buildSegment("Current"),
          1: buildSegment(AppLocalizations.of(context)!.past),
          // 1: buildSegment("Past"),
        },
        onValueChanged: (value){
          setState(() {
            groupValue = value!;
            getData(groupValue);
          });

        },
      ),
    );
  }

  void LoadNotificationsAndMessages() async{
    only_once=true;
    var current_user=_auth.currentUser!.phoneNumber;

    final globalProvider = Provider.of<GlobalProvider>(context);
    final notifyRef = await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Notifications").get();
    var unreader_notify=notifyRef.docs.where((element) =>  element.data()['check']==false).length;
    globalProvider.updateNotifcations(unreader_notify);

    final messagesRef = await firestore.collection("Chats").get();
    var chats_docs=messagesRef.docs.where((element) =>  (element.data()['sender']==current_user)||(element.data()['getter']==current_user));
    await Future.forEach(chats_docs, (chat) async{
      var messages=await firestore.collection("Chats").doc(chat.id).collection("Messages").get();
      await Future.forEach(messages.docs, (mess) {
        if(mess.data()['status']=="sent"&&mess.data()['user']!=current_user) {
          print("mess "+mess.data().toString());
          globalProvider.updateUncheckMessages(1);
        }
      });
    });


  }

  void GetCategories() async{
    Categories=[];
    Categories.add(!RussianLanguage ? "All categories" : "Все категории");
    var CategoriesCollection = await firestore.collection("Categories").get();
    category_exist=CategoriesCollection.docs.length!=0;

    await Future.forEach(CategoriesCollection.docs, (doc) {
      TranslatedCategory[doc.data()["name"]]=doc.data()["name_rus"];
      Categories.add(doc.data()[RussianLanguage ? 'name_rus' : 'name']);
    });


    setState(() { });
  }

  bool IsDateCurrent(Date){
    return DateTime.now().compareTo(DateTime.fromMillisecondsSinceEpoch(Date))==-1;
  }

  bool IsDateCurrentByDate(Date1,Date2,is_first_date){
    var date1=Date1 as DateTime;
    var date2=DateTime.fromMillisecondsSinceEpoch(Date2);
    if(date1.day==date2.day&&date1.month==date2.month&&is_first_date) {return true;}
    if(date1.day==date2.day&&date1.month==date2.month&&!is_first_date) {return false;}

    return Date1.compareTo(DateTime.fromMillisecondsSinceEpoch(Date2))==-1;
  }


  Future<bool> getData(groupValue) async {
    print("GetData");


    EventsList = [];
    EventsList.clear();
    MyEvents = [];
    MyEvents.clear();
    OrganizerEvents = [];
    OrganizerEvents.clear();
    bool AllCategoryBool=RussianLanguage ? CurrentCategory=="Все категории" : CurrentCategory=="All categories";
    print("CurrentCategory "+CurrentCategory.toString());


    if(widget.IsMyEvents||widget.IsMyOrganizerEvents){
      var MyEventsCollection=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("Events").get();
      var MyOrganizersEventsCollection=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("OrganizerEvents").get();

      await Future.forEach(MyEventsCollection.docs, (my_events) => MyEvents.add(my_events.id));
      await Future.forEach(MyOrganizersEventsCollection.docs, (my_org_events) => OrganizerEvents.add(my_org_events.id));

    }

    var EventCollection = await firestore.collection("Events").get();
    var EventDocs = EventCollection.docs;

    await Future.forEach(EventDocs, (doc) {
      var NewDocData=doc.data() as Map; NewDocData['doc_id']=doc.id;

      if(widget.IsMyEvents){
        if(groupValue==0){
          if((MyEvents as List).contains(doc.id)&&IsDateCurrent(doc.data()['date'])) {
            EventsList.add(NewDocData);
            // doc.data()['price']==0 ? EventsList.add(NewDocData) : null;
          };
        } else {

          if((MyEvents as List).contains(doc.id)&&!IsDateCurrent(doc.data()['date'])) {
            EventsList.add(NewDocData);
            // doc.data()['price']==0 ? EventsList.add(NewDocData) : null;
          };

        }
      }


      else if(widget.IsMyOrganizerEvents){
        if(groupValue==0){
          if((OrganizerEvents as List).contains(doc.id)&&IsDateCurrent(doc.data()['date'])) {
            EventsList.add(NewDocData);
          };
        } else {
          if((OrganizerEvents as List).contains(doc.id)&&!IsDateCurrent(doc.data()['date'])) {
            EventsList.add(NewDocData);
          };
        }
      }

      else if(widget.ApproveWidgets){
        if(NewDocData.containsKey("approved")) {
          !NewDocData["approved"] ? EventsList.add(NewDocData) : null;
        }

      } else {
        if(((NewDocData as Map).containsKey("approved") ? NewDocData["approved"] : false)&&IsDateCurrent(doc.data()['date'])){
          bool OneCategoryBool=CurrentCategory==doc.data()['category']||CurrentCategory==TranslatedCategory[doc.data()['category']];

          if(dates.length!=0&&dates_two.length!=0){
            if((dates.first as DateTime).day==(dates_two.first as DateTime).day&&(dates.first as DateTime).month==(dates_two.first as DateTime).month&&(dates.first as DateTime).year==(dates_two.first as DateTime).year){
              print("Сработало");
              if(free_events) ((AllCategoryBool||OneCategoryBool)&& !IsDateCurrentByDate(dates_two.first,doc.data()['date'],false) && doc.data()['price']=="0"&&IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;
              else ((AllCategoryBool||OneCategoryBool) && !IsDateCurrentByDate(dates_two.first,doc.data()['date'],false)  && IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;
            } else {
              if(free_events) ((AllCategoryBool||OneCategoryBool)&& !IsDateCurrentByDate(dates_two.first,doc.data()['date'],false) && IsDateCurrentByDate(dates.first,doc.data()['date'],true) && doc.data()['price']=="0"&&IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;
              else ((AllCategoryBool||CurrentCategory==OneCategoryBool) && !IsDateCurrentByDate(dates_two.first,doc.data()['date'],false) && IsDateCurrentByDate(dates.first,doc.data()['date'],true) && IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;
            }

          }
          if(dates.length!=0&&dates_two.length==0){
            if(free_events) {((AllCategoryBool||CurrentCategory==OneCategoryBool) && IsDateCurrentByDate(dates.first,doc.data()['date'],true) && doc.data()['price']=="0"&&IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;}
            else {((AllCategoryBool||CurrentCategory==OneCategoryBool) && IsDateCurrentByDate(dates.first,doc.data()['date'],true) && IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;};
          }
          if(dates.length==0&&dates_two.length!=0){
            if(free_events) ((AllCategoryBool||CurrentCategory==OneCategoryBool) && !IsDateCurrentByDate(dates_two.first,doc.data()['date'],false) && doc.data()['price']=="0"&&IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;
            else ((AllCategoryBool||CurrentCategory==OneCategoryBool) && !IsDateCurrentByDate(dates_two.first,doc.data()['date'],false) && IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;
          }
          if(dates.length==0&&dates_two.length==0){
            if(free_events) ((AllCategoryBool||CurrentCategory==OneCategoryBool) && doc.data()['price']=="0"&&IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;
            else ((AllCategoryBool||CurrentCategory==OneCategoryBool) && IsDateCurrent(doc.data()['date'])) ? EventsList.add(NewDocData) : null;
          }
        }
      }
    });


    EventsList.sort((a,b){
      return (DateTime.fromMillisecondsSinceEpoch(a['date']) as DateTime).compareTo((DateTime.fromMillisecondsSinceEpoch(b['date']) as DateTime));
    });


    setState(() {no_events=EventsList.length==0;});
    return true;
  }

  Widget DayWidget(DateEpoch,DateName){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16,),
        if(DateEpoch.day==DateTime.now().day) ...[
          Text(AppLocalizations.of(context)!.today,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black54),),
          // Text("Today",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black54),),
        ] else ...[

          Text( (RussianLanguage ? RusDays[DateName.toString()] : DateName.toString())+" "+DateEpoch.day.toString()+" "+( RussianLanguage ? RusMonths[DateEpoch.month] : EnglMonths[DateEpoch.month]),style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.w600),),
        ],

        SizedBox(height: 16,),
      ],
    );
  }

  void GetLanguage() async{
    var lang = await model.GetLanguage();
    print("Lang "+lang.toString());
    setState(() { RussianLanguage=lang=="ru"; CurrentCategory=lang=="ru" ? "Все категории" : "All categories";});

    GetCategories();
  }

  InkWell FiltersWidget(BuildContext context) {
    return InkWell(
        onTap: (){
          setState(() {
            filters=!filters;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black12,blurRadius: 10)
            ]
          ),
          child: Column(
            children: [
              Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.event_filters,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.black54),),
                          // Text("Event filters",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.black54),),
                          !filters ? Icon(Icons.expand_more,color: Colors.black54) : Icon(Icons.expand_less,color: Colors.black54)
                        ],
                      ),
                      InkWell(
                        onTap: (){
                          setState(() {
                            CurrentCategory="All categories";
                            dates.clear();
                            dates_two.clear();
                            free_events=false;
                          });
                          getData(groupValue);
                        },
                        child: Container(
                          height: 24,
                            width: 68,

                            child: Align(
                              alignment: Alignment.centerRight,
                                child: Text(AppLocalizations.of(context)!.clear,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.black54),)
                                // child: Text("Clear",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.black54),)
                            )
                        ),
                      ),
                    ],
                  )
              ),
              if(filters) ...[
                if(category_exist) ...[
                  SizedBox(height: 16,),
                  CategoriesDropDown(context),
                ],
                Divider(height: 16,color: Colors.white,),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14,horizontal: 12),
                          height: 48,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(width: 1,color: Color.fromRGBO(177, 177, 177, 1))
                          ),
                          child: Text(
                            // "From "+
                            AppLocalizations.of(context)!.from+" "+
                            // AppLocalizations.of(context)!.from+
                                (dates.length!=0 ?
                                (((dates.first as DateTime).day<10 ? "0"+(dates.first as DateTime).day.toString() : (dates.first as DateTime).day.toString())+"."+
                                    ((dates.first as DateTime).month<10 ? "0"+(dates.first as DateTime).month.toString() : (dates.first as DateTime).month.toString())+"."+
                                    (dates.first as DateTime).year.toString()) : ""),
                            style: TextStyle(fontFamily: "SFPro",fontWeight: FontWeight.w500,color: Color.fromRGBO(98, 98, 98, 1)),
                          ),
                        ),
                        onTap: (){
                          setState((){
                            CalendarIndex=0;
                            ShowCallendar=true;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16,),
                    Expanded(
                      child: InkWell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14,horizontal: 12),
                          height: 48,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(width: 1,color: Color.fromRGBO(177, 177, 177, 1))
                          ),
                          child: Text(
                            "... "+
                            // AppLocalizations.of(context)!.to+
                                (dates_two.length!=0 ?
                                (((dates_two.first as DateTime).day<10 ? "0"+(dates_two.first as DateTime).day.toString() : (dates_two.first as DateTime).day.toString())+"."+
                                    ((dates_two.first as DateTime).month<10 ? "0"+(dates_two.first as DateTime).month.toString() : (dates_two.first as DateTime).month.toString())+"."+
                                    (dates_two.first as DateTime).year.toString()) : ""),
                            style: TextStyle(fontFamily: "SFPro",fontWeight: FontWeight.w500,color: Color.fromRGBO(98, 98, 98, 1)),
                          ),
                        ),
                        onTap: (){
                          setState((){
                            CalendarIndex=1;
                            ShowCallendar=true;
                          });
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12),
                PriceFilterToggle(),
              ]
            ],
          ),
        ),
      );
  }

  Stack CalendarWidget(BuildContext context) {
    return Stack(
            children: [
              Material(
                color: Colors.black12,
                child: InkWell(
                  onTap: (){
                    setState(() {
                      ShowCallendar=false;
                    });
                  },
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
              ),
              Align(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 280,
                    height: 280,
                    padding: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Material(
                      child: Builder(
                        builder: (context){
                          return CalendarDatePicker2(
                              config: CalendarDatePicker2Config(),
                              value: [],
                              onValueChanged: (date) {
                                print(date.toString());
                                if(CalendarIndex==0) {
                                  getData(groupValue);
                                  setState(() {
                                    dates = [date.first as DateTime?];
                                    ShowCallendar=false;
                                  });
                                  // print("date after "+dates.toString());
                                } else if(CalendarIndex==1) {
                                  getData(groupValue);
                                  setState(() {
                                    dates_two = [date.first as DateTime?];
                                    ShowCallendar=false;
                                  });
                                }
                              },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }


  void TestFunc(){
    print("Сумма 5 и 10 "+summ(5,10).toString());
  }

  int summ(a,b){
    return a+b;
  }

  Widget CategoriesDropDown(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 0,vertical: 0),
      decoration: BoxDecoration(
          border: Border.all(width: 1,color: Colors.black26),
          borderRadius: BorderRadius.circular(8)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Choice category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: Categories.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          )).toList(),
          value: CurrentCategory,
          onChanged: (value) {
            setState(() {
              CurrentCategory = value!;
            });
            getData(groupValue);
          },
          dropdownStyleData: DropdownStyleData(
              maxHeight: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12)
              )
          ),
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            width: 140,

          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
        ),
      ),
    );
  }

  Row PriceFilterToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.free,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        // Text("Free",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: free_events,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              setState(() {
                free_events=!free_events;
              });
              getData(groupValue);
            }
        ),
      ],
    );
  }

  Widget buildSegment(String text){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(text,style: TextStyle(fontSize: 15, color: Colors.black87,),),
    );
  }
}
