import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/chat/chat_page.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../pages/events/event_page.dart';
import '../pages/user/other_user_page.dart';
import '../pages/user/user_page.dart';
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

PreferredSizeWidget ChatAppBarPro({required Context,required user_doc,required title,required image,required clear_chat}) {
  return AppBar(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
    title: InkWell(
      onTap: (){
        final page = OtherUserPage(user_doc: user_doc,);
        Navigator.of(Context).push(CustomPageRoute(page));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(image!='') ...[
            Container(width: 36,height: 36,decoration: BoxDecoration(color: CupertinoColors.systemGrey4,borderRadius: BorderRadius.circular(36),image: DecorationImage(image: NetworkImage(image),fit: BoxFit.cover)),),
            SizedBox(width: 8,),
          ],
          Text(title,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
        ],
      )
    ),
    centerTitle: true,
    actions: [
      IconButton(onPressed: (){
        clear_chat();
      }, icon: Icon(CupertinoIcons.delete_solid,color: Colors.grey,))
    ],
  );
}

PreferredSizeWidget AppBarOtherUser({required title,required instagram}) {
  return AppBar(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
    title: Text(title,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
    centerTitle: true,
    actions: [

      if(instagram!="") InkWell(
        onTap: () async{
          var url = instagram;
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            throw 'Could not launch $url';
          }
        },
        child: Opacity(opacity: 0.4,
            child: SvgPicture.asset("lib/assets/Icons/Light/Instagram.svg")),
      ),
      SizedBox(width: 16,)
    ],
  );
}

PreferredSizeWidget EventAppBarPro({required title,required data}) {
  return AppBar(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon(CupertinoIcons.location_solid,size: 16,color: Colors.grey,),
        // SizedBox(width: 8,),
        Text(title.toString().length>14 ? title.toString().substring(0,14)+"..." : title,style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w400,),),
        // SizedBox(width: 16,),
      ],
    ),
    centerTitle: true,
    actions: [
      if((data as Map).containsKey("telegram"))...[
        if((data as Map)["telegram"].length>0&&(data as Map)["social_media_exist"])
          InkWell(
            onTap: () async{
              var url = data['telegram'];
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Opacity(opacity: 0.4,
                child: Container(
                  width: 24,
                  height: 24,
                  child: SvgPicture.asset("lib/assets/Icons/Light/telegram.svg")),
                ),
          ),
        SizedBox(width: 8),
      ],

      if((data as Map)["instagram"].length>0&&(data as Map)["social_media_exist"])
      InkWell(
        onTap: () async{
          var url = data['instagram'];
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          } else {
          throw 'Could not launch $url';
          }
        },
        child: Opacity(opacity: 0.4,
          child: SvgPicture.asset("lib/assets/Icons/Light/Instagram.svg")),
      ),
      SizedBox(width: 8),
      if((data as Map)["facebook"].length>0&&(data as Map)["social_media_exist"])
      InkWell(
        onTap: () async{

          var url = data['facebook'];
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          } else {
          throw 'Could not launch $url';
          }

        },
        child: Opacity(opacity: 0.4,
            child: SvgPicture.asset("lib/assets/Icons/Light/Facebook.svg")
        ),
      ),
      SizedBox(width: 12,)
    ],
  );
}

PreferredSizeWidget SignAppBarPro(title,flag) {
  return AppBar(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
    title: Text(title,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
    centerTitle: true,
    actions: [

    ],
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
      child: Text(title,style: TextStyle(fontSize: 24,fontWeight: FontWeight.w600,color: Colors.black,),textAlign: TextAlign.center,)
  );
}

Widget FormPro(controller,node,hint,margin,textfield,suffix) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Color.fromRGBO(239, 239, 255, 1),
      borderRadius: BorderRadius.circular(8)
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

Widget PromoMaterialFormPro(controller,node,hint,margin,textfield,suffix) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8)
    ),
    child: Material(
      color: Colors.white,
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
    ),
  );
}

Widget FormProCustomLength(controller,node,hint,margin,textfield,suffix,max_length) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
        color: Color.fromRGBO(239, 239, 255, 1),
        borderRadius: BorderRadius.circular(8)
    ),
    child: TextFormField(
      maxLines: null,
      maxLength: max_length,
      focusNode: node,
      controller: controller,
      keyboardType: textfield ? TextInputType.text : TextInputType.number,
      style: TextStyle(height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        suffix: Text(suffix,style: TextStyle(fontWeight: FontWeight.w700),),
        border: InputBorder.none,
        counterText: "",
      ),
    ),
  );
}

