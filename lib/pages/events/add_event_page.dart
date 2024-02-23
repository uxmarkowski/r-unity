import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:event_app/functions/hive_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:app_settings/app_settings.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:event_app/pages/events/event_list_page.dart';
import 'package:event_app/pages/sign/sign_up.dart';
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
import 'package:instant/instant.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/custom_route.dart';
import 'other_organizers_page.dart';


class AddEventPage extends StatefulWidget {
  final data;
  final is_new;
  final is_dublicate;
  const AddEventPage({Key? key,required this.data, required this.is_new, required this.is_dublicate}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {

  static const CameraPosition _kGooglePlex = CameraPosition(target: LatLng(34.052235,-118.243683),   zoom: 14.4746,);
  static const CameraPosition _kLake = CameraPosition(bearing: 192.8334901395799, target: LatLng(37.43296265331129, -122.08832357078792), tilt: 59.440717697143555, zoom: 19.151926040649414);
  bool AllowMySelfGeo=true; final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final Set<Marker> _markers = new Set();
  final Set<Circle> _circles = new Set();

  var MapTypeUser=0;
  bool RussianLanguage=false;
  Map TranslatedCategory=Map();



  late VideoPlayerController video_controller;

  DateFormat format = new DateFormat("MMMM");

  TextEditingController EventNameController=TextEditingController(); TextEditingController RussianEventNameController=TextEditingController();
  TextEditingController EventNameController1=TextEditingController(); TextEditingController RussianEventNameController1=TextEditingController();
  TextEditingController EventNameController2=TextEditingController(); TextEditingController RussianEventNameController2=TextEditingController();

  TextEditingController AboutController=TextEditingController(); TextEditingController RussianAboutController=TextEditingController();
  TextEditingController AboutController1=TextEditingController(); TextEditingController RussianAboutController1=TextEditingController();
  TextEditingController AboutController2=TextEditingController(); TextEditingController RussianAboutController2=TextEditingController();

  TextEditingController PrimaryLanguageController=TextEditingController();
  TextEditingController PriceController=TextEditingController();
  TextEditingController MyWalletInstructionController=TextEditingController(); TextEditingController RussianMyWalletInstructionController=TextEditingController();
  TextEditingController MyWalletController=TextEditingController();
  TextEditingController MyWalletLinkController=TextEditingController();

  TextEditingController InstagramController=TextEditingController();TextEditingController FacebookController=TextEditingController();TextEditingController TelegramController=TextEditingController();

  TextEditingController MaxPeoplesController=TextEditingController();TextEditingController PromoCodeController=TextEditingController();TextEditingController PromoCode2Controller=TextEditingController();TextEditingController PromoCode3Controller=TextEditingController();TextEditingController PromoCode4Controller=TextEditingController();TextEditingController PromoCode5Controller=TextEditingController();TextEditingController PromoCode6Controller=TextEditingController();TextEditingController PromoCode7Controller=TextEditingController();
  TextEditingController AdresController=TextEditingController(); TextEditingController RussianAdresController=TextEditingController();
  TextEditingController ShortAdresController=TextEditingController(); TextEditingController RussianShortAdresController=TextEditingController();
  TextEditingController LocationInfoController=TextEditingController(); TextEditingController RussianLocationInfoController=TextEditingController();
  TextEditingController ParkingInfoController=TextEditingController(); TextEditingController RussianParkingInfoController=TextEditingController();


  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();

  FocusNode EventNameNode=FocusNode(); FocusNode RussianEventNameNode=FocusNode();
  FocusNode EventNameNode1=FocusNode(); FocusNode RussianEventNameNode1=FocusNode();
  FocusNode EventNameNode2=FocusNode(); FocusNode RussianEventNameNode2=FocusNode();

  FocusNode AboutNode=FocusNode(); FocusNode RussianAboutNode=FocusNode();
  FocusNode AboutNode1=FocusNode(); FocusNode RussianAboutNode1=FocusNode();
  FocusNode AboutNode2=FocusNode(); FocusNode RussianAboutNode2=FocusNode();

  FocusNode PrimaryLanguageNode=FocusNode();
  FocusNode PriceNode=FocusNode();
  FocusNode MyWalletInstructionNode=FocusNode(); FocusNode RussianMyWalletInstructionNode=FocusNode();
  FocusNode MyWalletNode=FocusNode();
  FocusNode MyWalletLinkNode=FocusNode();

  FocusNode InstagramNode=FocusNode();FocusNode FacebookNode=FocusNode();FocusNode TelegramNode=FocusNode();

  FocusNode MaxPeoplesNode=FocusNode();FocusNode PromoCodeNode=FocusNode();FocusNode PromoCodeNode2=FocusNode();FocusNode PromoCodeNode3=FocusNode();FocusNode PromoCodeNode4=FocusNode();FocusNode PromoCodeNode5=FocusNode();FocusNode PromoCodeNode6=FocusNode();FocusNode PromoCodeNode7=FocusNode();

  FocusNode AdresNode=FocusNode(); FocusNode RussianAdresNode=FocusNode();
  FocusNode ShortAdresNode=FocusNode(); FocusNode RussianShortAdresNode=FocusNode();
  FocusNode LocationInfoNode=FocusNode(); FocusNode RussianLocationInfoNode=FocusNode();
  FocusNode ParkingInfoNode=FocusNode(); FocusNode RussianParkingInfoNode=FocusNode();

  bool video_initialized=false;


  List<DateTime?> _dates=[];
  DateTime dates_var=DateTime.now().add(Duration(days: 1));
  DateTime finalDate=DateTime.now().add(Duration(days: 1));
  Duration MyDuration=Duration(hours: 0,minutes: 0);
  Duration MyDurationDate=Duration(hours: 0,minutes: 0);

  List MyOrganizerEvents=[];
  List OtherOrganizers=[];
  List AdditionalImagesFromEdit=[];
  List Categories=[];
  List Languages=["Все языки","All languages","American English","English","Русский","Українська","Қазақ","հայերեն"];
  List Cities=["Los Angeles"];
  // List Cities=["Los Angeles","New York"];


  int DatesTimeLength=0;
  int AdditionalTextLength=0;
  int PromoCodeLength=0;
  double PromoCodeValue=50;
  double PromoCodeValue2=50;
  double PromoCodeValue3=50;
  double PromoCodeValue4=50;
  double PromoCodeValue5=50;
  double PromoCodeValue6=50;
  double PromoCodeValue7=50;

  String DatesTime="00:00";
  String CurrentCategory="All category";
  String CurrentLanguage="All languages";
  String CurrentCity="Los Angeles";
  String EvenId="";
  String my_video_link="";

  bool InfinityUsers=false;
  bool IsOnline=true;
  bool InDoor=false;
  bool HideExactAdress=false;
  bool ShowPicker=false;
  bool BackDrop=false;
  bool ShowCallendar=false;
  bool WaitForNextStep=false;
  bool image_load=false;
  bool video_load=false;
  bool web_video_exist=false;
  bool additional_iamges=false;
  bool pay_with_my_wallet=false;
  bool social_media_exist=false;
  bool limited_unlimited_users=false;
  bool free_admission=false;
  bool kids_allowed=false;
  bool russian_text=false;
  bool show_flag=false;
  bool is_video_horizontal=false;
  double video_size_index=0;

  int GenderValue=0;


  final ImagePicker _picker = ImagePicker();
  late XFile? image;
  late XFile? video;
  List<dynamic> AdditionalImages=[];



  bool CanAddEvent(){
    if(EventNameController.text.length==0){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_event_name);
      // ScaffoldMessa("Please fill \"Event name\"");
      return false;
    } else if(PriceController.text.length==0&&!free_admission&&!InfinityUsers){
      ScaffoldMessa(AppLocalizations.of(context)!.please_add_price);
      // ScaffoldMessa("Please add \"Price\"");
      return false;
    } else if(AboutController.text.length==0){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_about);
      // ScaffoldMessa("Please fill \"About\"");
      return false;
    } else if(!IsOnline&&(AdresController.text.length==0||_markers.length==0)){
      ScaffoldMessa(_markers.length!=0 ? AppLocalizations.of(context)!.please_fill_address : AppLocalizations.of(context)!.please_add_geo_point);
      // ScaffoldMessa(_markers.length!=0 ? "Please fill \"Adres\"" :"Please make geopoint");
      return false;
    } else if(!IsOnline&&HideExactAdress&&_circles.length==0){
      ScaffoldMessa(AppLocalizations.of(context)!.please_add_approxiamte_geopoint);
      // ScaffoldMessa("Please add approxiamte geopoint");
      return false;
    } else if(MyDuration.inMinutes==0){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_duration);
      // ScaffoldMessa("Please fill \"Duration\"");
      return false;
    } else if(!image_load){
      ScaffoldMessa(AppLocalizations.of(context)!.please_add_an_image);
      // ScaffoldMessa("Please add an image");
      return false;
    } else if(AdditionalTextLength>0&&((EventNameController1.text.length==0||AboutController1.text.length==0))){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_additional_information);
      // ScaffoldMessa("Please fill additional information");
      return false;
    } else if(AdditionalTextLength>1&&((EventNameController2.text.length==0||AboutController2.text.length==0))){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_additional_information);
      // ScaffoldMessa("Please fill additional information");
      return false;
    } else if(pay_with_my_wallet&&MyWalletInstructionController.text.length==0&&!InfinityUsers){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_payment_instructions);
      // ScaffoldMessa("Please fill payment instructions");
      return false;
    } else if(MaxPeoplesController.text.length==0&&!InfinityUsers){
      ScaffoldMessa(limited_unlimited_users ? AppLocalizations.of(context)!.please_fill_approximate_peoples_count : AppLocalizations.of(context)!.please_fill_max_peoples_count);
      // ScaffoldMessa(limited_unlimited_users ? "Please fill approximate peoples count" : "Please fill max peoples count");
      return false;
    } else if(!IsOnline){
      if(AdresController.text.length==0){
        ScaffoldMessa(AppLocalizations.of(context)!.please_fill_address);
        // ScaffoldMessa("Please fill adress");
        return false;
      } if(ShortAdresController.text.length==0){
        ScaffoldMessa(AppLocalizations.of(context)!.please_fill_short_address);
        // ScaffoldMessa("Please fill short address");
        return false;
      } if(_markers.length==0){
        ScaffoldMessa(AppLocalizations.of(context)!.please_add_geo_point);
        // ScaffoldMessa("Please add geo point");

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

    russian_text=(widget.data as Map).containsKey("russian_text") ? widget.data['russian_text'] : false;
    InfinityUsers=(widget.data as Map).containsKey("infinity_users") ? widget.data['infinity_users'] : false;
    my_video_link=(widget.data as Map).containsKey("my_video_link") ? widget.data['my_video_link'] : "";
    is_video_horizontal=(widget.data as Map).containsKey("is_video_horizontal") ? widget.data['is_video_horizontal'] : false;
    video_size_index=(widget.data as Map).containsKey("video_size_index") ? widget.data['video_size_index'] : 0;


    EventNameController.text=widget.data['header'];
    EventNameController1.text=(widget.data as Map).containsKey("header1") ? widget.data['header1'] : "";
    EventNameController2.text=(widget.data as Map).containsKey("header2") ? widget.data['header2'] : "";
    CurrentLanguage=(widget.data as Map).containsKey("primary_language") ? widget.data['primary_language'] : "All languages";
    show_flag=(widget.data as Map).containsKey("show_flag") ? widget.data['show_flag'] : false;

    RussianEventNameController.text=(widget.data as Map).containsKey("rus_header") ? widget.data['rus_header'] : "";
    RussianEventNameController1.text=(widget.data as Map).containsKey("rus_header1") ? widget.data['rus_header1'] : "";
    RussianEventNameController2.text=(widget.data as Map).containsKey("rus_header2") ? widget.data['rus_header2'] : "";

    InstagramController.text=(widget.data as Map).containsKey("instagram") ? widget.data['instagram'] : "";
    FacebookController.text=(widget.data as Map).containsKey("facebook") ? widget.data['facebook'] : "";
    TelegramController.text=(widget.data as Map).containsKey("telegram") ? widget.data['telegram'] : "";

    PromoCodeController.text=(widget.data as Map).containsKey("promo_code_name") ? widget.data['promo_code_name'] : "";
    PromoCodeValue=(widget.data as Map).containsKey("promo_code_value") ? double.parse(widget.data['promo_code_value'].toString()) : 1.0;

    PromoCode2Controller.text=(widget.data as Map).containsKey("promo_code_name2") ? widget.data['promo_code_name2'] : "";
    PromoCodeValue2=(widget.data as Map).containsKey("promo_code_value2") ? double.parse(widget.data['promo_code_value2'].toString()) : 1.0;

    PromoCode3Controller.text=(widget.data as Map).containsKey("promo_code_name3") ? widget.data['promo_code_name3'] : "";
    PromoCodeValue3=(widget.data as Map).containsKey("promo_code_value3") ? double.parse(widget.data['promo_code_value3'].toString()) : 1.0;

    PromoCode4Controller.text=(widget.data as Map).containsKey("promo_code_name4") ? widget.data['promo_code_name4'] : "";
    PromoCodeValue4=(widget.data as Map).containsKey("promo_code_value4") ? double.parse(widget.data['promo_code_value4'].toString()) : 1.0;

    PromoCode5Controller.text=(widget.data as Map).containsKey("promo_code_name5") ? widget.data['promo_code_name5'] : "";
    PromoCodeValue5=(widget.data as Map).containsKey("promo_code_value5") ? double.parse(widget.data['promo_code_value5'].toString()) : 1.0;

    PromoCode6Controller.text=(widget.data as Map).containsKey("promo_code_name6") ? widget.data['promo_code_name6'] : "";
    PromoCodeValue6=(widget.data as Map).containsKey("promo_code_value6") ? double.parse(widget.data['promo_code_value6'].toString()) : 1.0;

    PromoCode7Controller.text=(widget.data as Map).containsKey("promo_code_name7") ? widget.data['promo_code_name7'] : "";
    PromoCodeValue7=(widget.data as Map).containsKey("promo_code_value7") ? double.parse(widget.data['promo_code_value7'].toString()) : 1.0;

    PromoCodeLength=(widget.data as Map).containsKey("promo_code_length") ? widget.data['promo_code_length'].toString().length>1 ? 1 : 0 : 0;

    MyWalletInstructionController.text=(widget.data as Map).containsKey("my_wallet_instructions") ? widget.data['my_wallet_instructions'] : "";
    RussianMyWalletInstructionController.text=(widget.data as Map).containsKey("rus_my_wallet_instructions") ? widget.data['rus_my_wallet_instructions'] : "";

    MyWalletController.text=(widget.data as Map).containsKey("my_wallet") ? widget.data['my_wallet'] : "";
    MyWalletLinkController.text=(widget.data as Map).containsKey("my_wallet_paylink") ? widget.data['my_wallet_paylink'] : "";

    AboutController.text=widget.data['about'];
    AboutController1.text=(widget.data as Map).containsKey("about1") ? widget.data['about1'] : "";
    AboutController2.text=(widget.data as Map).containsKey("about2") ? widget.data['about2'] : "";

    RussianAboutController.text=(widget.data as Map).containsKey("rus_about") ? widget.data['rus_about'] : "";
    RussianAboutController1.text=(widget.data as Map).containsKey("rus_about1") ? widget.data['rus_about1'] : "";
    RussianAboutController2.text=(widget.data as Map).containsKey("rus_about2") ? widget.data['rus_about2'] : "";


    AdditionalTextLength=(widget.data as Map).containsKey("additional_text_count") ? widget.data['additional_text_count'] : 0;
    GenderValue=(widget.data as Map).containsKey("gender") ? widget.data['gender'] : 0;

    PriceController.text=widget.data['price'];
    // TagController.text=(widget.data['tags'] as List).join(", ");
    MaxPeoplesController.text=widget.data['max_peoples'].toString();
    MyDuration=Duration(minutes: widget.data['duration']);
    _dates.length==0 ? _dates.add(DateTime.fromMillisecondsSinceEpoch(widget.data['date']))  : _dates.first=DateTime.fromMillisecondsSinceEpoch(widget.data['date']);
    AdresController.text=widget.data['address'];
    ShortAdresController.text=(widget.data as Map).containsKey("short_address") ? widget.data['short_address'] : "";
    LocationInfoController.text=widget.data['location_info'];
    ParkingInfoController.text=widget.data['parking_info'];
    limited_unlimited_users=widget.data['unlimited_users'];
    social_media_exist=(widget.data as Map).containsKey("social_media_exist") ? widget.data['social_media_exist'] : false;
    kids_allowed=(widget.data as Map).containsKey("kids_allowed") ? widget.data['kids_allowed'] : false;
    free_admission=(widget.data as Map).containsKey("free_admission") ? widget.data['free_admission'] : false;
    IsOnline=widget.data['is_online'];
    InDoor=widget.data['is_indor'];
    pay_with_my_wallet=(widget.data as Map).containsKey("pay_with_my_wallet") ? widget.data['pay_with_my_wallet'] : false;

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

      } if(widget.data['aproximate_geo_point']!=""){
        var _GeoPointTwo=widget.data['aproximate_geo_point'] as GeoPoint;
        _circles.add(
          Circle(
              circleId: CircleId("id"),
              center: LatLng(_GeoPointTwo.latitude,_GeoPointTwo.longitude),
              radius: 300,
              fillColor: Colors.black12,
              strokeWidth: 2,
              strokeColor: Colors.blueAccent
          ),
        );
      }

    }

    setState(() { });

  }

  void GetEvents() async{
    var Events=await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).get();
    // MyOrganizerEvents=Events.data()!['organizer_events'];
  }

  void SendIviteToOrganizers(photo_url,event_doc) async{

    if(OtherOrganizers.length>0){
      await Future.forEach(OtherOrganizers, (organazier) async{
        if(widget.is_new){
          await firestore.collection("UsersCollection").doc(organazier["phone"]).collection("Notifications").add(
              {
                "title":"You are invited by the organizer to "+EventNameController.text,
                "title_rus":"Вас пригласили стать оргонизатором в "+EventNameController.text,
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
                "title_rus":"Вас пригласили стать оргонизатором в "+EventNameController.text,
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
        title: Text(AppLocalizations.of(context)!.access_to_your_photos),
        // title: Text("Access to your photos"),
        content: Text(AppLocalizations.of(context)!.unfortunately_you_have_blocked),
        // content: Text("Unfortunately, you have blocked the application from accessing photos. A photo is not required for the application to work, but if you change your mind, you need to go to settings and add it"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.stay),
            // child: Text("Stay"),

            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.add),
            // child: Text("Add"),
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

    if(video_load&&video!=null){
      my_video_link=await prepare_video();
    }



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
      // AdditinalImgLinks.insert(0, urrr);
    }




    await firestore.collection("Events").add({
      "header":EventNameController.text,  "header1":EventNameController1.text,  "header2":EventNameController2.text,
      "rus_header":RussianEventNameController.text,  "rus_header1":RussianEventNameController1.text,  "rus_header2":RussianEventNameController2.text,
      "about":AboutController.text, "about1":AboutController1.text,  "about2":AboutController2.text,
      "rus_about":RussianAboutController.text, "rus_about1":RussianAboutController1.text,  "rus_about2":RussianAboutController2.text,
      "russian_exist":russian_text,
      "promo_code_value":PromoCodeValue.round(), "promo_code_value2":PromoCodeValue2.round(), "promo_code_value3":PromoCodeValue3.round(), "promo_code_value4":PromoCodeValue4.round(), "promo_code_value5":PromoCodeValue5.round(), "promo_code_value6":PromoCodeValue5.round(), "promo_code_value7":PromoCodeValue5.round(),
      "promo_code_name":PromoCodeController.text, "promo_code_name2":PromoCode2Controller.text, "promo_code_name3":PromoCode3Controller.text, "promo_code_name4":PromoCode4Controller.text, "promo_code_name5":PromoCode5Controller.text, "promo_code_name6":PromoCode5Controller.text, "promo_code_name7":PromoCode5Controller.text,
      "promo_code_length":PromoCodeLength,
      "my_video_link":my_video_link,
      "is_video_horizontal":is_video_horizontal,
      "video_size_index":video_size_index,
      "additional_text_count":AdditionalTextLength,
      "infinity_users":InfinityUsers,
      "price":free_admission ? "0":PriceController.text,
      "duration":(MyDuration as Duration).inMinutes,
      "date":_dates.length==0 ? DateTime.now().millisecondsSinceEpoch : (_dates.first as DateTime).millisecondsSinceEpoch,
      "address":AdresController.text, "rus_address":RussianAdresController.text,
      "short_address":ShortAdresController.text, "rus_short_address":RussianShortAdresController.text,
      "location_info":LocationInfoController.text, "rus_location_info":RussianLocationInfoController.text,
      "parking_info":ParkingInfoController.text, "rus_parking_info":ParkingInfoController.text,
      "geo_point":IsOnline ? "" : GeoPoint(_markers.first.position.latitude,_markers.first.position.longitude),
      "aproximate_geo_point":(!IsOnline&&HideExactAdress) ? GeoPoint(_circles.first.center.latitude,_circles.first.center.longitude) : "",
      "instagram":InstagramController.text,
      "facebook":FacebookController.text,
      "telegram":TelegramController.text,
      "is_online":IsOnline,
      "hide_exact_address":HideExactAdress,
      "is_indor":InDoor,
      "peoples":0,
      "max_peoples":int.parse(MaxPeoplesController.text),
      "photo_path": Avatar_Path.toString(),
      "photo_link": urrr.toString(),
      "additional_photo_links": AdditinalImgLinks,
      "pay_with_my_wallet": pay_with_my_wallet,
      "my_wallet_instructions": MyWalletInstructionController.text, "rus_my_wallet_instructions": RussianMyWalletInstructionController.text,
      "my_wallet": MyWalletController.text,
      "my_wallet_paylink": MyWalletLinkController.text,
      "social_media_exist":social_media_exist,
      "free_admission": free_admission,
      "kids_allowed": kids_allowed,
      "unlimited_users": limited_unlimited_users,
      "approved": false,
      "gender": GenderValue,
      "category": CurrentCategory,
      "primary_language": CurrentLanguage,
      "show_flag": show_flag,

    }).then((value) async{
      SendIviteToOrganizers(urrr,value.id);

      // MyOrganizerEvents.add(value.id); // Добавление себе в оргайназерсы
      // firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"organizer_events":MyOrganizerEvents}); // Collection Updated
      await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("OrganizerEvents").doc(value.id).set({"active":"true"});
      await firestore.collection("Events").doc(value.id).collection("Organizers").doc(_auth.currentUser!.phoneNumber).set({"active":"true"});
      await firestore.collection("Events").doc(value.id).collection("Messages").doc(_auth.currentUser!.phoneNumber).set({"active":"true"});
      await firestore.collection("Events").doc(value.id).collection("Messages").doc(_auth.currentUser!.phoneNumber).delete();
    });

    ScaffoldMessa("Please wait while your Event is being verified");



    final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: true, ApproveWidgets: false,);
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);

    setState(() {
      WaitForNextStep=false;
    });
  }

  Future<String> prepare_video() async {
    var Video_Path="events_video/event_"+DateTime.now().millisecondsSinceEpoch.toString()+".mp4";
    final videoRef = storageRef.child(Video_Path); File video_file = File(video!.path);
    await videoRef.putFile(video_file); var video_link=await videoRef.getDownloadURL();
    return video_link;
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

    SendIviteToOrganizers(urrrr,widget.data['doc_id']);

    var AdditinalImgLinks=[];

    if(video_load){
      my_video_link=await prepare_video();
    }

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
      // AdditinalImgLinks.insert(0, urrrr);
    }

    await firestore.collection("Events").doc(widget.data['doc_id']).update({
      "header":EventNameController.text,  "header1":EventNameController1.text,  "header2":EventNameController2.text,
      "rus_header":RussianEventNameController.text,  "rus_header1":RussianEventNameController1.text,  "rus_header2":RussianEventNameController2.text,
      "about":AboutController.text, "about1":AboutController1.text,  "about2":AboutController2.text,
      "rus_about":RussianAboutController.text, "rus_about1":RussianAboutController1.text,  "rus_about2":RussianAboutController2.text,
      "russian_exist":russian_text,
      "promo_code_value":PromoCodeValue.round(), "promo_code_value2":PromoCodeValue2.round(), "promo_code_value3":PromoCodeValue3.round(), "promo_code_value4":PromoCodeValue4.round(), "promo_code_value5":PromoCodeValue5.round(), "promo_code_value6":PromoCodeValue5.round(), "promo_code_value7":PromoCodeValue5.round(),
      "promo_code_name":PromoCodeController.text, "promo_code_name2":PromoCode2Controller.text, "promo_code_name3":PromoCode3Controller.text, "promo_code_name4":PromoCode4Controller.text, "promo_code_name5":PromoCode5Controller.text, "promo_code_name6":PromoCode5Controller.text, "promo_code_name7":PromoCode5Controller.text,
      "promo_code_length":PromoCodeLength,
      "additional_text_count":AdditionalTextLength,
      "my_video_link":video_load ? my_video_link : (my_video_link!="" ? (widget.data['my_video_link'] ?? "") : ""),
      "is_video_horizontal":is_video_horizontal,
      "video_size_index":video_size_index,
      "infinity_users":InfinityUsers,
      "price":free_admission ? "0":PriceController.text,
      "duration":(MyDuration as Duration).inMinutes,
      "date":_dates.length==0 ? DateTime.now().millisecondsSinceEpoch : (_dates.first as DateTime).millisecondsSinceEpoch,
      "address":AdresController.text,
      "geo_point":IsOnline ? "" : GeoPoint(_markers.first.position.latitude,_markers.first.position.longitude),
      "aproximate_geo_point":(!IsOnline&&HideExactAdress) ? GeoPoint(_circles.first.center.latitude,_circles.first.center.longitude) : "",
      "short_address":ShortAdresController.text, "rus_short_address":RussianShortAdresController.text,
      "location_info":LocationInfoController.text, "rus_location_info":RussianLocationInfoController.text,
      "parking_info":ParkingInfoController.text, "rus_parking_info":ParkingInfoController.text,
      "hide_exact_address":HideExactAdress,
      "instagram":InstagramController.text,
      "facebook":FacebookController.text,
      "telegram":TelegramController.text,
      "is_online":IsOnline,
      "is_indor":InDoor,
      "peoples":0,
      "pay_with_my_wallet": pay_with_my_wallet,
      "my_wallet_instructions": MyWalletInstructionController.text, "rus_my_wallet_instructions": RussianMyWalletInstructionController.text,
      "my_wallet": MyWalletController.text,
      "my_wallet_paylink": MyWalletLinkController.text,
      "max_peoples":int.parse(MaxPeoplesController.text),
      "photo_link": (image_load) ? urrrr.toString() : widget.data['photo_link'],
      "additional_photo_links": AdditinalImgLinks,
      "gender": GenderValue,
      "social_media_exist":social_media_exist,
      "kids_allowed": kids_allowed,
      "category": CurrentCategory,
      "primary_language": CurrentLanguage,
      "show_flag": show_flag,
    });



    final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: false,);
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
    setState(() { WaitForNextStep=false; });

  }

  void DublicateEvent() async{
    setState(() {
      WaitForNextStep=true;
    });
    var urrrr=widget.data['photo_link'];

    if(image_load){

      var Avatar_Path="events_photo/event_"+DateTime.now().millisecondsSinceEpoch.toString()+".jpg";
      final photoRef = storageRef.child(Avatar_Path); File file = File(image!.path);
      await photoRef.putFile(file); urrrr=await photoRef.getDownloadURL();

    }

    SendIviteToOrganizers(urrrr,widget.data['doc_id']);

    var AdditinalImgLinks=[];

    if(video_load){
      my_video_link=await prepare_video();
    }

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
      // AdditinalImgLinks.insert(0, urrrr);
    }

    await firestore.collection("Events").add({
      "header":EventNameController.text,  "header1":EventNameController1.text,  "header2":EventNameController2.text,
      "rus_header":RussianEventNameController.text,  "rus_header1":RussianEventNameController1.text,  "rus_header2":RussianEventNameController2.text,
      "about":AboutController.text, "about1":AboutController1.text,  "about2":AboutController2.text,
      "rus_about":RussianAboutController.text, "rus_about1":RussianAboutController1.text,  "rus_about2":RussianAboutController2.text,
      "promo_code_value":PromoCodeValue.round(),
      "russian_exist":russian_text,
      "free_admission": free_admission,
      "promo_code_name":PromoCodeController.text,
      "additional_text_count":AdditionalTextLength,
      "my_video_link":video_load ? my_video_link : (my_video_link!="" ? (widget.data['my_video_link'] ?? "") : ""),
      "is_video_horizontal":is_video_horizontal,
      "video_size_index":video_size_index,
      "price":free_admission ? "0":PriceController.text,
      "duration":(MyDuration as Duration).inMinutes,
      "date":_dates.length==0 ? DateTime.now().millisecondsSinceEpoch : (_dates.first as DateTime).millisecondsSinceEpoch,
      "address":AdresController.text,
      "geo_point":IsOnline ? "" : GeoPoint(_markers.first.position.latitude,_markers.first.position.longitude),
      "aproximate_geo_point":(!IsOnline&&HideExactAdress) ? GeoPoint(_circles.first.center.latitude,_circles.first.center.longitude) : "",
      "short_address":ShortAdresController.text, "rus_short_address":RussianShortAdresController.text,
      "location_info":LocationInfoController.text, "rus_location_info":RussianLocationInfoController.text,
      "parking_info":ParkingInfoController.text, "rus_parking_info":ParkingInfoController.text,
      "hide_exact_address":HideExactAdress,
      "instagram":InstagramController.text,
      "facebook":FacebookController.text,
      "telegram":TelegramController.text,
      "is_online":IsOnline,
      "is_indor":InDoor,
      "peoples":0,
      "approved": false,
      "unlimited_users": limited_unlimited_users,
      "pay_with_my_wallet": pay_with_my_wallet,
      "my_wallet_instructions": MyWalletInstructionController.text, "rus_my_wallet_instructions": RussianMyWalletInstructionController.text,
      "my_wallet": MyWalletController.text,
      "my_wallet_paylink": MyWalletLinkController.text,
      "max_peoples":int.parse(MaxPeoplesController.text),
      "photo_link": (image_load) ? urrrr.toString() : widget.data['photo_link'],
      "additional_photo_links": AdditinalImgLinks,
      "gender": GenderValue,
      "social_media_exist":social_media_exist,
      "kids_allowed": kids_allowed,
      "category": CurrentCategory,
      "primary_language": CurrentLanguage,
      "show_flag": show_flag,
    }).then((value) async{
      SendIviteToOrganizers((image_load) ? urrrr.toString() : widget.data['photo_link'],value.id);

      // MyOrganizerEvents.add(value.id); // Добавление себе в оргайназерсы
      // firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({"organizer_events":MyOrganizerEvents}); // Collection Updated
      await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).collection("OrganizerEvents").doc(value.id).set({"active":"true"});
      await firestore.collection("Events").doc(value.id).collection("Organizers").doc(_auth.currentUser!.phoneNumber).set({"active":"true"});
      await firestore.collection("Events").doc(value.id).collection("Messages").doc(_auth.currentUser!.phoneNumber).set({"active":"true"});
      await firestore.collection("Events").doc(value.id).collection("Messages").doc(_auth.currentUser!.phoneNumber).delete();
    });



    final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: false,);
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
    setState(() { WaitForNextStep=false; });

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
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_event_name);
      // ScaffoldMessa("Please fill \"Event name\"");
      return false;
    } else if(PriceController.text.length==0&&!free_admission&&!InfinityUsers){
      ScaffoldMessa(AppLocalizations.of(context)!.please_add_price);
      // ScaffoldMessa("Please fill \"Price\"");
      return false;
    }  else if(AboutController.text.length==0){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_about);
      // ScaffoldMessa("Please fill \"About\"");
      return false;
    } else if(!IsOnline&&AdresController.text.length==0){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_address);
      // ScaffoldMessa("Please fill \"Addres\"");
      return false;
    } else if(!IsOnline&&(AdresController.text.length==0||_markers.length==0)){
      ScaffoldMessa(_markers.length!=0 ? AppLocalizations.of(context)!.please_fill_address : AppLocalizations.of(context)!.please_make_geopoint);
      // ScaffoldMessa(_markers.length!=0 ? "Please fill \"Adres\"" :"Please make geopoint");
      return false;
    } else if(!IsOnline&&HideExactAdress&&_circles.length==0){
      ScaffoldMessa(AppLocalizations.of(context)!.please_add_approxiamte_geopoint);
      /*ScaffoldMessa("Please add approxiamte geopoint");*/
      return false;
    } else if(MyDuration.inMinutes==0){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_duration);
      // ScaffoldMessa("Please fill \"Duration\"");
      return false;
    } else if(pay_with_my_wallet&&MyWalletInstructionController.text.length==0&&!InfinityUsers){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_payment_instructions);
      // ScaffoldMessa("Please fill payment instructions");
      return false;
    } else if(AdditionalTextLength>0&&((EventNameController1.text.length==0||AboutController1.text.length==0))){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_additional_information);
      // ScaffoldMessa("Please fill additional information");
      return false;
    } else if(AdditionalTextLength>1&&((EventNameController2.text.length==0||AboutController2.text.length==0))){
      ScaffoldMessa(AppLocalizations.of(context)!.please_fill_additional_information);
      // ScaffoldMessa("Please fill additional information");
      return false;
    } else if(MaxPeoplesController.text.length==0&&!InfinityUsers){
      ScaffoldMessa(limited_unlimited_users ? AppLocalizations.of(context)!.please_fill_approximate_peoples_count : AppLocalizations.of(context)!.please_fill_max_peoples_count);
      // ScaffoldMessa(limited_unlimited_users ? "Please fill approximate peoples count" : "Please fill max peoples count");
      return false;
    } else if(!IsOnline){
      if(AdresController.text.length==0){
        ScaffoldMessa(AppLocalizations.of(context)!.please_fill_address);
        // ScaffoldMessa("Please fill adress");
        return false;
      } if(ShortAdresController.text.length==0){
        ScaffoldMessa(AppLocalizations.of(context)!.please_fill_short_address);
        // ScaffoldMessa("Please fill short adress");
        return false;
      } if(_markers.length==0){
        ScaffoldMessa(AppLocalizations.of(context)!.please_add_geo_point);
        // ScaffoldMessa("Please add geopoint");
        return false;
      } else {
        return true;
      }
    }

    setState(() {});
    return true;

  }

  void GetCategories() async{
    Categories=[];
    Categories.add(!RussianLanguage ? "All categories" : "Все категории");
    var CategoriesCollection = await firestore.collection("Categories").get();

    await Future.forEach(CategoriesCollection.docs, (doc) {
      TranslatedCategory[doc.data()["name"]]=doc.data()["name_rus"];
      Categories.add(doc.data()[RussianLanguage ? 'name_rus' : 'name']);
    });
    print("Categories 2 "+Categories.toString());

    setState(() { });
  }

  void GetLanguage() async{
    var model=hive_example();
    var lang = await model.GetLanguage();
    setState(() {
      RussianLanguage=lang=="ru";

      if(widget.is_new) CurrentLanguage=lang=="ru" ? "Все языки" : "All languages";
      else CurrentLanguage=(widget.data as Map).containsKey("primary_language") ? widget.data['primary_language'] : (lang=="ru" ? "Все языки" : "All languages");

      // CurrentLanguage=lang=="ru" ? "Все языки" : "All languages";
      CurrentCategory=lang=="ru" ? "Все категории" : "Current category";
      Languages=[lang=="ru" ? "Все языки" : "All languages", "American English","English","Русский","Українська","Қазақ","հայերեն"];

    });

    GetCategories();
  }


  @override
  void initState() {


    //
    print("Categories "+Categories.toString());
    print("Current Categories "+CurrentCategory.toString());

    GetLanguage();
    GetEvents();
    if(!widget.is_new){
      LoadEditInfo();
    }

    // TODO: implement initState
    super.initState();

    if((!widget.is_new)||widget.is_dublicate) Future.delayed(Duration(seconds: 1)).then((value) {
      if((widget.data as Map).containsKey("my_video_link")){
        if(widget.data['my_video_link']!="") InitVideo(false);
      };
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro(!widget.is_new&&!widget.is_dublicate ? AppLocalizations.of(context)!.update_event : AppLocalizations.of(context)!.add_event),
      // appBar: AppBarPro("Add event"),
      body: Stack(
        children: [
          InkWell(
            onTap: () => UnfocusNodes(),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12,),
                    CitiesDropDown(context),
                    if(Categories.length>1) SizedBox(height: 12,),
                    if(Categories.length>1) CategoriesDropDown(context),
                    SizedBox(height: 12,),
                    LanguagesDropDown(context),
                    SizedBox(height: 16,),
                    Container(
                      width: double.infinity,
                      child: CupertinoSlidingSegmentedControl<int>(
                        backgroundColor: Color.fromRGBO(239, 239, 255, 1),
                        thumbColor: Color.fromRGBO(196, 196, 241, 1),
                        padding: EdgeInsets.all(2),
                        groupValue: GenderValue,
                        children: {
                          0: buildSegment(AppLocalizations.of(context)!.all, GenderValue, 0),
                          // 0: buildSegment("All", GenderValue, 0),
                          1: buildSegment(AppLocalizations.of(context)!.male, GenderValue, 1),
                          // 1: buildSegment("Male", GenderValue, 1),
                          2: buildSegment(AppLocalizations.of(context)!.female, GenderValue, 2),
                          // 2: buildSegment("Female", GenderValue, 2),
                        },
                        onValueChanged: (value){
                          setState(() {
                            GenderValue = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 24,),
                    Text(AppLocalizations.of(context)!.promo_photo,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                    // Text("Promo photo",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                    AddPhotoImage(context),
                    SizedBox(height: 24,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.promo_video,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700)),
                        InkWell(
                          onTap: (){
                            if(video_load){
                              File(video!.path).delete();
                              my_video_link="";
                              video_load=false;
                              video_size_index=0.0;
                              setState(() { });
                              video_controller.dispose();
                            } else if(!widget.is_new){
                              print("где то");
                              if((widget.data as Map).containsKey("my_video_link")) {
                                  if(widget.data['my_video_link']!=""){
                                    print("тут");
                                    // widget.data['my_video_link'] = "";
                                    my_video_link = "";
                                    video_load=false;
                                    video_size_index=0.0;
                                    setState(() { });
                                    video_controller.dispose();

                                  }
                                }
                              }
                          },
                          child: Text(AppLocalizations.of(context)!.delete,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.red),)
                        ),
                      ],
                    ),
                    AddPromoVideo(context),
                    SizedBox(height: 16,),

                    AdittionalImageToggle(context),
                    if(additional_iamges) AdditionalImageList(),

                    SizedBox(height: 16,),
                    RussianLanguageToggle(),
                    SizedBox(height: 16,),

                    SocialMediaToggle(),
                    if(social_media_exist) SocialMediaFields()
                    else SizedBox(height: 16),

                    if(!free_admission) PaymentToggle(),
                    if(pay_with_my_wallet&&!free_admission) MyWalletFields()
                    else SizedBox(height: 16),

                    LimitedUsersToggle(),
                    SizedBox(height: 16,),
                    FreeAdmissionToggle(),
                    SizedBox(height: 16,),
                    KidsFrendlyToggle(),
                    SizedBox(height: 16,),
                    InfinityUsersToggle(),
                    SizedBox(height: 16,),
                    if(CurrentLanguage!="All languages") ShowFlagToggle(CurrentLanguage),
                    if(!free_admission) FormProCustomLength(PriceController,PriceNode,AppLocalizations.of(context)!.price,16,false,"\$",7),
                    // if(!free_admission) FormPro(PriceController,PriceNode,"Price",16,false,"\$"),
                    FormProCustomLength(EventNameController,EventNameNode,AppLocalizations.of(context)!.event_name,16,true,"",60),
                    // FormPro(EventNameController,EventNameNode,"Event name",16,true,""),
                    if(russian_text) FormProCustomLength(RussianEventNameController,RussianEventNameNode,AppLocalizations.of(context)!.event_name_rus,16,true,"",60),
                    // if(russian_text) FormPro(RussianEventNameController,RussianEventNameNode,"Event name (rus)",16,true,""),
                    FormProCustomLength(AboutController,AboutNode,AppLocalizations.of(context)!.about,16,true,"",1000),
                    // FormPro(AboutController,AboutNode,"About",16,true,""),
                    if(russian_text) FormProCustomLength(RussianAboutController,RussianAboutNode,AppLocalizations.of(context)!.about_rus,16,true,"",1000),
                    // if(russian_text) FormPro(RussianAboutController,RussianAboutNode,"About (rus)",16,true,""),
                    FormProCustomLength(MaxPeoplesController,MaxPeoplesNode,limited_unlimited_users ? AppLocalizations.of(context)!.approximate_peoples : AppLocalizations.of(context)!.max_peoples,16,false,"",7),
                    // FormPro(MaxPeoplesController,MaxPeoplesNode,limited_unlimited_users ? "Approximate peoples" : "Max peoples",16,false,""),
                    ChoiceDurationForm(),

                    SizedBox(height: 16,),

                    ChoiceDateForm(),

                    SizedBox(height: 24,),

                    InviteOrganizers(context),

                    if(OtherOrganizers.length!=0) SizedBox(height: 12,),

                    OrganizersList(),

                    Divider(height: 32,color: Colors.black26,),

                    AdittionalTextWidget(context),

                    Divider(height: 32,color: Colors.black26,),

                    PromoCodePlusButton(text: "Промокод",count: PromoCodeLength,onMinus: (){
                      setState(() {
                        PromoCodeLength=max(PromoCodeLength-1,0);
                      });
                    },onPlus: (){setState(() {
                      PromoCodeLength=min(PromoCodeLength+1,7);
                      print(PromoCodeLength.toString());
                    });}),
                    SizedBox(height: 12,),
                    if(PromoCodeLength>=1) ...[
                      FormProCustomLength(PromoCodeController,PromoCodeNode,AppLocalizations.of(context)!.promo_name,16,true,"",10),
                      Center(child: Text("Скидка: ${PromoCodeValue.round()}%",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),)),
                      Slider(value: PromoCodeValue,min: 1,max: 99, onChanged: (value){setState(() {PromoCodeValue=value;});}), SizedBox(height: 12,),
                    ],
                    if(PromoCodeLength>=2) ...[
                      FormProCustomLength(PromoCode2Controller,PromoCodeNode2,AppLocalizations.of(context)!.promo_name,16,true,"",10),
                      Center(child: Text("Скидка: ${PromoCodeValue2.round()}%",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),)),
                      Slider(value: PromoCodeValue2,min: 1,max: 99, onChanged: (value){setState(() {PromoCodeValue2=value;});}), SizedBox(height: 12,),
                    ],
                    if(PromoCodeLength>=3) ...[
                      FormProCustomLength(PromoCode3Controller,PromoCodeNode3,AppLocalizations.of(context)!.promo_name,16,true,"",10),
                      Center(child: Text("Скидка: ${PromoCodeValue3.round()}%",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),)),
                      Slider(value: PromoCodeValue3,min: 1,max: 99, onChanged: (value){setState(() {PromoCodeValue3=value;});}), SizedBox(height: 12,),
                    ],
                    if(PromoCodeLength>=4) ...[
                      FormProCustomLength(PromoCode4Controller,PromoCodeNode4,AppLocalizations.of(context)!.promo_name,16,true,"",10),
                      Center(child: Text("Скидка: ${PromoCodeValue4.round()}%",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),)),
                      Slider(value: PromoCodeValue4,min: 1,max: 99, onChanged: (value){setState(() {PromoCodeValue4=value;});}), SizedBox(height: 12,),
                    ],
                    if(PromoCodeLength>=5) ...[
                      FormProCustomLength(PromoCode5Controller,PromoCodeNode5,AppLocalizations.of(context)!.promo_name,16,true,"",10),
                      Center(child: Text("Скидка: ${PromoCodeValue5.round()}%",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),)),
                      Slider(value: PromoCodeValue5,min: 1,max: 99, onChanged: (value){setState(() {PromoCodeValue5=value;});}), SizedBox(height: 12,),
                    ],
                    if(PromoCodeLength>=6) ...[
                      FormProCustomLength(PromoCode6Controller,PromoCodeNode6,AppLocalizations.of(context)!.promo_name,16,true,"",10),
                      Center(child: Text("Скидка: ${PromoCodeValue6.round()}%",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),)),
                      Slider(value: PromoCodeValue6,min: 1,max: 99, onChanged: (value){setState(() {PromoCodeValue6=value;});}), SizedBox(height: 12,),
                    ],
                    if(PromoCodeLength>=7) ...[
                      FormProCustomLength(PromoCode7Controller,PromoCodeNode7,AppLocalizations.of(context)!.promo_name,16,true,"",10),
                      Center(child: Text("Скидка: ${PromoCodeValue7.round()}%",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700),)),
                      Slider(value: PromoCodeValue7,min: 1,max: 99, onChanged: (value){setState(() {PromoCodeValue7=value;});}), SizedBox(height: 12,),
                    ],
                    Divider(height: 32,color: Colors.black26,),

                    OnlineToggle(),
                    if(!IsOnline) AdresForm(context),

                    SizedBox(height: 24,),

                    ButtonPro(!widget.is_new&&!widget.is_dublicate ?
                    AppLocalizations.of(context)!.update_event:
                    AppLocalizations.of(context)!.add_event
                    // "Add event"

                    ,
                    // "Update event",
                    () async{
                      if(widget.is_new){
                        if(CanAddEvent()){
                          AddEvent();

                        }
                      } else if(CanUpdateEvent()&&!widget.is_new){
                        if(widget.is_dublicate) DublicateEvent();
                        else UpdateEvent();

                        // Navigator.of(context).push(CustomPageRoute(page));
                      }
                    },WaitForNextStep),

                    SizedBox(height: 24,),
                  ],
                ),
              ),
            ),
          ),
          if(BackDrop) BackDropWidget(context),
          if(ShowPicker) DurationPicker(),
          if(ShowCallendar) CalendarPicker(context),
        ],
      ),
      // bottomNavigationBar: BottomNavBarPro(context, 2),
    );
  }

  Column AdittionalTextWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdditionalTextPlusButton(
            AppLocalizations.of(context)!.additional_text,
            // "Additional text",
                (){
              setState(() {AdditionalTextLength=(AdditionalTextLength+1)>1 ? 2 : 1;});

            },AdditionalTextLength,(){setState(() {AdditionalTextLength=max(0, AdditionalTextLength-1);});}),

        if(AdditionalTextLength>0)...[
          SizedBox(height: 16,),
          FormProCustomLength(EventNameController1,EventNameNode1,AppLocalizations.of(context)!.additional_header,16,true,"",60),
          // FormPro(EventNameController1,EventNameNode1,"Additional header",16,true,""),
          if(russian_text) FormProCustomLength(RussianEventNameController1,RussianEventNameNode1,AppLocalizations.of(context)!.additional_header_rus,16,true,"",60),
          // if(russian_text) FormPro(RussianEventNameController1,RussianEventNameNode1,"Additional header (rus)",16,true,""),
          FormProCustomLength(AboutController1,AboutNode1,AppLocalizations.of(context)!.additional_text,8,true,"",1000),
          // FormPro(AboutController1,AboutNode1,"Additional text",8,true,""),
          if(russian_text) FormProCustomLength(RussianAboutController1,RussianAboutNode1,AppLocalizations.of(context)!.additional_text_rus,8,true,"",1000),
          // if(russian_text) FormPro(RussianAboutController1,RussianAboutNode1,"Additional text (rus)",8,true,""),
        ],

        if(AdditionalTextLength==2)...[
          SizedBox(height: 16,),
          FormProCustomLength(EventNameController2,EventNameNode2,AppLocalizations.of(context)!.other_additional_header,16,true,"",60),
          // FormPro(EventNameController2,EventNameNode2,"Other additional header",16,true,""),
          if(russian_text) FormProCustomLength(RussianEventNameController2,RussianEventNameNode2,AppLocalizations.of(context)!.other_additional_header_rus,16,true,"",60),
          // if(russian_text) FormPro(RussianEventNameController2,RussianEventNameNode2,"Other additional header (rus)",16,true,""),
          FormProCustomLength(AboutController2,AboutNode2,AppLocalizations.of(context)!.other_additional_text,16,true,"",1000),
          // FormPro(AboutController2,AboutNode2,"Other additional text",16,true,""),
          if(russian_text) FormProCustomLength(RussianAboutController2,RussianAboutNode2,AppLocalizations.of(context)!.other_additional_text_rus,16,true,"",1000),
          // if(russian_text) FormPro(RussianAboutController2,RussianAboutNode2,"Other additional text (rus)",16,true,""),
        ],
      ],
    );
  }

  InkWell BackDropWidget(BuildContext context) {
    return InkWell(
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
    );
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
            AppLocalizations.of(context)!.choice_category,
            // 'Choice category',
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

  Widget CitiesDropDown(BuildContext context) {
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
            AppLocalizations.of(context)!.choice_category,
            // 'Choice category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: Cities.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          )).toList(),
          value: CurrentCity,
          onChanged: (value) {
            setState(() {
              CurrentCity = value!;
            });
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

  Widget LanguagesDropDown(BuildContext context) {
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
            AppLocalizations.of(context)!.choice_primary_language,
            // 'Choice primary language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: Languages.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          )).toList(),
          value: CurrentLanguage,
          onChanged: (value) {
            setState(() {
              CurrentLanguage = value!;
            });
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


  Align CalendarPicker(BuildContext context) {
    return Align(
      child: Container(
        width: 300,
        height: 520,
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
            CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: MyDurationDate,
                onTimerDurationChanged: (value){
                  MyDurationDate=value;
                }
            ),
            SizedBox(height: 12,),
            InkWell(
              onTap: (){
                DateTime newDate = dates_var;
                DateTime formatedDate = newDate.subtract(Duration(hours: newDate.hour, minutes: newDate.minute, seconds: newDate.second, milliseconds: newDate.millisecond, microseconds: newDate.microsecond));
                if(DatesTimeLength==5){
                  _dates = [(formatedDate as DateTime?)?.add(MyDurationDate)];
                } else {
                  _dates = [(formatedDate as DateTime?)?.add(MyDurationDate)];
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
                  child: Text(AppLocalizations.of(context)!.accept,style: TextStyle(fontFamily: "SFPro",fontSize: 16,fontWeight: FontWeight.w700,),)
                  // child: Text("Выбрать",style: TextStyle(fontFamily: "SFPro",fontSize: 16,fontWeight: FontWeight.w700,),)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Center DurationPicker() {
    return Center(
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
            Text(AppLocalizations.of(context)!.choice_duration,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700,),),
            // Text("Choice duration",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700,),),
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
              child: ButtonPro(
                  AppLocalizations.of(context)!.choice,
                  // "Choice",
                      (){
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
    );
  }

  Column AdditionalImageList() {
    return Column(
      children: [
        if(AdditionalTextLength>2) ...[
          Text(AppLocalizations.of(context)!.slide_to_the_right_to_see_all_images,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54),),
          // Text("Slide to the right to see all images",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black54),),
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
    );
  }

  Row AdittionalImageToggle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.additional_images,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        // Text("Additional images",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: additional_iamges,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              setState(() {
                if(widget.is_new){
                  additional_iamges=!additional_iamges;
                } else {
                  additional_iamges=!additional_iamges;
                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //   content: Text("Я пока не сделал чтобы можно было редактировать эти фотки)"),
                  //   duration: Duration(seconds: 3),
                  //   backgroundColor: Colors.red,
                  // ));
                }
              });
            }
        ),
      ],
    );
  }


  Column AdresForm(BuildContext context) {

    return Column(
      children: [
        Divider(height: 32,color: Colors.black26,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if(InDoor) ...[
                  Text(AppLocalizations.of(context)!.indoor,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                  // Text("InDoor",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                  Text(" | ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                  Text(AppLocalizations.of(context)!.outdoor,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                  // Text("Outdoor",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                ] else ...[
                  Text(AppLocalizations.of(context)!.indoor,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black),),
                  // Text("InDoor",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black),),
                  Text(" | ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
                  Text(AppLocalizations.of(context)!.outdoor,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black),),
                  // Text("Outdoor",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black),),
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
        Divider(height: 32,color: Colors.black26,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.hide_exact_address,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black),),
            // Text("Hide exact address\nfor unregistered users",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black),),
            CupertinoSwitch(
                value: HideExactAdress,
                activeColor: PrimaryCol,
                onChanged: (value) async{
                  setState(() {
                    HideExactAdress=!HideExactAdress;
                  });
                }
            ),
          ],
        ),
        SizedBox(height: 24,),
        Container(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            backgroundColor:  CupertinoColors.systemGrey5,
            thumbColor: CupertinoColors.white,

            groupValue: MapTypeUser,
            children: {
              0: buildSegmentTwo(AppLocalizations.of(context)!.exact),
              // 0: buildSegmentTwo("Exact"),
              1: buildSegmentTwo(AppLocalizations.of(context)!.approximate),
              // 1: buildSegmentTwo("Approximate"),
            },
            onValueChanged: (value){
              setState(() {
                MapTypeUser = value!;
              });

            },
          ),
        ),
        SizedBox(height: 12),
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

                if(MapTypeUser==1) {
                  _circles.clear();
                  _circles.add(
                    Circle(
                        circleId: CircleId("id"),
                        center: LatLngg,
                        radius: 300,
                        fillColor: Colors.black12,
                        strokeWidth: 2,
                        strokeColor: Colors.blueAccent
                    ),
                  );
                } else {
                  _markers.clear();
                  _markers.add(Marker(
                    markerId: MarkerId("place.id"),
                    position: LatLngg,
                    infoWindow: InfoWindow(
                      title: EventNameController.text,
                    ),
                    icon: BitmapDescriptor.defaultMarker,
                  ));
                }

                setState(() { });
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              // polygons: _polygon,
              markers: Set<Marker>.of(_markers as Iterable<Marker>),
              circles: Set<Circle>.of(_circles as Iterable<Circle>),
              // polygons: myPolygon(),
            ),
          ),
        ),
        SizedBox(height: 24,),
        FormProCustomLength(AdresController,AdresNode,AppLocalizations.of(context)!.address,16,true,"",500),
        // FormPro(AdresController,AdresNode,"Address",16,true,""),
        if(russian_text) FormProCustomLength(RussianAdresController,RussianAdresNode,AppLocalizations.of(context)!.address_rus,16,true,"",500),
        // if(russian_text) FormPro(RussianAdresController,RussianAdresNode,"Address (rus)",16,true,""),
        FormProCustomLength(ShortAdresController,ShortAdresNode,AppLocalizations.of(context)!.short_address,16,true,"",500),
        // FormPro(ShortAdresController,ShortAdresNode,"Short address",16,true,""),
        if(russian_text) FormProCustomLength(RussianShortAdresController,RussianShortAdresNode,AppLocalizations.of(context)!.short_address_rus,16,true,"",500),
        // if(russian_text) FormPro(RussianShortAdresController,RussianShortAdresNode,"Short address (rus)",16,true,""),
        FormProCustomLength(LocationInfoController,LocationInfoNode,AppLocalizations.of(context)!.location_info,16,true,"",500),
        // FormPro(LocationInfoController,LocationInfoNode,"Location info",16,true,""),
        if(russian_text) FormProCustomLength(RussianLocationInfoController,RussianLocationInfoNode,AppLocalizations.of(context)!.location_info_rus,16,true,"",500),
        // if(russian_text) FormPro(RussianLocationInfoController,RussianLocationInfoNode,"Location info (rus)",16,true,""),
        FormProCustomLength(ParkingInfoController,ParkingInfoNode,AppLocalizations.of(context)!.parking_info,russian_text ? 16 : 0 ,true,"",500),
        // FormPro(ParkingInfoController,ParkingInfoNode,"Parking info",russian_text ? 16 : 0 ,true,""),
        if(russian_text) FormProCustomLength(RussianParkingInfoController,RussianParkingInfoNode,AppLocalizations.of(context)!.parking_info_rus,0,true,"",500),
        // if(russian_text) FormPro(RussianParkingInfoController,RussianParkingInfoNode,"Parking info (rus)",0,true,""),
      ],
    );
  }

  Row OnlineToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if(IsOnline) ...[
              Text(AppLocalizations.of(context)!.online,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
              // Text("Online",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
              Text(" | ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
              Text(AppLocalizations.of(context)!.offline,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
              // Text("offline",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
            ] else ...[
              Text(AppLocalizations.of(context)!.online,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black),),
              // Text("Online",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black),),
              Text(" | ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.grey),),
              Text(AppLocalizations.of(context)!.offline,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black),),
              // Text("offline",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black),),

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
    );
  }

  ListView OrganizersList() {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount: OtherOrganizers.length,
      itemBuilder: (context,index) {
        return AddOrganizerCard(context,OtherOrganizers[index]["name"],
            "Organizer",
            OtherOrganizers[index]["photo"],(){
          setState(() {
            OtherOrganizers.removeAt(index);
          });},"Close");
      },
      separatorBuilder: (context,index) { return Divider(height: 32,color: Colors.black45,);},
    );
  }

  Widget InviteOrganizers(BuildContext context) {
    return TextPlusButton(AppLocalizations.of(context)!.invite_organizers,(){
    // return TextPlusButton("Invite organizers",(){

      final page = OtherOrganizersPage();
      Navigator.of(context).push(CustomPageRoute(page)).then((value) {
        if(value!=null) {setState(() {OtherOrganizers.where((element) => element['phone']==value['phone']).length==0 ? OtherOrganizers.add(value) : null; });
        }});
    });
  }

  InkWell AddPhotoImage(BuildContext context) {
    return InkWell(
      onTap: () async{

        if(image_load&&image!=null){

          File(image!.path).delete();
          image = await _picker.pickImage(source: ImageSource.gallery);
          setState(() { image_load=true; });

        } else {

          try {
            image = await _picker.pickImage(source: ImageSource.gallery);
            image_load=true;
            setState(() {

            });
          } on PlatformException catch  (e) {
            await PermissionGallery(context);
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: 16),
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
    );
  }

  InkWell AddPromoVideo(BuildContext context) {
    return InkWell(
      onTap: () async{

        if(video_load){

          print("1");
          File(video!.path).delete();
          video = await _picker.pickVideo(source: ImageSource.gallery);

          if(video!=null){
            video_controller.dispose();
            print("11");

            // video_controller.dispose();
            InitVideo(true);
          }

        } else {

          try {
            video = await _picker.pickVideo(source: ImageSource.gallery);
            if(video!=null){
            if(!widget.is_new) {
                if((widget.data as Map).containsKey("my_video_link")){
                  if(widget.data['my_video_link']!="") video_controller.dispose();
                  print("dispose");
                }
              }


              InitVideo(true);
            }


          } on PlatformException catch  (e) {await PermissionGallery(context);}
        }
      },
      child: (!widget.is_new||widget.is_dublicate)
          &&(widget.data as Map).containsKey("my_video_link")
          &&video_initialized&&!video_load ? VideoFromData(context) : VideoAsset(context),
    );
  }

  Container VideoAsset(BuildContext context) {
    print("show VideoAsset");

    return Container(
      height: video_size_index==0.0 ? 130.0 : (is_video_horizontal ? video_size_index*(MediaQuery.of(context).size.width-32) : 400.0+16),
      width: double.infinity,
      decoration: BoxDecoration(color: PrimaryCol, borderRadius: BorderRadius.circular(12),),
      margin: EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          margin: !is_video_horizontal ? EdgeInsets.symmetric(vertical: 16) : null,
          height: video_size_index==0.0 ? 130.0 : (is_video_horizontal ? video_size_index*(MediaQuery.of(context).size.width-32) : 400.0),
          width: video_size_index==0.0 ? double.infinity : (is_video_horizontal ? double.infinity : 200.0),
          decoration: (video_load)?
          null :
          BoxDecoration(color: PrimaryCol, borderRadius: BorderRadius.circular(12),),
          child: !(video_load) ?  Center(
            child: SvgPicture.asset("lib/assets/Icons/Bold/Video.svg",color: Colors.white,),
          ) : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: VideoPlayer(video_controller,)
          ),
        ),
      ),
    );
  }

  Container VideoFromData(BuildContext context) {
    print("show DataAsset");

    return Container(
      height: video_size_index==0.0 ? 130.0 : (is_video_horizontal ? video_size_index*(MediaQuery.of(context).size.width-32) : 400.0+16),
      width: double.infinity,
      decoration: BoxDecoration(color: PrimaryCol, borderRadius: BorderRadius.circular(12),),
      margin: EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          margin: !is_video_horizontal ? EdgeInsets.symmetric(vertical: 16) : null,
          height: video_size_index==0.0 ? 130.0 : (is_video_horizontal ? video_size_index*(MediaQuery.of(context).size.width-32) : 400.0),
          width: video_size_index==0.0 ? double.infinity : (is_video_horizontal ? double.infinity : 200.0),
          decoration: BoxDecoration(color: PrimaryCol, borderRadius: BorderRadius.circular(12),),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
            child: !widget.data.containsKey("my_video_link") ?  Center(
              child: SvgPicture.asset("lib/assets/Icons/Bold/Video.svg",color: Colors.white,),
            ) : (widget.data["my_video_link"]!=""&&my_video_link!=""&&(!WaitForNextStep) ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: VideoPlayer(video_controller,)
            ) : Center(
              child: SvgPicture.asset("lib/assets/Icons/Bold/Video.svg",color: Colors.white,),
            )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if(widget.is_new){
      if(video_load) video_controller.dispose();
    } else {
      if((widget.data as Map).containsKey("my_video_link")||video_load) {
        if((widget.data as Map).containsKey("my_video_link")){
          if(widget.data['my_video_link']!="") video_controller.dispose();
        } else {
          video_controller.dispose();
        }
      }
    }

    // video_controller.hasListeners ? video_controller.dispose() : null;
    // TODO: implement dispose
    super.dispose();
  }

  void LoadVideo(video_file) {
    // video_controller.dispose();
    video_controller = VideoPlayerController.file(File((video_file as XFile).path))
      ..initialize().then((_) {
        video_controller.play();
        video_controller.setLooping(true);
        setState(() { video_load=true; });
        // Ensure the first frame is shown after the video is initialized
      });
  }

  void InitVideo(is_file){
    print("init_video");

    if(is_file){
      video_controller = VideoPlayerController.file(File((video as XFile).path))
        ..initialize().then((_) {
          video_controller.play();
          video_controller.setLooping(true);
          InitVideoSettings(true);
          // Ensure the first frame is shown after the video is initialized

        });
    } else {
      print("Here");
      video_controller = VideoPlayerController.networkUrl(Uri.parse(widget.data['my_video_link']))
        ..initialize().then((_) {
          video_controller.play();
          video_controller.setLooping(true);
          InitVideoSettings(false);
          setState(() {
            video_initialized=true;
          });

        });
    }

  }

  void InitVideoSettings(video_load_bool) {
    setState(() { video_load=video_load_bool; });
    var video_height=video_controller.value.size.height;
    var video_width=video_controller.value.size.width;
    print("Size "+video_controller.value.size.width.toString());
    print("Size "+video_controller.value.size.height.toString());
    if(video_height>video_width){
      print("First sz "+(video_height/video_width).toString());

      setState(() {
        video_size_index=video_width/video_height;
        is_video_horizontal=false;
      });
    } else {
      print("Second sz "+(video_width/video_height).toString());
      setState(() {
        video_size_index=video_height/video_width;
        is_video_horizontal=true;
      });
    }
  }

  Future<void> PermissionGallery(BuildContext context) async {
    print("Erroe");
    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.access_to_your_photos),
        // title: Text("Access to your photos"),
        content: Text(AppLocalizations.of(context)!.unfortunately_you_have_blocked),
        // content: Text("Unfortunately, you have blocked the application from accessing photos. A photo is not required for the application to work, but if you change your mind, you need to go to settings and add it"),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.stay),
            // child: Text("Stay"),

            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context)!.add),
            // child: Text("Add"),
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

  Stack ChoiceDateForm() {
    // DateTime DateTimeNow=dateTimeToZone(zone: CurrentCity=="Los Angeles" ? "PST" : "EST", datetime: DateTime.now());
    DateTime DateTimeNow=DateTime.now();

    return Stack(
      children: [
        FakeFormPro(
            _dates.length!=0 ?
          ((_dates.first as DateTime).day<10 ? "0"+(_dates.first as DateTime).day.toString() : (_dates.first as DateTime).day.toString() )+" "+
              DateFormat.MMMM().format(_dates.first as DateTime).toString()+" "+
              (_dates.first as DateTime).year.toString()+", "+
              DateFormat('HH:mm').format(_dates.first as DateTime).toString() :

            ((DateTimeNow).day<10 ? "0"+(DateTimeNow).day.toString() : (DateTimeNow).day.toString() )+" "+
                DateFormat.MMMM().format(DateTimeNow).toString()+" "+
                (DateTimeNow).year.toString()+", "+
                DateFormat('HH:mm').format(DateTimeNow).toString()
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
    );
  }

  Stack ChoiceDurationForm() {
    return Stack(
      children: [
        FakeFormPro(AppLocalizations.of(context)!.duration+" "+(MyDuration as Duration).inMinutes.toString()+" "+AppLocalizations.of(context)!.min),
        // FakeFormPro("Duration "+(MyDuration as Duration).inMinutes.toString()+" min."),
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
    );
  }

  void UnfocusNodes() {
    EventNameNode.hasFocus ? EventNameNode.unfocus() : null;
    EventNameNode1.hasFocus ? EventNameNode1.unfocus() : null;
    EventNameNode2.hasFocus ? EventNameNode2.unfocus() : null;
    RussianEventNameNode.hasFocus ? RussianEventNameNode.unfocus() : null;
    RussianEventNameNode1.hasFocus ? RussianEventNameNode1.unfocus() : null;
    RussianEventNameNode2.hasFocus ? RussianEventNameNode2.unfocus() : null;

    PrimaryLanguageNode.hasFocus ? PrimaryLanguageNode.unfocus() : null;
    AboutNode.hasFocus ? AboutNode.unfocus() : null;
    AboutNode1.hasFocus ? AboutNode1.unfocus() : null;
    AboutNode2.hasFocus ? AboutNode2.unfocus() : null;
    RussianAboutNode.hasFocus ? RussianAboutNode.unfocus() : null;
    RussianAboutNode1.hasFocus ? RussianAboutNode1.unfocus() : null;
    RussianAboutNode2.hasFocus ? RussianAboutNode2.unfocus() : null;


    PriceNode.hasFocus ? PriceNode.unfocus() : null;
    MyWalletInstructionNode.hasFocus ? MyWalletInstructionNode.unfocus() : null;
    RussianMyWalletInstructionNode.hasFocus ? RussianMyWalletInstructionNode.unfocus() : null;
    MyWalletNode.hasFocus ? MyWalletInstructionNode.unfocus() : null;
    MyWalletLinkNode.hasFocus ? MyWalletInstructionNode.unfocus() : null;

    InstagramNode.hasFocus ? InstagramNode.unfocus() : null;
    FacebookNode.hasFocus ? FacebookNode.unfocus() : null;
    TelegramNode.hasFocus ? TelegramNode.unfocus() : null;

    MaxPeoplesNode.hasFocus ? MaxPeoplesNode.unfocus() : null;
    PromoCodeNode.hasFocus ? PromoCodeNode.unfocus() : null;
    PromoCodeNode2.hasFocus ? PromoCodeNode2.unfocus() : null;
    PromoCodeNode3.hasFocus ? PromoCodeNode3.unfocus() : null;
    PromoCodeNode4.hasFocus ? PromoCodeNode4.unfocus() : null;
    PromoCodeNode5.hasFocus ? PromoCodeNode5.unfocus() : null;
    PromoCodeNode6.hasFocus ? PromoCodeNode6.unfocus() : null;
    PromoCodeNode7.hasFocus ? PromoCodeNode7.unfocus() : null;

    RussianAdresNode.hasFocus ? RussianAdresNode.unfocus() : null;
    RussianShortAdresNode.hasFocus ? RussianShortAdresNode.unfocus() : null;
    RussianLocationInfoNode.hasFocus ? RussianLocationInfoNode.unfocus() : null;
    RussianParkingInfoNode.hasFocus ? RussianParkingInfoNode.unfocus() : null;

    ParkingInfoNode.hasFocus ? ParkingInfoNode.unfocus() : null;
    ParkingInfoNode.hasFocus ? ParkingInfoNode.unfocus() : null;
    ParkingInfoNode.hasFocus ? ParkingInfoNode.unfocus() : null;
    ParkingInfoNode.hasFocus ? ParkingInfoNode.unfocus() : null;
  }

  Widget MyWalletFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4,),
        Text(AppLocalizations.of(context)!.cannot_be_edited_after_an,style: TextStyle(fontSize: 13,color: Colors.red,fontWeight: FontWeight.w500,height: 1.5),),
        // Text("Cannot be edited after an event has been published",style: TextStyle(fontSize: 13,color: Colors.red,fontWeight: FontWeight.w500,height: 1.5),),
        SizedBox(height: 4,),
        Text(AppLocalizations.of(context)!.after_users_transfer_funds_to_you,style: TextStyle(fontSize: 13,color: Colors.grey,fontWeight: FontWeight.w500,height: 1.5),),
        // Text("After users transfer funds to you, you will need to add them to the event list in the users section of your event",style: TextStyle(fontSize: 13,color: Colors.grey,fontWeight: FontWeight.w500,height: 1.5),),
        SizedBox(height: 16,),
        FormProCustomLength(MyWalletInstructionController,MyWalletInstructionNode,AppLocalizations.of(context)!.pay_instructions,16,true,"",500),
        // FormPro(MyWalletInstructionController,MyWalletInstructionNode,"Pay instructions",16,true,""),
        if(russian_text) FormProCustomLength(RussianMyWalletInstructionController,RussianMyWalletInstructionNode,AppLocalizations.of(context)!.pay_instructions_rus,16,true,"",500),
        // if(russian_text) FormPro(RussianMyWalletInstructionController,RussianMyWalletInstructionNode,"Pay instructions (rus)",16,true,""),
        FormProCustomLength(MyWalletController,MyWalletNode,AppLocalizations.of(context)!.my_wallet_optional,16,true,"",100),
        // FormPro(MyWalletController,MyWalletNode,"My wallet (optional)",16,true,""),
        FormPro(MyWalletLinkController,MyWalletLinkNode,AppLocalizations.of(context)!.pay_link_optional,16,true,""),
        // FormPro(MyWalletLinkController,MyWalletLinkNode,"Pay link (optional)",16,true,""),
      ],
    );
  }

  Widget SocialMediaFields() {
    return Column(
      children: [
        SizedBox(height: 16,),
        FormPro(InstagramController,InstagramNode,AppLocalizations.of(context)!.instagram_link,16,true,""),
        // FormPro(InstagramController,InstagramNode,"Instagram link",16,true,""),
        FormPro(FacebookController,FacebookNode,AppLocalizations.of(context)!.facebook_link,16,true,""),
        // FormPro(FacebookController,FacebookNode,"Facebook link",16,true,""),
        FormPro(TelegramController,TelegramNode,AppLocalizations.of(context)!.telegram_link,16,true,""),
        // FormPro(TelegramController,TelegramNode,"Telegram link",16,true,""),
      ],
    );
  }

  Row PaymentToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.payments_on_my_own_wallet,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        // Text("Payments on my own wallet",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: pay_with_my_wallet,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              if(widget.is_new) {
                setState(() {
                  pay_with_my_wallet=!pay_with_my_wallet;
                });
              }
            }
        ),
      ],
    );
  }

  Row LimitedUsersToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.unlimited_users_count,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        // Text("Unlimited users count",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: limited_unlimited_users,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              if(widget.is_new){
                setState(() {
                  limited_unlimited_users=!limited_unlimited_users;
                });
              }
            }
        ),
      ],
    );
  }

  Row FreeAdmissionToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.free_admission,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        // Text("Free admission",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: free_admission,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              if(widget.is_new){
                setState(() {
                  free_admission=!free_admission;
                });
              }

            }
        ),
      ],
    );
  }

  Row KidsFrendlyToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.kids_allowed,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        // Text("Free admission",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: kids_allowed,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              setState(() {
                kids_allowed=!kids_allowed;
              });

            }
        ),
      ],
    );
  }



  Row InfinityUsersToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.all_welcome_event,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: InfinityUsers,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              setState(() {
                InfinityUsers=!InfinityUsers;
              });

            }
        ),
      ],
    );
  }

  Container ShowFlagToggle(Lang) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context)!.show_flag,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
              // Text("Show flag",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(width: 1,color: Colors.grey),
                    image: DecorationImage(
                        image: Lang=="English" ? AssetImage("lib/assets/Flag/EngFlag.png")
                            :  Lang=="American English" ? AssetImage("lib/assets/Flag/UsFlag.png")
                            :  Lang=="Русский" ? AssetImage("lib/assets/Flag/RusFlag.png")
                            :  Lang=="Українська" ? AssetImage("lib/assets/Flag/UkrFlag.png")
                            :  Lang=="Қазақ" ? AssetImage("lib/assets/Flag/KazFlag.png")
                            :  Lang=="հայերեն" ? AssetImage("lib/assets/Flag/ArmFlag.png")
                            : AssetImage("lib/assets/Flag/EngFlag.png")
                    )
                ),
                width: 32,
                height: 20,
              ),
            ],
          ),
          CupertinoSwitch(
              value: show_flag,
              activeColor: PrimaryCol,
              onChanged: (value) async{
                setState(() {
                  show_flag=!show_flag;
                });
                // ScaffoldMessa("Please wait while your Event is being verified");

              }
          ),
        ],
      ),
    );
  }

  Row SocialMediaToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.social_media,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        // Text("Social media",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: social_media_exist,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              setState(() {
                social_media_exist=!social_media_exist;
              });
            }
        ),
      ],
    );
  }

  Row RussianLanguageToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.russian_translate,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        // Text("Russian translate",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        CupertinoSwitch(
            value: russian_text,
            activeColor: PrimaryCol,
            onChanged: (value) async{
              setState(() {
                russian_text=!russian_text;
              });
            }
        ),
      ],
    );
  }
}
