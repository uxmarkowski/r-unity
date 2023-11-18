import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/chat/chat_page.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../pages/events/event_page.dart';
import '../pages/other_user_page.dart';
import '../pages/user_page.dart';
import 'custom_route.dart';



PreferredSizeWidget AppBarPro(title) {
  return AppBar(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
    title: Text(title,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
    centerTitle: true,
  );
}



Widget ScaffoldBodyPro(children) {
  return SingleChildScrollView(
    child: Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: children,
      ),
    ),
  );
}

Widget BigText(title) {
  return Text(title,style: TextStyle(fontSize: 24,fontWeight: FontWeight.w600,color: Colors.black),);
}

Widget BigTextCenter(title) {
  return Center(
      child: Text(title,style: TextStyle(fontSize: 24,fontWeight: FontWeight.w600,color: Colors.black),)
  );
}

Widget FormPro(controller,node,hint,margin,textfield,suffix) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Color.fromRGBO(239, 239, 255, 1),
      borderRadius: BorderRadius.circular(4)
    ),
    child: TextFormField(
      maxLines: null,
      focusNode: node,
      controller: controller,
      keyboardType: textfield ? TextInputType.text : TextInputType.number,
      style: TextStyle(height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        suffix: Text(suffix,style: TextStyle(fontWeight: FontWeight.w700),),
        border: InputBorder.none,
      ),
    ),
  );
}

Widget BalanceFormPro(controller,node,hint,margin,textfield,suffix) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(12)
    ),
    child: TextFormField(
      maxLines: null,
      focusNode: node,
      controller: controller,
      keyboardType: textfield ? TextInputType.text : TextInputType.number,
      style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontWeight: FontWeight.w400,color: Colors.white70),
        suffix: Text(suffix,style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white),),
        border: InputBorder.none,
      ),
    ),
  );
}

Widget MessageFieldPro(context,controller,node,hint,space_left,onFieldSubmitted) {
  return Container(
    width: MediaQuery.of(context).size.width-24-28-12*2-space_left,
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
        color: Color.fromRGBO(239, 239, 255, 1),
        borderRadius: BorderRadius.circular(4)
    ),
    child: TextFormField(
      onFieldSubmitted: (value){
        onFieldSubmitted();
      },
      maxLines: null,
      focusNode: node,
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
      ),
    ),
  );
}

Widget FakeFormPro(hint) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
        color: Color.fromRGBO(239, 239, 255, 1),
        borderRadius: BorderRadius.circular(4)
    ),
    child: TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
      ),
    ),
  );
}

Widget PhoneFormPro(controller,node,hint) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
        color: Color.fromRGBO(239, 239, 255, 1),
        borderRadius: BorderRadius.circular(4)
    ),
    child: TextFormField(
      focusNode: node,
      keyboardType: TextInputType.phone,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        prefixIcon: Icon(CupertinoIcons.plus,size: 16,),
        prefixIconConstraints: BoxConstraints(minWidth: 24)
      ),
      onChanged: (value){
        // var text=(controller as TextEditingController).text;
        // if(text.length>=1){
        //   (controller as TextEditingController).text="+"+(controller as TextEditingController).text;
        // }
      },
    ),
  );
}

Widget ButtonPro(title,onTap,wait) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        primary: Color.fromRGBO(0, 45, 227, 1),
        minimumSize: const Size.fromHeight(52), // NEW
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
    ),
    onPressed: onTap,
    child: wait ? CupertinoActivityIndicator(color: Colors.white,) : Text(title,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
  );
}


Widget ProfileButton(Icon,CallBack,NotificationLenght){
  return InkWell(
    onTap: CallBack,
    child: Stack(
      children: [
        Container(
          margin: EdgeInsets.all(2),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Color.fromRGBO(228, 232, 249, 1),
            borderRadius: BorderRadius.circular(56),
          ),
          child: Center(child: SvgPicture.asset("lib/assets/Icons/Light/"+Icon)),
        ),
        if(Icon=="Notification.svg"&&NotificationLenght!=0) ...[
          Positioned(
            top: 0,right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(NotificationLenght.toString(),style: TextStyle(fontSize: 12,color: Colors.white),),
              )
          )
        ]
      ],
    ),
  );
}