Widget FormProMinLength(controller,node,hint,margin,textfield,suffix) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Color.fromRGBO(239, 239, 255, 1),
      borderRadius: BorderRadius.circular(8)
    ),
    child: TextFormField(
      maxLines: null,
      maxLength: 16,

      focusNode: node,
      controller: controller,
      keyboardType: textfield ? TextInputType.text : TextInputType.number,
      style: TextStyle(height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        suffix: Text(suffix,style: TextStyle(fontWeight: FontWeight.w700),),
        border: InputBorder.none,
      ),
    ),
  );
}

Widget LockFormProMinLength(controller,node,hint,margin,textfield,suffix,lock) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
        color: Color.fromRGBO(239, 239, 255, 1),
        borderRadius: BorderRadius.circular(8)
    ),
    child: TextFormField(
      maxLines: null,
      maxLength: 16,
      focusNode: node,
      controller: controller,
      readOnly: lock,
      keyboardType: textfield ? TextInputType.text : TextInputType.number,
      style: TextStyle(height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        suffixIcon:  lock ? Icon(Icons.lock_outline,color: CupertinoColors.systemGrey3,) : null,
        suffix: Text(suffix,style: TextStyle(fontWeight: FontWeight.w700),),
        border: InputBorder.none,
      ),
    ),
  );
}

Widget FormProMinLengthFiveHundred(controller,node,hint,margin,textfield,suffix) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Color.fromRGBO(239, 239, 255, 1),
      borderRadius: BorderRadius.circular(8)
    ),
    child: TextFormField(
      maxLines: null,
      maxLength: 500,

      focusNode: node,
      controller: controller,
      keyboardType: textfield ? TextInputType.text : TextInputType.number,
      style: TextStyle(height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        suffix: Text(suffix,style: TextStyle(fontWeight: FontWeight.w700),),
        border: InputBorder.none,
      ),
    ),
  );
}

Widget BalanceFormPro(controller,node,hint,margin,textfield,suffix,context) {

  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: margin.toDouble()),
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: MediaQuery.of(context).platformBrightness!=Brightness.dark ? Colors.white : Colors.black,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(width: 1,color: MediaQuery.of(context).platformBrightness==Brightness.dark ? Colors.white.withOpacity(0.16) : Colors.black.withOpacity(0.16))
    ),
    child: TextFormField(
      maxLines: null,
      focusNode: node,
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(fontWeight: FontWeight.w700,color: MediaQuery.of(context).platformBrightness==Brightness.dark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontWeight: FontWeight.w400,color: MediaQuery.of(context).platformBrightness==Brightness.dark ? Colors.white : Colors.black),
        suffix: Text(suffix,style: TextStyle(fontWeight: FontWeight.w700,color: MediaQuery.of(context).platformBrightness==Brightness.dark ? Colors.white : Colors.black),),
        border: InputBorder.none,
      ),
    ),
  );
}

Widget MessageFieldPro({required context,required controller,required node,required hint,required space_left,required onFieldSubmitted,required onChanged}) {
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
      maxLength: 100,
      onChanged: (value){
        onChanged();
      },
      maxLines: null,
      focusNode: node,
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
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
        borderRadius: BorderRadius.circular(8)
    ),
    child: TextFormField(
      focusNode: node,
      keyboardType: TextInputType.phone,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        prefixIcon: Icon(CupertinoIcons.plus,size: 16,color: Colors.black,),
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
        primary: PrimaryCol,
        minimumSize: const Size.fromHeight(52), // NEW
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
    ),
    onPressed: onTap,
    child: wait ? CupertinoActivityIndicator(color: Colors.white,) : Text(title,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
  );
}

Widget ButtonProOutLine(title,onTap,wait) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 2,color: PrimaryCol),
      ),
      child: Center(
        child: wait ? CupertinoActivityIndicator(color: PrimaryCol,) : Text(title,style: TextStyle(fontSize: 16,color: PrimaryCol,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
      ),
    ),
  );
}

Widget ButtonProColored(title,onTap,wait,color) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        primary: color,
        minimumSize: const Size.fromHeight(52), // NEW
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
    ),
    onPressed: onTap,
    child: wait ? CupertinoActivityIndicator(color: Colors.white,) : Text(title,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
  );
}

Widget ButtonProColoredWidth(title,onTap,wait,color,width) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 56,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color
      ),
      child: Center(
        child: wait ? CupertinoActivityIndicator(color: Colors.white,) : Text(title,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
      ),
    ),
  );
}


