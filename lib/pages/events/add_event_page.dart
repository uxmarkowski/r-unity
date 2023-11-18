import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/events/event_list_page.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:event_app/widgets/app_bar.dart';
import 'package:event_app/widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

import '../../widgets/custom_route.dart';
import 'other_organizers_page.dart';


class AddEventPage extends StatefulWidget {
  final data;
  final is_new;
  const AddEventPage({Key? key,required this.data, required this.is_new}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {

  static const CameraPosition _kGooglePlex = CameraPosition(target: LatLng(34.052235,-118.243683),   zoom: 14.4746,);
  static const CameraPosition _kLake = CameraPosition(bearing: 192.8334901395799, target: LatLng(37.43296265331129, -122.08832357078792), tilt: 59.440717697143555, zoom: 19.151926040649414);
  bool AllowMySelfGeo=true; final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final Set<Marker> _markers = new Set();

  DateFormat format = new DateFormat("MMMM");

  TextEditingController EventNameController=TextEditingController();
  TextEditingController EventNameController1=TextEditingController();
  TextEditingController EventNameController2=TextEditingController();

  TextEditingController AboutController=TextEditingController();
  TextEditingController AboutController1=TextEditingController();
  TextEditingController AboutController2=TextEditingController();

  TextEditingController PriceController=TextEditingController();
  TextEditingController MyWalletController=TextEditingController();
  TextEditingController MaxPeoplesController=TextEditingController();
  TextEditingController AdresController=TextEditingController();
  TextEditingController ShortAdresController=TextEditingController();
  TextEditingController LocationInfoController=TextEditingController();
  TextEditingController ParkingInfoController=TextEditingController();
  TextEditingController TagController=TextEditingController();


  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();

  FocusNode EventNameNode=FocusNode();
  FocusNode EventNameNode1=FocusNode();
  FocusNode EventNameNode2=FocusNode();

  FocusNode AboutNode=FocusNode();
  FocusNode AboutNode1=FocusNode();
  FocusNode AboutNode2=FocusNode();

  FocusNode PriceNode=FocusNode();
  FocusNode MyWalletNode=FocusNode();
  FocusNode MaxPeoplesNode=FocusNode();
  FocusNode AdresNode=FocusNode();
  FocusNode ShortAdresNode=FocusNode();
  FocusNode LocationInfoNode=FocusNode();
  FocusNode ParkingInfoNode=FocusNode();
  FocusNode TagNode=FocusNode();

  List<DateTime?> _dates=[DateTime.now()];
  DateTime dates_var=DateTime.now();
  DateTime finalDate=DateTime.now();
  Duration MyDuration=Duration(hours: 0,minutes: 0);

  List MyOrganizerEvents=[];
  List OtherOrganizers=[];
  List AdditionalImagesFromEdit=[];

  var EvenId="";
  var DatesTimeLength=0;
  var DatesTime="00:00";
  var AdditionalTextLength=0;

  bool IsOnline=true;
  bool InDoor=false;
  bool ShowPicker=false;
  bool BackDrop=false;
  bool ShowCallendar=false;
  bool WaitForNextStep=false;
  bool image_load=false;
  bool additional_iamges=false;
  bool pay_with_my_wallet=false;


  final ImagePicker _picker = ImagePicker();
  late XFile? image;
  List<dynamic> AdditionalImages=[];





  bool CanAddEvent(){
    if(EventNameController.text.length==0){
      ScaffoldMessa("Please fill \"Event name\"");
      return false;
    } else if(AboutController.text.length==0){
      ScaffoldMessa("Please fill \"About\"");
      return false;
    } else if(!IsOnline&&(AdresController.text.length==0||_markers.length==0)){
      ScaffoldMessa(_markers.length!=0 ? "Please fill \"Adres\"" :"Please make geopoint");
      return false;
    } else if(MyDuration.inMinutes==0){
      ScaffoldMessa("Please fill \"Duration\"");
      return false;
    } else if(!image_load){
      ScaffoldMessa("Please add an image");
      return false;
    } else if(AdditionalTextLength>0&&((EventNameController1.text.length==0||AboutController1.text.length==0))){
      ScaffoldMessa("Please fill additional information");
      return false;
    } else if(AdditionalTextLength>1&&((EventNameController2.text.length==0||AboutController2.text.length==0))){
      ScaffoldMessa("Please fill additional information");
      return false;
    } else if(pay_with_my_wallet&&MyWalletController.text.length==0){
      ScaffoldMessa("Please fill payment instructions");
      return false;
    } else if(MaxPeoplesController.text.length==0){
      ScaffoldMessa("Please max peoples count");
      return false;
    } else if(!IsOnline){
      if(AdresController.text.length==0){
        ScaffoldMessa("Please fill adress");
        return false;
      } if(ShortAdresController.text.length==0){
        ScaffoldMessa("Please fill short adress");
        return false;
      } if(_markers.length==0){
        ScaffoldMessa("Please add geo point");

        return false;
      } else {
        return true;
      }
    }

    setState(() {});
    return true;

  }

  void LoadEditInfo(){

    additional_iamges=widget.data["additional_photo_links"].length!=0;
    AdditionalImages.addAll(widget.data["additional_photo_links"]);
    AdditionalImages.removeWhere((element) => element==widget.data['photo_link']);

    EventNameController.text=widget.data['header'];
    EventNameController1.text=(widget.data as Map).containsKey("header1") ? widget.data['header1'] : "";
    EventNameController2.text=(widget.data as Map).containsKey("header2") ? widget.data['header2'] : "";
    MyWalletController.text=(widget.data as Map).containsKey("my_wallet_instructions") ? widget.data['my_wallet_instructions'] : "";

    AboutController.text=widget.data['about'];
    AboutController1.text=(widget.data as Map).containsKey("about1") ? widget.data['about1'] : "";
    AboutController2.text=(widget.data as Map).containsKey("about2") ? widget.data['about2'] : "";
    AdditionalTextLength=(widget.data as Map).containsKey("additional_text_count") ? widget.data['additional_text_count'] : 0;

    PriceController.text=widget.data['price'];
    // TagController.text=(widget.data['tags'] as List).join(", ");
    MaxPeoplesController.text=widget.data['max_peoples'].toString();
    MyDuration=Duration(minutes: widget.data['duration']);
    _dates.first=DateTime.fromMillisecondsSinceEpoch(widget.data['date']);
    AdresController.text=widget.data['address'];
    ShortAdresController.text=(widget.data as Map).containsKey("short_address") ? widget.data['short_address'] : "";
    LocationInfoController.text=widget.data['location_info'];
    ParkingInfoController.text=widget.data['parking_info'];
    IsOnline=widget.data['is_online'];
    InDoor=widget.data['is_indor'];
    pay_with_my_wallet=(widget.data as Map).containsKey(pay_with_my_wallet) ? widget.data['pay_with_my_wallet'] : false;

    if((widget.data as Map).containsKey("geo_point") ){
      if(widget.data['geo_point']!=""){
        var _GeoPoint=widget.data['geo_point'] as GeoPoint;
        _markers.add(Marker(
          markerId: MarkerId("place.id"),
          position: LatLng(_GeoPoint.latitude,_GeoPoint.longitude),
          infoWindow: InfoWindow(
            title: EventNameController.text,
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));
      }

    }

    setState(() { });

  }

  void GetEvents() async{
    var Events=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    MyOrganizerEvents=Events.data()!['organizer_events'];
  }

  void SendIviteToOrganizer(photo_url,event_doc) async{

    if(OtherOrganizers.length>0){
      await Future.forEach(OtherOrganizers, (organazier) async{
        if(widget.is_new){
          await firestore.collection("UsersCollection").doc(organazier["phone"]).collection("Notifications").add(
              {
                "title":"You are invited by the organizer to "+EventNameController.text,
                "photo_link": photo_url.toString(),
                "type":"organizer_invite",
                "event_doc":event_doc,
                "status":"invited",
                "check":false,
                "date":DateTime.now().millisecondsSinceEpoch
              });
        } else if(!(widget.data['organizers'] as List).contains(organazier['phone'])){
          await firestore.collection("UsersCollection").doc(organazier["phone"]).collection("Notifications").add(
              {
                "title":"You are invited by the organizer to "+EventNameController.text,
                "photo_link": photo_url.toString(),
                "type":"organizer_invite",
                "event_doc":event_doc,
                "status":"invited",
                "check":false,
                "date":DateTime.now().millisecondsSinceEpoch
              });
        }
      });
    }
  }

  void AddImage() async{

    try {

      var MyImage = await _picker.pickImage(source: ImageSource.gallery);
      AdditionalImages.add(MyImage!);

      setState(() { });

    } on PlatformException catch  (e) {
      ExceptDialog();
    }
  }

  void DeleteImage(index) {

    AdditionalImages.removeAt(index);
    setState(() {

    });
  }

  void ExceptDialog() async{
    print("Erroe");
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Access to your photos"),
        content: Text("Unfortunately, you have blocked the application from accessing photos. A photo is not required for the application to work, but if you change your mind, you need to go to settings and add it"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Stay"),

            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text("Add"),
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if(result){
      AppSettings.openAppSettings().then((value) => setState((){}));
    }
  }

  void AddEvent() async{
    setState(() {
      WaitForNextStep=true;
    });

    var Avatar_Path="events_photo/event_"+DateTime.now().millisecondsSinceEpoch.toString()+".jpg";
    final photoRef = storageRef.child(Avatar_Path); File file = File(image!.path);
    await photoRef.putFile(file); var urrr=await photoRef.getDownloadURL();
    var AdditinalImgLinks=[];



    if(AdditionalImages.length!=0&&additional_iamges){
      await Future.forEach(AdditionalImages, (imagee) async{
        if(imagee.toString().startsWith("http")){
          AdditinalImgLinks.add(imagee);
        } else {
          var Avatar_Path="events_photo/event_"+DateTime.now().millisecondsSinceEpoch.toString()+".jpg";
          final photoRef = storageRef.child(Avatar_Path); File file = File(imagee!.path);
          await photoRef.putFile(file); var urr=await photoRef.getDownloadURL();
          AdditinalImgLinks.add(urr);
        }
      });
      AdditinalImgLinks.insert(0, urrr);
    }




    await firestore.collection("Events").add({
      "header":EventNameController.text,
      "header1":EventNameController1.text,
      "header2":EventNameController2.text,
      "about":AboutController.text,
      "about1":AboutController1.text,
      "about2":AboutController2.text,
      "additional_text_count":AdditionalTextLength,
      "price":PriceController.text,
      "duration":(MyDuration as Duration).inMinutes,
      "date":(_dates.first as DateTime).millisecondsSinceEpoch,
      "address":AdresController.text,
      "geo_point":IsOnline ? "" : GeoPoint(_markers.first.position.latitude,_markers.first.position.longitude),
      "short_address":ShortAdresController.text,
      "location_info":LocationInfoController.text,
      "parking_info":ParkingInfoController.text,
      "is_online":IsOnline,
      "is_indor":InDoor,
      "peoples":0,
      "max_peoples":int.parse(MaxPeoplesController.text),
      // "tags":TagController.text.replaceAll(' ', '').split(','),
      "organizers":[_auth.currentUser!.phoneNumber],
      "photo_path": Avatar_Path.toString(),
      "photo_link": urrr.toString(),
      "additional_photo_links": AdditinalImgLinks,
      "pay_with_my_wallet": pay_with_my_wallet,
      "my_wallet_instructions": MyWalletController.text,
      "messages": [],
      "users": [],
      "wait_list": [],
      "approved": false,
    }).then((value) {
      SendIviteToOrganizer(urrr,value.id);
      MyOrganizerEvents.add(value.id);
      firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
        "organizer_events":MyOrganizerEvents
      });
    });

    setState(() {
      WaitForNextStep=false;
    });
  }

  void UpdateEvent() async{
    setState(() {
      WaitForNextStep=true;
    });
    var urrrr=widget.data['photo_link'];

    if(image_load){
      var Avatar_Path="events_photo/event_"+DateTime.now().millisecondsSinceEpoch.toString()+".jpg";
      final photoRef = storageRef.child(Avatar_Path); File file = File(image!.path);
      await photoRef.putFile(file); urrrr=await photoRef.getDownloadURL();

    }

    SendIviteToOrganizer(urrrr,widget.data['doc_id']);

    var AdditinalImgLinks=[];

    if(AdditionalImages.length!=0&&additional_iamges){
      await Future.forEach(AdditionalImages, (imagee) async{
        if(imagee.toString().startsWith("http")){
          AdditinalImgLinks.add(imagee);
        } else {
          var Avatar_Path="events_photo/event_"+DateTime.now().millisecondsSinceEpoch.toString()+".jpg";
          final photoRef = storageRef.child(Avatar_Path); File file = File(imagee!.path);
          await photoRef.putFile(file); var urr=await photoRef.getDownloadURL();
          AdditinalImgLinks.add(urr);
        }
      });
      AdditinalImgLinks.insert(0, urrrr);
    }

    await firestore.collection("Events").doc(widget.data['doc_id']).update({
      "header":EventNameController.text,
      "header1":EventNameController1.text,
      "header2":EventNameController2.text,
      "about":AboutController.text,
      "about1":AboutController1.text,
      "about2":AboutController2.text,
      "additional_text_count":AdditionalTextLength,
      "price":PriceController.text,
      "duration":(MyDuration as Duration).inMinutes,
      "date":(_dates.first as DateTime).millisecondsSinceEpoch,
      "address":AdresController.text,
      "geo_point":IsOnline ? "" : GeoPoint(_markers.first.position.latitude,_markers.first.position.longitude),
      "short_address":ShortAdresController.text,
      "location_info":LocationInfoController.text,
      "parking_info":ParkingInfoController.text,
      "is_online":IsOnline,
      "is_indor":InDoor,
      "peoples":0,
      "pay_with_my_wallet": pay_with_my_wallet,
      "my_wallet_instructions": MyWalletController.text,
      "max_peoples":int.parse(MaxPeoplesController.text),
      // "tags":TagController.text.replaceAll(' ', '').split(','),
      "organizers":[_auth.currentUser!.phoneNumber],
      "photo_link": (image_load) ? urrrr.toString() : widget.data['photo_link'],
      "additional_photo_links": AdditinalImgLinks,
      "messages": [],
      "users": [],
    });


    setState(() {
      WaitForNextStep=false;
    });

  }

  void ScaffoldMessa(message){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
    ));
  }