Widget ProfileButtons(Icon,Name,CallBack){
  return GestureDetector(
    onTap: CallBack,
    child: Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset("lib/assets/Icons/Light/"+Icon),
              SizedBox(width: 8),
              Text(Name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
            ],
          ),
          SvgPicture.asset("lib/assets/Icons/Light/Right.svg"),
        ],
      ),
    ),
  );
}

Widget EventCard(context,data,getData){

// Widget EventCard(context,header,img,price,is_online,is_indoor,address,peoples,maxpeoples,date,min){
  return InkWell(
    onTap: (){
      final page = EventPage(data: data,);
      Navigator.of(context).push(CustomPageRoute(page)).then((value) => getData());
    },
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12,spreadRadius: 4,blurRadius: 20)
          ]
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 112,
            child: Stack(
              children: [
                Container(
                  height: 112,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black12,
                      image: DecorationImage(
                        image: NetworkImage(data['photo_link']),
                        fit: BoxFit.cover,
                      )
                  ),
                ),
                Positioned(
                  bottom: 8,left: 8,
                  child: Row(
                    children: [
                      if(!data['is_online']) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(width: 1,color: Colors.grey),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                          child: Row(
                            children: [
                              SvgPicture.asset("lib/assets/Icons/Bold/Location.svg",width: 12,),
                              SizedBox(width: 4,),
                              (data as Map).containsKey("short_address") ?
                              Text(data['short_address'].length<16 ? data['short_address'].toUpperCase() : data['short_address'].substring(0,16).toUpperCase()+"...",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),) :
                              Text(data['address'].length<16 ? data['address'].toUpperCase() : data['address'].substring(0,16).toUpperCase()+"...",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(width: 1,color: Colors.grey),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                        child: Text(data['is_online'] ? 'ONLINE' : data['is_indor'] ? 'INDOOR' : 'OUTDOOR',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 12,),
          Text(data['header'].toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
          SizedBox(height: 8),
          Row(
            children: [
              IconText(DateTime.fromMillisecondsSinceEpoch(data['date']).hour.toString()+":"+(DateTime.fromMillisecondsSinceEpoch(data['date']).minute>9 ? DateTime.fromMillisecondsSinceEpoch(data['date']).minute.toString() : "0"+DateTime.fromMillisecondsSinceEpoch(data['date']).minute.toString() )+
                  " | "+data['duration'].toString()+" min.","TimeSquare.svg"),
              SizedBox(width: 16,),
              data['price']=="0" ?
              IconText("FREE","Wallet.svg") :
              IconText("\$"+data['price'].toString(),"Wallet.svg"),
              SizedBox(width: 16,),
              IconText(data['peoples'].toString()+"/"+data['max_peoples'].toString(),"Users.svg"),
            ],
          )
        ],
      ),
    ),
  );
}


Widget TagPro(text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
    decoration: BoxDecoration(
        border: Border.all(width: 1,color: Colors.black87),
        borderRadius: BorderRadius.circular(48)
    ),
    child: Text(text,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Color.fromRGBO(81, 81, 87, 1)),),
  );
}

Widget TextPlusButton(text,onTap){
  return InkWell(
    onTap: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
        SvgPicture.asset("lib/assets/Icons/Bold/Plus.svg")
      ],
    ),
  );
}

Widget AdditionalTextPlusButton(text,onPlus,count,onMinus){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      count==0 ? Text(text,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),) :
      Text(text+" ("+count.toString()+")",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
      Row(
        children: [
          if(count!=0)...[
            InkWell(
                onTap: onMinus,
                child: SvgPicture.asset("lib/assets/Icons/Bold/Minus.svg")
            ),
          ],
          InkWell(
            onTap: onPlus,
              child: SvgPicture.asset("lib/assets/Icons/Bold/Plus.svg")
          ),
        ],
      )
    ],
  );
}

Widget IconText(text,icon){
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SvgPicture.asset("lib/assets/Icons/Light/"+icon,width: 24,color: Colors.black54,),
      SizedBox(width: 6,),
      Text(text,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Colors.black54),),
    ],
  );
}

