import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/sign_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/custom_route.dart';
import '../../widgets/voice_mes/user_message.dart';


class EditCategoriesPage extends StatefulWidget {
  final appbar;
  final nickname;

  const EditCategoriesPage({Key? key,required this.appbar,required this.nickname}) : super(key: key);

  @override
  State<EditCategoriesPage> createState() => _EditCategoriesPageState();
}


class _EditCategoriesPageState extends State<EditCategoriesPage> {

  TextEditingController CategoriesController=TextEditingController();
  TextEditingController CategoriesControllerRus=TextEditingController();
  FocusNode CategoriesNode=FocusNode();
  FocusNode CategoriesNodeRus=FocusNode();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List Categories=[];


  bool wait_bool=false;

  void GetCategories() async{
    Categories=[];
    var CategoriesCollection = await firestore.collection("Categories").get();

    await Future.forEach(CategoriesCollection.docs, (doc) {
      Categories.add(doc.id);
    });

    setState(() { });

  }

  @override
  void initState() {
    GetCategories();

    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro(widget.appbar),
      body: InkWell(
        onTap: (){
          CategoriesNode.hasFocus ? CategoriesNode.unfocus() : null;
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16,),
                      Categories.length==0 ?
                      Center(child: CupertinoActivityIndicator(color: Colors.black,))    :
                      ListView.separated(
                        padding: EdgeInsets.all(0),
                        itemBuilder: (context,index){
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(Categories[index],style: TextStyle(color: Colors.black,fontSize: 24),),
                              InkWell(
                                  child: Icon(Icons.close,size: 28,),
                                onTap: (){
                                  firestore.collection("Categories").doc(Categories[index]).delete();
                                  Categories.removeAt(index);
                                  setState(() {

                                  });
                                },
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context,index){
                          return Divider(height: 36,color: Colors.black38,);
                        },
                        shrinkWrap: true,
                        itemCount: Categories.length,
                        physics: NeverScrollableScrollPhysics(),
                      ),
                      Divider(height: 24,color: Colors.white,),
                      FormPro(CategoriesController,CategoriesNode,"New category",16,true,""),
                      FormPro(CategoriesControllerRus,CategoriesNodeRus,"Новая категория",16,true,""),
                    ],
                  ),
                  ButtonPro("Add category",() async{
                    // await firestore.collection("Nicknames").doc(NickNameController.text).set({"active":true});
                    // await firestore.collection("Nicknames").doc(widget.nickname).delete();
                    //
                    //
                    // await firestore.collection("UsersCollection").doc(_auth.currentUser!.phoneNumber).update({
                    //   "nickname": NickNameController.text,
                    //   "firstname": NickNameController.text,
                    //   "lastname": NickNameController.text,
                    //   "email": EmailController.text,
                    //   "about": AboutController.text,
                    // });
                    // Navigator.pop(context);
                    if(CategoriesController.text.length==0||CategoriesControllerRus.text.length==0){
                      UserMessage("Заполни оба поля", context);
                    } else {
                      setState(() {wait_bool=true;});

                      await firestore.collection("Categories").doc(CategoriesController.text).set({
                        "active": true,
                        "name": CategoriesController.text,
                        "name_rus": CategoriesControllerRus.text,
                      });
                      GetCategories();
                      setState(() {wait_bool=false;CategoriesController.clear();});
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