  bool CanUpdateEvent() {
    if(EventNameController.text.length==0){
      ScaffoldMessa("Please fill \"Event name\"");
      return false;
    } else if(AboutController.text.length==0){
      ScaffoldMessa("Please fill \"About\"");
      return false;
    } else if(!IsOnline&&AdresController.text.length==0){
      ScaffoldMessa("Please fill \"Addres\"");
      return false;
    } else if(MyDuration.inMinutes==0){
      ScaffoldMessa("Please fill \"Duration\"");
      return false;
    } else if(pay_with_my_wallet&&MyWalletController.text.length==0){
      ScaffoldMessa("Please fill payment instructions");
      return false;
    } else if(AdditionalTextLength>0&&((EventNameController1.text.length==0||AboutController1.text.length==0))){
      ScaffoldMessa("Please fill additional information");
      return false;
    } else if(AdditionalTextLength>1&&((EventNameController2.text.length==0||AboutController2.text.length==0))){
      ScaffoldMessa("Please fill additional information");
      return false;
    } else if(MaxPeoplesController.text.length==0){
      ScaffoldMessa("Please add max peoples count");
      return false;
    } else if(!IsOnline){
      if(AdresController.text.length==0){
        ScaffoldMessa("Please fill adress");
        return false;
      } if(ShortAdresController.text.length==0){
        ScaffoldMessa("Please fill short adress");
        return false;
      } if(_markers.length==0){
        ScaffoldMessa("Please add geopoint");
        return false;
      } else {
        return true;
      }
    }

    setState(() {});
    return true;

  }


