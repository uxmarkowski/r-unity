import 'package:event_app/pages/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../pages/chat/chatlist_page.dart';
import '../pages/events/event_list_page.dart';
import '../pages/global_variables.dart';
import '../pages/sign/welcome_page.dart';
import 'custom_route.dart';




Widget BottomNavBarPro(context,currentIndex) {
  final globalProvider = Provider.of<GlobalProvider>(context);
  final globalData = globalProvider.notifications_lenght_get;

  return BottomNavigationBar(
    currentIndex: currentIndex,
    elevation: 24,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    onTap: (index){
      switch(index){
        case 0:
          final page = EventListPage(IsMyEvents: false, IsMyOrganizerEvents: false, ApproveWidgets: false, );
          Navigator.of(context).push(CustomPageRoute(page));
          break;
        case 1:
          final page = ChatListPage();
          Navigator.of(context).push(CustomPageRoute(page));
          break;
        case 2:
          final page = UserPage();
          Navigator.of(context).push(CustomPageRoute(page));
          break;
      }

    },
    items: [
      BottomNavigationBarItem(
          activeIcon: SvgPicture.asset("lib/assets/Icons/Bold/Document.svg",color: PrimaryCol,),
          icon: SvgPicture.asset("lib/assets/Icons/Light/Document.svg",color: Colors.black54),
          label: ""
      ),
      BottomNavigationBarItem(
          activeIcon: Stack(
            children: [
              Container(margin: EdgeInsets.only(left: 8),width: 36,child: SvgPicture.asset("lib/assets/Icons/Bold/Chat.svg",color: PrimaryCol)),
              if(globalProvider.uncheck_messages_lenght!=0) Positioned(right: 0,child: Icon(Icons.circle,color: Colors.red,size: 8,)),
            ],
          ),
          icon: Stack(
            children: [
              Container(margin: EdgeInsets.only(left: 8),width: 36,child: SvgPicture.asset("lib/assets/Icons/Light/Chat.svg",color: Colors.black54)),
              if(globalProvider.uncheck_messages_lenght!=0) Positioned(right: 0,child: Icon(Icons.circle,color: Colors.red,size: 8,)),
            ],
          ),
          // activeIcon: SvgPicture.asset("lib/assets/Icons/Bold/Chat.svg",color: globalProvider.uncheck_messages_lenght==0 ? PrimaryCol : Colors.red,),
          // icon: SvgPicture.asset("lib/assets/Icons/"+(globalProvider.uncheck_messages_lenght==0 ? "Light" : "Bold")+"/Chat.svg",color: globalProvider.uncheck_messages_lenght==0 ? Colors.black54 : Colors.red),
          label: ""
      ),
      BottomNavigationBarItem(
          activeIcon: Stack(
            children: [
              Container(width: 32,child: SvgPicture.asset("lib/assets/Icons/Bold/Profile.svg",color: PrimaryCol)),
              if(globalProvider.notifications_lenght_get!=0) Positioned(right: 0,child: Icon(Icons.circle,color: Colors.red,size: 8,)),
            ],
          ),
          icon: Stack(
            children: [
              Container(width: 32,child: SvgPicture.asset("lib/assets/Icons/Light/Profile.svg",color: Colors.black54)),
              if(globalProvider.notifications_lenght_get!=0) Positioned(right: 0,child: Icon(Icons.circle,color: Colors.red,size: 8,)),
            ],
          ),
          // activeIcon: SvgPicture.asset("lib/assets/Icons/Bold/Profile.svg",color: globalProvider.notifications_lenght_get==0 ? PrimaryCol : Colors.red,),
          // icon: SvgPicture.asset("lib/assets/Icons/"+(globalProvider.notifications_lenght_get==0 ? "Light" : "Bold")+"/Profile.svg",color: globalProvider.notifications_lenght_get==0 ? Colors.black54 : Colors.red),
          label: ""
      ),
    ],
  );
}