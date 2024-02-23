import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/pages/sign/sign_up.dart';
import 'package:event_app/pages/sign/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../pages/sign/sign_in.dart';
import '../widgets/custom_route.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void SignOut({required context}) async{
  FirebaseAuth _auth = FirebaseAuth.instance;

  var result=await showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      // title: Text(AppLocalizations.of(context)!.log),
      title: Text(AppLocalizations.of(context)!.log_out),
      // title: Text("Log out"),
      content: Text(AppLocalizations.of(context)!.are_you_sure_you_want_to_log_out),
      // content: Text("Are you sure you want to log out?"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(AppLocalizations.of(context)!.cancel),
          // child: Text("Cancel"),

          onPressed: () => Navigator.of(context).pop(false),
        ),
        CupertinoDialogAction(
          child: Text("OK"),
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if(result) {
    await _auth.signOut();
    final page = WelcomePage();
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
  }
}

void DeleteAccount({required context}) async{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  var result=await showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(AppLocalizations.of(context)!.attention),
      content: Text(AppLocalizations.of(context)!.this_will_delete_your_account_data),
      // content: Text("This will delete your account data, including your responses and ratings."),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(AppLocalizations.of(context)!.cancel),
          // child: Text("Cancel"),

          onPressed: () => Navigator.of(context).pop(false),
        ),
        CupertinoDialogAction(
          child: Text("OK"),
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if(result) {

    // await storageRef.child(AvatarLinkPath).delete();

    var UserNomber=_auth.currentUser?.phoneNumber.toString();
    await firestore.collection("UsersCollection").doc(UserNomber).delete();

    _auth.currentUser?.delete();

    final page = WelcomePage();
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
  }
}

void NeedToRegisterAccount({required context}) async{


  var result=await showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(AppLocalizations.of(context)!.no_such_user),
      // title: Text("No such user"),
      content: Text(AppLocalizations.of(context)!.this_phone_number_is_not),
      // content: Text("This phone number is not registered. Want to register?"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(AppLocalizations.of(context)!.cancel),
          // child: Text("Cancel"),

          onPressed: () => Navigator.of(context).pop(false),
        ),
        CupertinoDialogAction(
          child: Text(AppLocalizations.of(context)!.register),
          // child: Text("Register"),
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if(result) {

    final page = SignUpPage();
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
  }
}

void NeedToLoginAccount({required context}) async{


  var result=await showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(AppLocalizations.of(context)!.user_is_already_registered),
      // title: Text("User is already registered"),
      content: Text(AppLocalizations.of(context)!.this_phone_number_has_already),
      // content: Text("This phone number has already been registered.Do you want to log in?"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(AppLocalizations.of(context)!.cancel),
          // child: Text("Cancel"),

          onPressed: () => Navigator.of(context).pop(false),
        ),
        CupertinoDialogAction(
          child: Text(AppLocalizations.of(context)!.sign_in),
          // child: Text("Log in"),
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if(result) {

    final page = SignInPage();
    Navigator.of(context).pushAndRemoveUntil(CustomPageRoute(page),(Route<dynamic> route) => false);
  }
}