  @override
  void initState() {
    GetEvents();
    if(!widget.is_new){
      LoadEditInfo();
    }

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("Add event"),
      body: Stack(
        children: [
          InkWell(
            onTap: (){
              EventNameNode.hasFocus ? EventNameNode.unfocus() : null;
              EventNameNode1.hasFocus ? EventNameNode1.unfocus() : null;
              EventNameNode2.hasFocus ? EventNameNode2.unfocus() : null;

              AboutNode.hasFocus ? AboutNode.unfocus() : null;
              AboutNode1.hasFocus ? AboutNode1.unfocus() : null;
              AboutNode2.hasFocus ? AboutNode2.unfocus() : null;

              AdresNode.hasFocus ? AdresNode.unfocus() : null;
              ShortAdresNode.hasFocus ? ShortAdresNode.unfocus() : null;
              PriceNode.hasFocus ? PriceNode.unfocus() : null;
              MyWalletNode.hasFocus ? MyWalletNode.unfocus() : null;
              MaxPeoplesNode.hasFocus ? MaxPeoplesNode.unfocus() : null;
              LocationInfoNode.hasFocus ? LocationInfoNode.unfocus() : null;
              ParkingInfoNode.hasFocus ? ParkingInfoNode.unfocus() : null;

            },
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16,),
                    Text("Promo photo",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                    SizedBox(height: 16,),
                    Container(
                      height:124,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () async{

                              if(image_load&&image!=null){

                                File(image!.path).delete();
                                image = await _picker.pickImage(source: ImageSource.gallery);
                                image_load=true;
                                setState(() {

                                });

                              } else {

                                try {
                                  image = await _picker.pickImage(source: ImageSource.gallery);
                                  image_load=true;
                                  setState(() {

                                  });
                                } on PlatformException catch  (e) {
                                  print("Erroe");
                                  var result=await showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: Text("Access to your photos"),
                                      content: Text("Unfortunately, you have blocked the application from accessing photos. A photo is not required for the application to work, but if you change your mind, you need to go to settings and add it"),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: Text("Stay"),

                                          onPressed: () => Navigator.of(context).pop(false),
                                        ),
                                        CupertinoDialogAction(
                                          child: Text("Add"),
                                          isDefaultAction: true,
                                          onPressed: () => Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if(result){
                                    AppSettings.openAppSettings().then((value) => setState((){}));
                                  }


                                }

                              }


                            },
                            child: Container(
                              height: 124,
                              decoration: (image_load&&image!=null)?
                                BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black,
                                  image: DecorationImage(
                                      image:  FileImage(File(image!.path)),
                                      fit: BoxFit.cover,
                                      opacity: 0.8
                                  )
                                ) :
                                BoxDecoration(
                                    color: PrimaryCol,
                                    borderRadius: BorderRadius.circular(12),
                                    image: widget.is_new ? null : DecorationImage(
                                        image: NetworkImage(
                                          widget.data['photo_link'],
                                        ),
                                      fit: BoxFit.cover
                                    )
                                ),
                              child: Center(
                                child: SvgPicture.asset("lib/assets/Icons/Bold/Image.svg"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Additional images",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                        CupertinoSwitch(
                            value: additional_iamges,
                            activeColor: PrimaryCol,
                            onChanged: (value) async{
                              setState(() {
                                if(widget.is_new){
                                  additional_iamges=!additional_iamges;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Я пока не сделал чтобы можно было редактировать эти фотки)"),
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              });
                            }
                        ),
                      ],
                    ),
                    if(additional_iamges) ...[
                      if(AdditionalTextLength>2) ...[
                        Text("Slide to the right to see all images",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54),),
                      ],
                      SizedBox(height: 16,),
                      Container(
                        height: 124,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: AdditionalImages.length+1+AdditionalImagesFromEdit.length,
                          itemBuilder: (context,index){

                            return index==0 ? InkWell(
                              onTap: AddImage,
                              child: Container(
                                margin: EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: PrimaryCol,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                width: 124,
                                height: 124,
                                child: Center(
                                  child: SvgPicture.asset("lib/assets/Icons/Bold/Image.svg"),
                                ),
                              ),
                            ) : Container(
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                  image: AdditionalImages[index-1].toString().startsWith("http") ?
                                  DecorationImage(
                                      image:  NetworkImage(AdditionalImages[index-1] as String),
                                      fit: BoxFit.cover,
                                      opacity: 0.8
                                  ) :
                                  DecorationImage(
                                      image:  FileImage(File(AdditionalImages[index-1]!.path)),
                                      fit: BoxFit.cover,
                                      opacity: 0.8
                                  )
                              ),
                              width: 124,
                              height: 124,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: Icon(Icons.close,color: Colors.white,size: 24,),
                                  onPressed: (){
                                    DeleteImage(index-1);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: 16,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Pay for my own wallet",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                        CupertinoSwitch(
                            value: pay_with_my_wallet,
                            activeColor: PrimaryCol,
                            onChanged: (value) async{
                              setState(() {
                                pay_with_my_wallet=!pay_with_my_wallet;
                              });
                            }
                        ),
                      ],
                    ),
                    if(pay_with_my_wallet) ...[
                      SizedBox(height: 4,),
                      Text("After users transfer funds to you, you will need to add them to the event list in the users section of your event",style: TextStyle(fontSize: 13,color: Colors.grey,fontWeight: FontWeight.w500,height: 1.5),),
                      SizedBox(height: 16,),
                      FormPro(MyWalletController,MyWalletNode,"Pay instructions",16,true,""),
                    ] else ...[
                      SizedBox(height: 16,),
                    ],
                    FormPro(PriceController,PriceNode,"Price",16,false,"\$"),
                    FormPro(EventNameController,EventNameNode,"Event name",16,true,""),
                    FormPro(AboutController,AboutNode,"About",16,true,""),
                    FormPro(MaxPeoplesController,MaxPeoplesNode,"Max peoples",16,false,""),
                    Stack(
                      children: [
                        FakeFormPro("Duration "+(MyDuration as Duration).inMinutes.toString()+" min."),
                        InkWell(
                          onTap: (){
                            setState(() {
                              BackDrop=true;
                              ShowPicker=true;
                            });
                          },
                          child: Container(
                            height: 48,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16,),
                    Stack(
                      children: [
                        FakeFormPro(
                          ((_dates.first as DateTime).day<10 ? "0"+(_dates.first as DateTime).day.toString() : (_dates.first as DateTime).day.toString() )+" "+
                              DateFormat.MMMM().format(_dates.first as DateTime).toString()+" "+
                              (_dates.first as DateTime).year.toString()+", "+
                              DateFormat('HH:mm').format(_dates.first as DateTime).toString()
                        ),
                        InkWell(
                          onTap: (){
                            setState(() {
                              print("ss");
                              BackDrop=true;
                              ShowCallendar=true;
                            });
                          },
                          child: Container(
                            height: 48,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 24,),
                    // FormPro(TagController,TagNode,"Tags separated by commas",16,true,""),
                    TextPlusButton("Invite organizers",(){
                      final page = OtherOrganizersPage();
                      Navigator.of(context).push(CustomPageRoute(page)).then((value) { if(value!=null) {setState(() {OtherOrganizers.where((element) => element['phone']==value['phone']).length==0 ? OtherOrganizers.add(value) : null; });}});
                    }),
                    if(OtherOrganizers.length!=0) SizedBox(height: 12,),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: OtherOrganizers.length,
                      itemBuilder: (context,index) {
                        return AddOrganizerCard(context,OtherOrganizers[index]["name"],"Organizer",OtherOrganizers[index]["photo"],(){
                          setState(() {
                            OtherOrganizers.removeAt(index);
                          });},"Close");
                      },
                      separatorBuilder: (context,index) { return Divider(height: 32,color: Colors.black45,);},
                    ),
                    Divider(height: 32,color: Colors.black26,),
                    AdditionalTextPlusButton("Additional text",(){
                      setState(() {AdditionalTextLength=(AdditionalTextLength+1)>1 ? 2 : 1;});

                    },AdditionalTextLength,(){
                      setState(() {AdditionalTextLength=max(0, AdditionalTextLength-1);});
                    }
                    ),
                    if(AdditionalTextLength>0)...[
                      SizedBox(height: 16,),
                      FormPro(EventNameController1,EventNameNode1,"Additional header",16,true,""),
                      FormPro(AboutController1,AboutNode1,"Additional text",8,true,""),
                    ],
                    if(AdditionalTextLength==2)...[
                      SizedBox(height: 16,),
                      FormPro(EventNameController2,EventNameNode2,"Other additional header",16,true,""),
                      FormPro(AboutController2,AboutNode2,"Other additional text",16,true,""),
                    ],
                    Divider(height: 32,color: Colors.black26,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if(IsOnline) ...[
                              Text("Online",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                              Text(" | ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                              Text("offline",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                            ] else ...[
                              Text("Online",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black),),
                              Text(" | ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                              Text("offline",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black),),

                            ],
                          ],
                        ),
                        CupertinoSwitch(
                            value: IsOnline,
                            activeColor: PrimaryCol,
                            onChanged: (value) async{
                              setState(() {
                                IsOnline=!IsOnline;
                                // !IsOnline ? HoldScreen=false : null;
                              });
                            }
                        ),
                      ],
                    ),
                    if(!IsOnline) ...[
                      Divider(height: 32,color: Colors.black26,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if(InDoor) ...[
                                Text("InDoor",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                                Text(" | ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                                Text("Outdoor",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                              ] else ...[
                                Text("InDoor",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black),),
                                Text(" | ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                                Text("Outdoor",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black),),
                              ],
                            ],
                          ),
                          CupertinoSwitch(
                              value: InDoor,
                              activeColor: PrimaryCol,
                              onChanged: (value) async{
                                setState(() {
                                  InDoor=!InDoor;
                                });
                              }
                          ),
                        ],
                      ),
                      SizedBox(height: 16,),
                      Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width-32,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GoogleMap(
                            zoomControlsEnabled: false,
                            // zoomGesturesEnabled: false,
                            mapType: MapType.normal,
                            myLocationButtonEnabled: false,
                            myLocationEnabled: AllowMySelfGeo,
                            initialCameraPosition: _kGooglePlex,
                            gestureRecognizers: Set()..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
                            onTap: (LatLngg){
                              _markers.clear();

                              _markers.add(Marker(
                                markerId: MarkerId("place.id"),
                                position: LatLngg,
                                infoWindow: InfoWindow(
                                  title: EventNameController.text,
                                ),
                                icon: BitmapDescriptor.defaultMarker,
                              ));
                              print(_markers.length);

                              setState(() {

                              });
                            },
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            // polygons: _polygon,
                            markers: Set<Marker>.of(_markers as Iterable<Marker>),
                          ),
                        ),
                      ),
                      SizedBox(height: 24,),
                      FormPro(AdresController,AdresNode,"Address",16,true,""),
                      FormPro(ShortAdresController,ShortAdresNode,"Short address",16,true,""),
                      FormPro(LocationInfoController,LocationInfoNode,"Location info",16,true,""),
                      FormPro(ParkingInfoController,ParkingInfoNode,"Parking info",0,true,""),
                    ],
                    SizedBox(height: 24,),
                    ButtonPro(widget.is_new ? "Add event" : "Update event", () async{
                      if(widget.is_new){
                        if(CanAddEvent()){
                          AddEvent();
                          Navigator.pop(context);
                        }
                      }
                      if(CanUpdateEvent()&&!widget.is_new){
                        UpdateEvent();
                        final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: false,);
                        Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
                        // Navigator.of(context).push(CustomPageRoute(page));
                      }
                    },WaitForNextStep),
                    SizedBox(height: 24,),
                  ],
                ),
              ),
            ),
          ),
          if(BackDrop) ...[
            InkWell(
              onTap: (){
                setState(() {
                  BackDrop=false;
                  ShowPicker=false;
                  ShowCallendar=false;
                });
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black12,
                ),
              ),
            ),
          ],
          if(ShowPicker)...[
            Center(
              child: Container(
                width: 300,
                height: 372,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 24,),
                    Text("Choice duration",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700,),),
                    SizedBox(height: 12,),
                    CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.hm,
                        initialTimerDuration: MyDuration,
                        onTimerDurationChanged: (value){
                          MyDuration=value;
                        }
                    ),
                    SizedBox(height: 12,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: ButtonPro("Choice", (){
                        DateTime newDate = DateTime.now();
                        DateTime formatedDate = newDate.subtract(Duration(hours: newDate.hour, minutes: newDate.minute, seconds: newDate.second, milliseconds: newDate.millisecond, microseconds: newDate.microsecond));
                        // finalDate=formatedDate.add(MyDuration);

                        print(finalDate.toString());
                        setState(() {
                          BackDrop=false;
                          ShowPicker=false;
                          ShowCallendar=false;
                        });
                      },false),
                    ),

                  ],
                ),
              ),
            )
          ],
          if(ShowCallendar) ...[
            Align(
              child: Container(
                width: 300,
                height: 340,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 220,
                      // color: Colors.red,
                      child: Localizations.override(
                        context: context,
                        child: Builder(
                          builder: (context){
                            return CalendarDatePicker2(
                              config: CalendarDatePicker2Config(),
                              value: _dates,
                              onValueChanged: (dates) {
                                dates_var=dates.first ?? DateTime.now();
                                // print(DateTime.now().minute.toString());

                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              padding: EdgeInsets.only(left: 16,),
                            child: Text("Date",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black87),)
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 0),
                              width: 62,
                              height: 32,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromRGBO(226, 230, 239, 1)
                              ),
                              margin: EdgeInsets.only(right: 16),
                              child: Center(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  showCursor: false,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  autofocus: true,
                                  style: TextStyle(fontFamily: "SFPro",fontSize: 14,fontWeight: FontWeight.w500),
                                  inputFormatters: [
                                    MaskTextInputFormatter(mask: "20:30", filter: {"0": RegExp(r'[0-9]'),"2":RegExp(r'[0-2]'),"3":RegExp(r'[0-5]')})
                                  ],
                                  onChanged: (value){
                                    DatesTimeLength=value.length;
                                    DatesTime=value;
                                    if(DatesTimeLength==5){
                                      _dates = [(dates_var as DateTime?)?.add(Duration(hours: int.parse(value.substring(0,2)))).add(Duration(minutes: int.parse(value.substring(3,5))))];
                                    }
                                  },
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintStyle: TextStyle(color: Colors.grey,fontSize: 14),
                                    border: InputBorder.none,
                                    hintText: DateFormat('HH:mm').format(_dates.first ?? DateTime.now()).toString(),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12,),
                    InkWell(
                      onTap: (){
                        DateTime newDate = dates_var;
                        DateTime formatedDate = newDate.subtract(Duration(hours: newDate.hour, minutes: newDate.minute, seconds: newDate.second, milliseconds: newDate.millisecond, microseconds: newDate.microsecond));
                        if(DatesTimeLength==5){
                          _dates = [(formatedDate as DateTime?)?.add(Duration(hours: int.parse(DatesTime.substring(0,2)))).add(Duration(minutes: int.parse(DatesTime.substring(3,5))))];
                        } else {
                          _dates = [(formatedDate as DateTime?)?.add(Duration(hours: DateTime.now().hour)).add(Duration(minutes: DateTime.now().minute))];
                        }
                        setState(() {
                          ShowCallendar=false;
                          BackDrop=false;
                        });
                      },
                      child: Container(
                        height: 56,
                        width: 300-32,
                        margin: EdgeInsets.only(left: 16),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(229, 234, 245, 1),
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Center(
                            // child: Text(AppLocalizations.of(context)!.select,style: TextStyle(fontFamily: "SFPro",fontSize: 16,fontWeight: FontWeight.w700,),)
                          child: Text("Выбрать",style: TextStyle(fontFamily: "SFPro",fontSize: 16,fontWeight: FontWeight.w700,),)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomNavBarPro(context, 2),
    );
  }
}
