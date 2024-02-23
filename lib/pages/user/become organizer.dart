import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/widgets/voice_mes/user_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/app_bar.dart';



class BecomeOrganizer extends StatefulWidget {
  const BecomeOrganizer({Key? key}) : super(key: key);

  @override
  State<BecomeOrganizer> createState() => _BecomeOrganizerState();
}

class _BecomeOrganizerState extends State<BecomeOrganizer> {

  TextEditingController NameController=TextEditingController();
  TextEditingController EmailController=TextEditingController();
  TextEditingController DescribeController=TextEditingController();
  FocusNode NameNode=FocusNode();
  FocusNode EmailNode=FocusNode();
  FocusNode DescribeNode=FocusNode();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool wait_bool=false;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Become organizer"),),
      appBar: AppBarPro(AppLocalizations.of(context)!.become_organizer),
      body: SingleChildScrollView(
        child: InkWell(
          onTap: (){
            NameNode.hasFocus ? NameNode.unfocus() : null;
            EmailNode.hasFocus ? EmailNode.unfocus() : null;
            DescribeNode.hasFocus ? DescribeNode.unfocus() : null;
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 16,),
                Text(AppLocalizations.of(context)!.please_fill_up_your_contact_information_and,style: TextStyle(fontSize: 16),),
                SizedBox(height: 24,),
                // FormPro(NameController,NameNode,AppLocalizations.of(context)!.event_name,16,true,""),
                FormPro(NameController,NameNode,AppLocalizations.of(context)!.name,16,true,""),
                FormPro(EmailController,EmailNode,"Email",16,true,""),
                FormProMinLengthFiveHundred(DescribeController,DescribeNode,AppLocalizations.of(context)!.describe_your_event,16,true,""),
                ButtonPro(AppLocalizations.of(context)!.send_request, () async{
                  if(NameController.text.length==0||EmailController.text.length==0||DescribeController.text.length==0){
                    UserMessage("Fill in all the fields", context);
                  } else {
                    setState(() {wait_bool=true;});
                    await firestore.collection("OrganizerRequests").add({
                      "Name":NameController.text,
                      "EmailController":EmailController.text,
                      "Describe":DescribeController.text,
                      "Phone":_auth.currentUser!.phoneNumber.toString(),
                    });
                    UserMessage(AppLocalizations.of(context)!.your_application_has_been_sent, context);
                    Navigator.pop(context);
                  }
                }, wait_bool)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
