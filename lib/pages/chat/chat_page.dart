import 'dart:async';
import 'dart:io';


import 'package:app_settings/app_settings.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/widgets/voice_mes/user_message.dart';
import 'package:event_app/widgets/voice_mes/voice_mes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';


import '../../main.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/voice_mes/contact_noises.dart';
import '../global_variables.dart';
import '../sign/welcome_page.dart';


class ChatPage extends StatefulWidget {
  final appbar;
  final doc_id;
  final phone;
  const ChatPage({Key? key,required this.appbar,required this.doc_id,required this.phone}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List MessageList=[ ];
  var image_url="";

  late StreamSubscription stream;
  final ImagePicker _picker = ImagePicker();
  late XFile? image;

  bool image_load=false;

  TextEditingController MessageController = TextEditingController();
  FocusNode MessageNode = FocusNode();


  

  void SendMessage(Message) async{
    firestore.collection("Chats").doc(widget.doc_id).collection("Messages").add(Message);
  }

  void GetAllMessage() async{
    setState(() {
      MessageList=[];
    });

    var MessagesCollection=await firestore.collection("Chats").doc(widget.doc_id).collection("Messages").get();
    print("Получаем сообщения "+widget.doc_id.toString());
    await Future.forEach(MessagesCollection.docs, (message) => MessageList.add(message.data()));
    // MessageList=messages.data()!['messages'] as List;
    MessageList.sort((a,b){
      return DateTime.fromMillisecondsSinceEpoch(a["time"]).compareTo(DateTime.fromMillisecondsSinceEpoch(b["time"]));
    });
    if(MessageList.length>MessagesCollection.docs.length) GetAllMessage();
    setState(() { });
    // UpDateMessage(messages);
  }

  // void UpDateMessage(messages){
  //
  //   MessageList=messages.data()!['messages'] as List;
  //   MessageList.forEach((element) {
  //     if(element['user']!=_auth.currentUser!.phoneNumber){
  //       element['status']="sent";
  //     };
  //   });
  //
  //   AllReaded(MessageList);
  // }

  void AllReaded() async{
    var MessagesCollection=await firestore.collection("Chats").doc(widget.doc_id).collection("Messages").get();

    await Future.forEach(MessagesCollection.docs, (MessgeDoc) async{
      if(MessgeDoc.data()['user']!=_auth.currentUser!.phoneNumber){
        await firestore.collection("Chats").doc(widget.doc_id).collection("Messages").doc(MessgeDoc.id).update({
          "status":"readed"
        });
      }
    });

  }

  FirebaseWebSocket(Switch){

    final MessagesRef = firestore.collection("Chats").doc(widget.doc_id).collection("Messages");

    if(Switch) { print("Слушаем стрим ");
      stream = MessagesRef.snapshots().listen((event) {print(event.docs.first.data().toString()); GetAllMessage();},
        onError: (error) {print("Listen failed: $error");},
      );
    } else { print("Не слушаем"); stream.cancel();}

  }


  void GetUserData() async{
    var data=await firestore.collection("UsersCollection").doc(widget.phone).get();
    print("data "+data.data().toString());
    setState(() {
      image_url=data.data()!['avatar_link'];
    });

  }

  @override
  void initState() {
    print("Телефон собеседника "+widget.phone);
    GetUserData();

    GetAllMessage();
    FirebaseWebSocket(true);
    AllReaded();

    // TODO: implement initState
    super.initState();
    // Future.delayed(Duration(seconds: 1)).then((value) => InitScroll());
  }


  void DeleteChatHistory() async{

    var result=await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.delete_chat_history),
        // title: Text("Delete chat history"),
        content: Text(AppLocalizations.of(context)!.are_you_sure_you_want_to_clear),
        // content: Text("Are you sure you want to clear the chat for both participants?"),
        // content: Text(AppLocalizations.of(context)!.this_will_delete_your_account_data),
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
      var chat_data = await firestore.collection("Chats").doc(widget.doc_id).collection("Messages").get();
      await Future.forEach(chat_data.docs, (chat_doc) async{
        await firestore.collection("Chats").doc(widget.doc_id).collection("Messages").doc(chat_doc.id).delete();
      });
      GetAllMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(236, 236, 242, 1),
      appBar: ChatAppBarPro(Context: context,title: widget.appbar,user_doc: widget.phone,clear_chat: DeleteChatHistory, image: image_url),
      body: ChatWidget(MessageController: MessageController,MessageNode: MessageNode, MessageList: MessageList,SendMessage: (value){
        SendMessage(value);
      },IsEventChat: false,),
    );
  }

  void dispose() {

    FirebaseWebSocket(false);
    super.dispose();
  }
}