Widget ProfileButton(Icon,CallBack,NotificationLenght){
  return GestureDetector(
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

Widget EventCard({required context,required data,required getData,required russian_language}){

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
            height: MediaQuery.of(context).size.width>700 ? 300 : 160,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width>700 ? 300 : 160,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black12,
                      image: DecorationImage(
                        image: NetworkImage(data['photo_link']),
                        fit: BoxFit.cover,
                      )
                  ),
                ),
                if((data as Map).containsKey("approved"))...[
                  if(!data["approved"]) ...[
                    Positioned(
                        top: 8,left: 8,
                        child: Column(
                          children: [
                            if((data as Map).containsKey("approved"))...[
                              if(data["approved"]) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(width: 1,color: Colors.white),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                                  child: Row(
                                    children: [
                                      Text(AppLocalizations.of(context)!.waiting,style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),)
                                      // Text("Waiting",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),)
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8,)
                              ]
                            ],
                          ],
                        )
                    ),
                  ]
                ],

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
                        child: Text(data['is_online'] ? AppLocalizations.of(context)!.online.toUpperCase() : data['is_indor'] ? AppLocalizations.of(context)!.indoor.toUpperCase() : AppLocalizations.of(context)!.outdoor.toUpperCase(),style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),),
                        // child: Text(data['is_online'] ? 'ONLINE' : data['is_indor'] ? 'INDOOR' : 'OUTDOOR',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),),
                      ),
                    ],
                  ),
                ),
                if(data.containsKey("show_flag")&&data.containsKey("primary_language")) ...[
                  if(data['show_flag']&&data['primary_language']!="All languages") Positioned(
                    top: 8,right: 8,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(width: 1,color: Colors.grey),
                              image: DecorationImage(
                                  image: data['primary_language']=="English" ? AssetImage("lib/assets/Flag/EngFlag.png")
                                      :  data['primary_language']=="American English" ? AssetImage("lib/assets/Flag/UsFlag.png")
                                      :  data['primary_language']=="Русский" ? AssetImage("lib/assets/Flag/RusFlag.png")
                                      :  data['primary_language']=="Українська" ? AssetImage("lib/assets/Flag/UkrFlag.png")
                                      :  data['primary_language']=="Қазақ" ? AssetImage("lib/assets/Flag/KazFlag.png")
                                      :  data['primary_language']=="հայերեն" ? AssetImage("lib/assets/Flag/ArmFlag.png")
                                      : AssetImage("lib/assets/Flag/EngFlag.png")
                              )
                          ),
                          width: 32,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
          SizedBox(height: 12,),
          Text(russian_language&&data['rus_header']!="" ? data['rus_header'].toString() : data['header'].toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
          SizedBox(height: 8),
          Row(
            children: [
              IconText(DateTime.fromMillisecondsSinceEpoch(data['date']).hour.toString()+":"+(DateTime.fromMillisecondsSinceEpoch(data['date']).minute>9 ? DateTime.fromMillisecondsSinceEpoch(data['date']).minute.toString() : "0"+DateTime.fromMillisecondsSinceEpoch(data['date']).minute.toString() )+
                  " | "+data['duration'].toString()+" min.","TimeSquare.svg"),
              SizedBox(width: 16,),
              data['price']=="0" ?
              // IconText(AppLocalizations.of(context)!.free,"Wallet.svg") :
              IconText("FREE","Wallet.svg") :
              IconText("\$"+data['price'].toString(),"Wallet.svg"),
              if(data.containsKey("infinity_users")) ...[
                if(!data['infinity_users'])...[
                  SizedBox(width: 16,),
                  data['unlimited_users'] ? IconText(""+data['max_peoples'].toString(),"Users.svg") : IconText(data['peoples'].toString()+"/"+data['max_peoples'].toString(),"Users.svg")
                ],
              ] else ...[
                SizedBox(width: 16,),
                data['unlimited_users'] ? IconText(""+data['max_peoples'].toString(),"Users.svg") : IconText(data['peoples'].toString()+"/"+data['max_peoples'].toString(),"Users.svg")
              ]
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
        border: Border.all(width: 1,color: Colors.black26),
        borderRadius: BorderRadius.circular(48)
    ),
    child: Text(text,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500,color: Color.fromRGBO(81, 81, 87, 1)),),
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


Widget PromoCodePlusButton({required text,required onPlus,required count,required onMinus}){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(text,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
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

Widget ChatCard(Context,Name,LastMessage,Img,DocId,UnReaded,GetChats,Phone) {
  return InkWell(
    onTap: (){
      final page = ChatPage(appbar: Name,doc_id: DocId, phone: Phone,);
      Navigator.of(Context).push(CustomPageRoute(page)).then((value) => GetChats());
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
                  LastMessage!=null ? Text(LastMessage.length>28 ? LastMessage.toString().substring(0,28) : LastMessage.toString(),style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),) : Text("Send first message!",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.grey),),
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

Widget FriendCard({required Context,required Name,required LastMessage,required Img,required DocId,required Phone,required NeedToAddFriend,required on_tap}) {
  return InkWell(
    onTap: (){
      on_tap(NeedToAddFriend,Context,Phone,DocId);
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

Widget EventUserCard(Context,Name,Status,Img,DocId,IAmOrganizer,DeleteButton,AddFromUsersList,IsVerified) {
  FirebaseAuth _auth = FirebaseAuth.instance;

  return GestureDetector(
    onTap: (){
      if(DocId!=_auth.currentUser!.phoneNumber&&Status!="Member"){
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
                height: 68,
                width: 68,
                child: Stack(
                  children: [
                    if(Status=="Organizer") ...[
                      Container(
                        height: 68,
                        width: 68,
                        child: SvgPicture.asset("lib/assets/StoryBorder.svg"),
                      ),
                    ],
                    Center(
                      child: Container(
                        height: 70,
                        width: 70,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                height: Status!="Organizer" ? 60 : 56,
                                width: Status!="Organizer" ? 60 : 56,
                                decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey3,
                                    borderRadius: BorderRadius.circular(Status!="Organizer" ? 16 : 16,),
                                    image: DecorationImage(
                                        image: NetworkImage(Img),
                                      fit: BoxFit.cover
                                    )
                                ),
                              ),
                            ),
                            if(Status=="Organizer"&&IsVerified) Positioned(
                              bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: Colors.black26,blurRadius: 20)]
                                    ),
                                    child: Center(child: Icon(CupertinoIcons.shield_lefthalf_fill,color: Colors.orange,size: 16,))
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8,),
                  Text(Name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                  SizedBox(height: 4,),
                  if(Status=="Organizer") ...[
                    Text(IsVerified ? AppLocalizations.of(Context)!.verified_organizer : AppLocalizations.of(Context)!.organizer,style: TextStyle(fontWeight: FontWeight.w700,color: Colors.orange),),
                  ] else if (Status=="Member") ...[
                    Text(AppLocalizations.of(Context)!.added_by_organizer),
                  ] else  ...[
                    Text(Status),
                  ]

                ],
              ),
            ],
          ),
          if(DocId!=_auth.currentUser!.phoneNumber&&IAmOrganizer&&!Status.toString().startsWith("Wait"))...[
            InkWell(
                onTap: (){

                  DeleteButton();

                },
                child: SvgPicture.asset("lib/assets/Icons/Bold/Close.svg",width: 36,)
            ),
          ] else if(DocId!=_auth.currentUser!.phoneNumber&&IAmOrganizer&&Status.toString().startsWith("Wait")) ...[
            InkWell(
                onTap: AddFromUsersList,
                child: SvgPicture.asset("lib/assets/Icons/Bold/Plus.svg",width: 36,)
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

Widget ProfileAvatarSquare(doc_id){

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  return FutureBuilder(
      future: firestore.collection("UsersCollection").doc(doc_id).snapshots().first,
      builder: (context,snapshot){

        if(snapshot.hasData){
          if(snapshot.data!.get("avatar_link")==""){
            return Container(
              height: 200,
              width: double.infinity,
              child: CircleAvatar(
                backgroundColor: Colors.black,
                // backgroundImage: snapshot.data!.get("gender")
                // AssetImage('lib/images/men_avatar.png') :
                // AssetImage('lib/images/women_avatar.png',),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black,width: 1)
              ),
            );
          } else {
            // return CircleAvatar(
            //   backgroundColor: Colors.grey,
            //   backgroundImage: NetworkImage(snapshot.data!.get("avatar_link")),
            // );
            return Container(
              width: double.infinity,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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

  var logo_linc="https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.upwork.com%2Fresources%2Foperations-manager-job-description&psig=AOvVaw3dbXrm92dXWJ-8zM_tbwZY&ust=1703728413405000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCPj10InBroMDFQAAAAAdAAAAABAQ";

  return InkWell(
    onTap: (){
      Function("String");
    },
    child: Container(

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 2),
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: Img!=logo_linc ? DecorationImage(
                      image: NetworkImage(Img),
                      fit: BoxFit.cover
                    ) : DecorationImage(
                        image: AssetImage("lib/assets/logo.png"),
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