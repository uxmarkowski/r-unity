import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget EventCardForDeveloper({required context,required data,required russian_language}){

// Widget EventCard(context,header,img,price,is_online,is_indoor,address,peoples,maxpeoples,date,min){
  return Container(
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
                                    Text("Waiting",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),)
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
                      // child: Text(data['is_online'] ? AppLocalizations.of(context)!.online.toUpperCase() : data['is_indor'] ? AppLocalizations.of(context)!.indoor.toUpperCase() : AppLocalizations.of(context)!.outdoor.toUpperCase(),style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),),
                      child: Text(data['is_online'] ? 'ONLINE' : data['is_indor'] ? 'INDOOR' : 'OUTDOOR',style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 12),),
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