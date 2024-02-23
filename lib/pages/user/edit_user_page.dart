import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/sign_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_route.dart';
import '../../widgets/voice_mes/user_message.dart';


class EditUserPage extends StatefulWidget {
  final appbar;
  final nickname;
  final data;
  final is_admin;

  const EditUserPage({Key? key,required this.appbar,required this.nickname,required this.data,required this.is_admin}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}


class _EditUserPageState extends State<EditUserPage> {

  TextEditingController NickNameController=TextEditingController();
  TextEditingController FirstNameController=TextEditingController();
  TextEditingController LastNameController=TextEditingController();
  TextEditingController InstagramController=TextEditingController();
  TextEditingController PhoneController=TextEditingController();
  TextEditingController AboutController=TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FocusNode NickNameNode=FocusNode();
  FocusNode FirstNameNode=FocusNode();
  FocusNode LastNameNode=FocusNode();
  FocusNode InstagramNode=FocusNode();
  FocusNode PhoneNode=FocusNode();
  FocusNode AboutNode=FocusNode();

  bool RestrictChangeName=false;

  bool wait_bool=false;

  Future<bool> GetNicknames(name) async{
    setState(() {wait_bool=true;});

    bool result=false;
    var nicknamesCollection = await firestore.collection("Nicknames").get();

    await Future.forEach(nicknamesCollection.docs, (doc) {
      if(name.toString().toLowerCase()==doc.id.toString().toLowerCase()) result=true;
    });


    return result;
  }

  @override
  void initState() {
    NickNameController.text=widget.nickname;
    FirstNameController.text=widget.data['firstname'];
    LastNameController.text=widget.data['lastname'];
    InstagramController.text=widget.data['instagram'];
    AboutController.text=widget.data['about'];

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro(widget.appbar),
      body: InkWell(
        onTap: (){
          PhoneNode.hasFocus ? PhoneNode.unfocus() : null;
          NickNameNode.hasFocus ? NickNameNode.unfocus() : null;
          FirstNameNode.hasFocus ? FirstNameNode.unfocus() : null;
          LastNameNode.hasFocus ? LastNameNode.unfocus() : null;

          InstagramNode.hasFocus ? InstagramNode.unfocus() : null;
          AboutNode.hasFocus ? AboutNode.unfocus() : null;
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

                      LockFormProMinLength(FirstNameController,FirstNameNode,AppLocalizations.of(context)!.first_name,16,true,"",widget.is_admin),
                      // FormPro(FirstNameController,FirstNameNode,"First name",16,true,""),
                      LockFormProMinLength(LastNameController,LastNameNode,AppLocalizations.of(context)!.last_name,16,true,"",widget.is_admin),
                      // FormPro(LastNameController,LastNameNode,"Last name",16,true,""),
                      FormPro(InstagramController,InstagramNode,AppLocalizations.of(context)!.instagram,16,true,""),
                      // FormPro(InstagramController,InstagramNode,"Instagram",16,true,""),
                      FormPro(AboutController,AboutNode,AppLocalizations.of(context)!.about,24,true,""),
                      // FormPro(AboutController,AboutNode,"About",24,true,""),
                    ],
                  ),
                  ButtonPro(
                      AppLocalizations.of(context)!.save,
                      // "Save",
                          () async{
                    var nickname_exist=await GetNicknames(NickNameController.text);

                    if(nickname_exist) {
                      UserMessage("Nickname already exist", context);
                    } else {
                      await firestore.collection("Nicknames").doc(NickNameController.text).set({"active":true});
                      await firestore.collection("Nicknames").doc(widget.nickname).delete();


                      await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
                        "nickname": NickNameController.text.toString().trim(),
                        "firstname": FirstNameController.text.toString().trim(),
                        "lastname": LastNameController.text.toString().trim(),
                        "instagram": InstagramController.text.toString().trim(),
                        "about": AboutController.text,
                      });
                      setState(() {wait_bool=false;});
                      Navigator.pop(context);
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