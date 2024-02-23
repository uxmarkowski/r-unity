import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/voice_mes/user_message.dart';
import '../sign/welcome_page.dart';


class AddUserManualy extends StatefulWidget {
  final event_id;
  const AddUserManualy({Key? key,required this.event_id}) : super(key: key);

  @override
  State<AddUserManualy> createState() => _AddUserManualyState();
}

class _AddUserManualyState extends State<AddUserManualy> {
  bool image_load=false;
  bool wait_bool=false;

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  final ImagePicker _picker = ImagePicker();
  late XFile? image;

  TextEditingController NameController=TextEditingController();
  FocusNode NameNode=FocusNode();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("Add user"),
      body: InkWell(
        onTap: (){
          NameNode.hasFocus ? NameNode.unfocus() : null;
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  AddPhotoImage(context),
                  SizedBox(height: 16,),
                  FormProMinLength(NameController, NameNode, "Name",16, true, ""),
                ],
              ),
              Column(
                children: [
                  ButtonPro("Add user to event", () async{
                    if(!image_load||NameController.text.length==0||image==null){
                      UserMessage("Fill all fields",context,);
                    } else {
                      setState(() {wait_bool=true;});

                      var Avatar_Path="events_photo/event_"+DateTime.now().millisecondsSinceEpoch.toString()+".jpg";
                      final photoRef = storageRef.child(Avatar_Path); File file = File(image!.path);
                      await photoRef.putFile(file); var urrr=await photoRef.getDownloadURL();

                      var event_data=await firestore.collection("Events").doc(widget.event_id).get();
                      var user_id=DateTime.now().millisecondsSinceEpoch;

                      await firestore.collection("Events").doc(widget.event_id).collection("Users").doc(user_id.toString()).set({
                        "active":false,
                        "avatar_link":urrr,
                        "doc_id":user_id,
                        "nickname":NameController.text,
                      });
                      await firestore.collection("Events").doc(widget.event_id).update({"peoples":event_data.data()!['peoples']+1});
                      Navigator.pop(context);
                    }


                  }, wait_bool),
                  SizedBox(height: 24,),
                ],
              )
            ],
          ),
        ),
      ),
    );
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

        ),
        child: Center(
          child: SvgPicture.asset("lib/assets/Icons/Bold/Image.svg"),
        ),
      ),
    );
  }
}