class ChatWidget extends StatefulWidget {
  final MessageController;
  final MessageNode;
  final MessageList;
  final IsEventChat;
  Function(Map) SendMessage;

  ChatWidget({Key? key,required this.MessageController,required this.MessageNode,required this.MessageList,required this.SendMessage,required this.IsEventChat}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool image_load=false;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> stream;
  final ImagePicker _picker = ImagePicker();
  final storageRef = FirebaseStorage.instance.ref();
  late XFile? image;

  bool AwaitBool=false;
  var photoUrl="";
  String mPath="";
  final record = AudioRecorder();
  bool RebuildVar=false;
  bool AudioExit=false;
  bool AudioRecording=false;
  var downloadUrlVoice="";
  late Timer _timer;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      setState(() {

      });
      },
    );
  }





  void LoadPhotoFile() async{

    if(image_load&&image!=null){

      File(image!.path).delete();
      image = await _picker.pickImage(source: ImageSource.gallery);
      image_load=true;
      setState(() { });

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
            title: Text(AppLocalizations.of(context)!.access_to_your_photos),
            // title: Text("Access to your photos"),
            content: Text(AppLocalizations.of(context)!.unfortunately_you_have_blocked),
            // content: Text("Unfortunately, you have blocked the application from accessing photos. A photo is not required for the application to work, but if you change your mind, you need to go to settings and add it"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.stay),
                // child: Text("Stay"),

                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                child: Text(AppLocalizations.of(context)!.add),
                // child: Text("Add"),
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
  }

  Future<String> LoadPhoto() async{
    var Chat_Photo_Path="chat_photo/chat_"+DateTime.now().millisecondsSinceEpoch.toString()+".jpg";
    final photoRef = storageRef.child(Chat_Photo_Path); File file = File(image!.path);
    await photoRef.putFile(file); var DownloadUrl=await photoRef.getDownloadURL();

    return DownloadUrl;
  }

  SendMessage() async{



    if(image_load&&image!=null) {
      setState(() {
        AwaitBool=true;
      });

      photoUrl=await LoadPhoto();

      setState(() {
        AwaitBool=false;
      });
    }


    var Message=AudioExit ? {
      "img":"",
      "message":downloadUrlVoice,
      "time":DateTime.now().millisecondsSinceEpoch,
      "user":_auth.currentUser!.phoneNumber,
      "status":"sent"
    } : {
    "img":photoUrl,
    "message":widget.MessageController.text,
    "time":DateTime.now().millisecondsSinceEpoch,
    "user":_auth.currentUser!.phoneNumber,
    "status":"sent"
    };

    // if(AudioExit) {
    //   widget.MessageList.add(Message);
    // } else {
    //   widget.MessageList.add(Message);
    // }


    widget.MessageController.clear();
    widget.MessageNode.unfocus();
    widget.SendMessage(Message);

    if(image_load&&image!=null){
      photoUrl="";
      setState(() {
        image_load=false;
      });
    }

    setState(() {AudioExit=false;});
  }


  void Record() async{


    print("Start");
    if (await record.hasPermission()) {
      try {
        setState(() {
          AudioExit=false;
          AudioRecording=true;
        });
        startTimer();
        var tempDir = await getTemporaryDirectory();
        mPath = 'recoed.mp4';
        await record.start(const RecordConfig(), path: tempDir.path+'/myFile.m4a');
      } catch (e){
        UserMessage("Error "+e.toString(), context);
      }


    } else {
      UserMessage(AppLocalizations.of(context)!.you_have_blocked_the_application_from, context);
      await Permission.microphone.request();
    }

  }

  Future<void> stopRecorder() async {

    _timer.cancel();
    print("Finish");
    setState(() {
      AwaitBool=true;
      AudioExit=true;
      AudioRecording=false;
    });

    try {
      final voice_path = await record.stop();
      print("path " + voice_path.toString());

      if (voice_path != null) {
        var Voice_Storage_Path = "voice/voice_${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";
        final voiceRef = storageRef.child(Voice_Storage_Path);
        File file = File(voice_path);
        await voiceRef.putFile(file);
        downloadUrlVoice = await voiceRef.getDownloadURL();
        print("URL для загруженного аудио: $downloadUrlVoice");
      } else {
        UserMessage("Путь к аудио пуст. Не удалось остановить запись.", context);
      }
    } catch (e) {

      UserMessage("Error "+e.toString(), context);
      // UserMessage("Ошибка при остановке записи или загрузке", context);
      // Вы можете добавить дополнительные действия в случае ошибки, если это необходимо
    }

    setState(() {
      AwaitBool=false;
    });
  }


  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      final globalProvider = Provider.of<GlobalProvider>(context,listen: false);
      globalProvider.updateUncheckMessages(0);
    });

    return Stack(
      children: [
        InkWell(
            onTap: (){
              widget.MessageNode.hasFocus ? widget.MessageNode.unfocus() : null;
            },
            child: ListView(
                padding: EdgeInsets.all(16),
                reverse: true,
                shrinkWrap: true,
                children: [
                  SizedBox(height: 82,),
                  SizedBox(height: 16,),
                  for (final element in widget.MessageList.reversed)
                    if(element['user']==_auth.currentUser!.phoneNumber) ...[
                      element['message'].toString().startsWith("http") ?
                      Padding(
                        padding:  EdgeInsets.only(left: 124.0),
                        child: MyVoiceMessage(
                          // key: UniqueKey(),
                          // key: UniqueKey(),
                          // duration: Duration(seconds: 19),
                          audioSrc: element['message'],
                          played: true, // To sh
                          duration: null,
                          contactPlayIconColor: Colors.white,// ow played badge or not.
                          contactFgColor: Colors.black,
                          contactCircleColor: Colors.black54,
                          contactPlayIconBgColor: Colors.black54,
                          // duration: Duration(seconds: 3),
                          me: true, // Set message side.
                          onPlay: () {
                            print("sssssssssss");
                            setState(() {
                              RebuildVar=!RebuildVar;
                            });
                          }, // Do something when voice played.
                          meBgColor: PrimaryCol,
                        ),
                      ) :
                      MyMessage(element['img'], element['message'], element['time'])
                    ] else ...[
                      element['message'].toString().startsWith("http") ?
                      Padding(
                        padding: EdgeInsets.only(right: 124),
                        child: MyVoiceMessage(
                          // key: UniqueKey(),
                          // key: UniqueKey(),
                          // duration: Duration(seconds: 19),
                          audioSrc: element['message'],
                          played: true, // To sh
                          duration: null,
                          contactPlayIconColor: Colors.white,// ow played badge or not.
                          contactFgColor: Colors.black,
                          contactCircleColor: Colors.black54,
                          contactPlayIconBgColor: Colors.black54,
                          // duration: Duration(seconds: 3),
                          me: false, // Set message side.
                          onPlay: () {
                            print("sssssssssss");
                            setState(() {
                              RebuildVar=!RebuildVar;
                            });
                          }, // Do something when voice played.
                          meBgColor: PrimaryCol,
                        ),
                      ) :
                      OtherMessage(element['img'], element['message'], element['time']),
                    ],

                  if(widget.IsEventChat) ...[
                    SizedBox(height: 82,),
                  ]
                ]
            )
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              padding: EdgeInsets.only(bottom: widget.MessageNode.hasFocus ? 12 : 36 ,left: 12,right: 12,top: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06),spreadRadius: 20,blurRadius: 40)
                  ]
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if(!AudioExit)...[
                    if(image_load&&image!=null)...[
                      InkWell(
                        onTap: (){

                          setState(() {
                            image_load=false;
                          });

                        },
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: (image_load&&image!=null)?
                          BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.black,
                              image: DecorationImage(
                                  image:  FileImage(File(image!.path)),
                                  fit: BoxFit.cover,
                                  opacity: 0.95
                              )
                          ) :
                          BoxDecoration(
                              color: PrimaryCol,
                              borderRadius: BorderRadius.circular(4)
                          ),
                        ),
                      )
                    ] else ...[
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: SvgPicture.asset("lib/assets/Icons/Bold/Image.svg",color: Colors.black,width: 28,),
                        ),
                        onTap: (){
                          LoadPhotoFile();

                          // setState(() {image_load=true;});
                        },
                      ),
                    ],
                  ],

                  if(AudioExit)...[

                    Expanded(
                        child: Container(
                            height: 48,
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color.fromRGBO(239, 239, 255, 1),
                            ),
                            margin: EdgeInsets.only(left: 4,right: 4),
                            child: ContactNoise()
                        )
                    ),
                    IconButton(
                        onPressed: (){
                          setState(() {
                            AudioExit=false;
                          });
                        },
                        icon: Icon(Icons.close,size: 36,)
                    ),
                    SizedBox(width: 8,),
                  ] else ...[
                    SizedBox(width: 12,),
                    MessageFieldPro(context: context,controller: widget.MessageController,node: widget.MessageNode,hint: AppLocalizations.of(context)!.text_here,space_left: image_load ? 48 : 28,onFieldSubmitted: () async{
                      if(!AwaitBool) {
                        if(widget.MessageController.text.length==0){
                          if(!AudioExit||AudioRecording){
                            await record.isRecording() ? stopRecorder() : Record();
                          } else {
                            SendMessage();
                          }

                        } else {
                          SendMessage();
                        }
                      }
                    },onChanged:(){setState(() {});}),
                    SizedBox(width: 12,),
                  ],
                  InkWell(
                    onTap: () async {

                      if(!AwaitBool) { // Ждем загрузки?

                        if(widget.MessageController.text.length==0&&!image_load){ // Нет текста?
                          if(!AudioExit||AudioRecording){
                            await record.isRecording() ? stopRecorder() : Record();
                          } else {
                            SendMessage();
                          }

                        } else {
                          SendMessage();
                        }
                      }

                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: AwaitBool ? 16.0 : AudioRecording ? 14.0 : 10.0),
                      child: AwaitBool ? CupertinoActivityIndicator(color: Colors.black,) :
                      widget.MessageController.text.length==0&&!image_load ?
                      AudioRecording ? Icon(CupertinoIcons.stop_fill,color: DateTime.now().second.isEven ? Colors.red : Colors.black,) :
                      (!AudioExit ? SvgPicture.asset("lib/assets/Icons/Bold/Voice.svg",color: Colors.black,width: 28,) : SvgPicture.asset("lib/assets/Icons/Bold/Send.svg",color: Colors.black,width: 28,)) :
                      // SvgPicture.asset("lib/assets/Icons/Bold/Voice.svg",color: Colors.black,width: 28,) :
                      SvgPicture.asset("lib/assets/Icons/Bold/Send.svg",color: Colors.black,width: 28,),
                    ),
                  ),
                ],
              )
          ),
        )
      ],
    );
  }


}


