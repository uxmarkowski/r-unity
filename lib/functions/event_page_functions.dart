import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void SendDeleteNotification({required doc_id,required data}) async{ FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore.collection("UsersCollection").doc(doc_id).collection("Notifications").add(
      {
        "title":"The organizer has removed you from the "+data["header"]+". The money has been refunded to your balance",
        "title_rus":"Организатор удалил вас из "+data["header"]+". Деньги возращены на баланс",
        "photo_link": data["photo_link"].toString(),
        "type":"delete_notification",
        "check":false,
        "date":DateTime.now().millisecondsSinceEpoch
      });
}

void SendAcceptNotification({required doc_id,required data}) async{ FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore.collection("UsersCollection").doc(doc_id).collection("Notifications").add(
      {
        "title":"The organizer has approved your participation in the event "+data["header"],
        "title_rus":"Организатор принял вас в мероприятие "+data["header"],
        "photo_link": data["photo_link"].toString(),
        "type":"event_accept_notification",
        "check":false,
        "date":DateTime.now().millisecondsSinceEpoch
      });
}

void SendFriendInviteNotification({required doc_id,required data}) async{ FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore.collection("Events").doc(data['id']).collection("InvitedUsers").doc(doc_id).set({
    "active":true
  });

  await firestore.collection("UsersCollection").doc(doc_id).collection("Notifications").add(
      {
        "title":"You invtited to "+data["header"],
        "title_rus":"Вы приглашены в "+data["header"],
        "photo_link": data["photo_link"].toString(),
        "type":"friend_invite_to_event",
        "check":false,
        "id":data['id'],
        "date":DateTime.now().millisecondsSinceEpoch
      });

}