Widget OtherMessage(img,text,date){
  return Align(
    alignment: Alignment.topLeft,
    child: Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12),bottomRight: Radius.circular(12),bottomLeft: Radius.circular(0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(img!="")...[
            Container(
              height: 200,
              width: 200,
              child: ClipRRect(
                child: Image.network(img,fit: BoxFit.cover,),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16,),
          ],
          if(text.length!=0) ...[
            Text(text,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600)),
            SizedBox(height: 8,),
          ],
          Text(DateTime.fromMillisecondsSinceEpoch(date).hour.toString()+":"+(DateTime.fromMillisecondsSinceEpoch(date).minute>9 ? DateTime.fromMillisecondsSinceEpoch(date).minute.toString() : "0"+DateTime.fromMillisecondsSinceEpoch(date).minute.toString() ),style: TextStyle(color: Colors.black45,fontSize: 14),),
        ],
      ),
    ),
  );
}

Widget MyMessage(img,text,date){
  return Align(
    alignment: Alignment.topRight,
    child: Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: PrimaryCol,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12),bottomRight: Radius.circular(0),bottomLeft: Radius.circular(12))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(img!="")...[
            Container(
              height: 200,
              width: 200,
              child: ClipRRect(
                child: Image.network(img,fit: BoxFit.cover,),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16,),
          ],
          if(text.length!=0) ...[
            Text(text,style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w600)),
            SizedBox(height: 8,),
          ],
          Text(DateTime.fromMillisecondsSinceEpoch(date).hour.toString()+":"+(DateTime.fromMillisecondsSinceEpoch(date).minute>9 ? DateTime.fromMillisecondsSinceEpoch(date).minute.toString() : "0"+DateTime.fromMillisecondsSinceEpoch(date).minute.toString() ),style: TextStyle(color: Colors.white54,fontSize: 14),),
        ],
      ),
    ),
  );
}

Widget ChatCard(Context,Name,LastMessage,Img,DocId,UnReaded) {
  return InkWell(
    onTap: (){
      final page = ChatPage(appbar: Name,doc_id: DocId,);
      Navigator.of(Context).push(CustomPageRoute(page));
    },
    child: Container(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey3,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                        image: NetworkImage(Img),
                      fit: BoxFit.cover
                    )
                ),
              ),
              SizedBox(width: 16,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8,),
                  Text(Name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                  SizedBox(height: 4,),
                  LastMessage!=null ? Text(LastMessage.length>14 ? LastMessage.toString().substring(0,14) : LastMessage.toString(),style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey),) : Text("Send first message!",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey),),
                ],
              ),
            ],
          ),
          SizedBox(width: 16,),
          if(UnReaded ?? false) ...[
            Center(
              child: Icon(Icons.circle,color: Colors.red,size: 12,),
            )
          ]
        ],
      ),
    ),
  );
}

Widget FriendCard(Context,Name,LastMessage,Img,DocId) {
  return InkWell(
    onTap: (){
      final page = OtherUserPage(user_doc: DocId,);
      Navigator.of(Context).push(CustomPageRoute(page));
    },
    child: Container(
      height: 64,
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
                color: CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                    image: NetworkImage(Img),
                    fit: BoxFit.cover
                )
            ),
          ),
          SizedBox(width: 16,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8,),
              Text(Name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
              SizedBox(height: 4,),
              LastMessage!=null ? Text(LastMessage.length>14 ? LastMessage.toString().substring(0,14) : LastMessage.toString(),style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey),) : Text("Send first message!",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey),),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget EventUserCard(Context,Name,Status,Img,DocId,IAmOrganizer,DeleteButton) {
  FirebaseAuth _auth = FirebaseAuth.instance;

  return GestureDetector(
    onTap: (){
      if(DocId!=_auth.currentUser!.phoneNumber){
        final page = OtherUserPage(user_doc: DocId,);
        Navigator.of(Context).push(CustomPageRoute(page));
      } else {
        // final page = UserPage();
        // Navigator.of(Context).push(CustomPageRoute(page));
      }
    },
    child: Container(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey3,
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                        image: NetworkImage(Img),
                      fit: BoxFit.cover
                    )
                ),
              ),
              SizedBox(width: 16,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8,),
                  Text(Name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                  SizedBox(height: 4,),
                  if(Status=="Organizer") ...[
                    Text(Status,style: TextStyle(fontWeight: FontWeight.w700,color: Colors.orange),),
                  ] else ...[
                    Text(Status),
                  ]

                ],
              ),
            ],
          ),
          if(DocId!=_auth.currentUser!.phoneNumber&&IAmOrganizer)...[
            InkWell(
                onTap: DeleteButton,
                child: SvgPicture.asset("lib/assets/Icons/Bold/Close.svg",width: 36,)
            ),
          ]
        ],
      ),
    ),
  );
}

Widget AddOrganizerCard(Context,Name,Status,Img,onTap,icon) {
  return Container(
    height: 64,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                      image: NetworkImage(Img),
                      fit: BoxFit.cover
                  )
              ),
            ),
            SizedBox(width: 16,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8,),
                Text(Name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                SizedBox(height: 4,),
                if(Status=="Organizer") ...[
                  Text(Status,style: TextStyle(fontWeight: FontWeight.w700,color: Colors.orange),),
                ] else ...[
                  Text(Status),
                ]

              ],
            ),
          ],
        ),
        InkWell(
          onTap: onTap,
            child: SvgPicture.asset("lib/assets/Icons/Bold/$icon.svg",width: 36,)
        ),
      ],
    ),
  );
}


Widget ProfileAvatar(doc_id){
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  return FutureBuilder(
      future: firestore.collection("UsersCollection").doc(doc_id).snapshots().first,
      builder: (context,snapshot){

        if(snapshot.hasData){
          if(snapshot.data!.get("avatar_link")==""){
            return Container(
              height: 100,
              width: 100,
              child: CircleAvatar(
                backgroundColor: Colors.black,
                // backgroundImage: snapshot.data!.get("gender")
                // AssetImage('lib/images/men_avatar.png') :
                // AssetImage('lib/images/women_avatar.png',),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.black,width: 1)
              ),
            );
          } else {
            // return CircleAvatar(
            //   backgroundColor: Colors.grey,
            //   backgroundImage: NetworkImage(snapshot.data!.get("avatar_link")),
            // );
            return Container(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(snapshot.data!.get("avatar_link"),
                  fit: BoxFit.cover,
                  loadingBuilder: (context,child,loadingProgress){
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },),
              ),
            );
          }
        } else {
          return Container(
            height: 100,
            width: 100,
            // child: Image.asset('lib/images/men_avatar.png'),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.black,width: 1)
            ),
          );;
        }

      }
  );
}

Widget NotificationCard(Name,Check,Img,Function) {
  return InkWell(
    onTap: (){
      Function("String");
    },
    child: Container(

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(Img),
                      fit: BoxFit.cover
                    )
                ),
              ),
              SizedBox(width: 12,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 180,
                      child: Text(Name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),)
                  ),
                  SizedBox(height: 4,),
                ],
              ),
            ],
          ),

          if(!Check) ...[
            Center(
              child: Icon(Icons.circle,color: Colors.red,size: 12,),
            )
          ]
        ],
      ),
    ),
  );
}


Widget PinCode(NumberController,){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(width: 12,),
      if(NumberController.text.length>=1) ...[
        Container(
          width: 24,
          height: 36,
          child: Center(
              child: Text(NumberController.text.substring(0,1),style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),)
          ),
        ),
      ] else ...[
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(40)
          ),
        ),
      ],
      if(NumberController.text.length>=2) ...[
        Container(
          width: 24,
          height: 36,
          child: Center(
              child: Text(NumberController.text.substring(1,2),style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),)
          ),
        ),
      ]  else ...[
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(40)
          ),
        ),
      ],
      if(NumberController.text.length>=3) ...[
        Container(
          width: 24,
          height: 36,
          child: Center(
              child: Text(NumberController.text.substring(2,3),style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),)
          ),
        ),
      ] else ...[
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(40)
          ),
        ),
      ],
      if(NumberController.text.length>=4) ...[
        Container(
          width: 24,
          height: 36,
          child: Center(
              child: Text(NumberController.text.substring(3,4),style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),)
          ),
        ),
      ] else ...[
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(40)
          ),
        ),
      ],
      if(NumberController.text.length>=5) ...[
        Container(
          width: 24,
          height: 36,
          child: Center(
              child: Text(NumberController.text.substring(4,5),style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),)
          ),
        ),
      ] else ...[
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(40)
          ),
        ),
      ],
      if(NumberController.text.length>=6) ...[
        Container(
          width: 24,
          height: 36,
          child: Center(
              child: Text(NumberController.text.substring(5,6),style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),)
          ),
        ),
      ] else ...[
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(40)
          ),
        ),
      ],
      SizedBox(width: 12,),
    ],
  );
}