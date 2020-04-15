import 'dart:io';
import 'package:chat/ChatMessage.dart';
import 'package:chat/Text_Compose.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  void _sendMessage({String text, File file}) async {

    if (_currentUser == null)
    {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possível efetuar o login na sua conta Google, tente novamente."),
          backgroundColor: Colors.red,
        )
      );
    }
    else {
      Map<String, dynamic> data = {
        "uid": _currentUser.uid,
        "senderName": _currentUser.displayName,
        "senderPhotoUrl": _currentUser.photoUrl,
        "time": Timestamp.now()
      };

      if (file != null) {

        setState(() {
          _isLoading = true;
        });

        bool compress = false;

        print('localizou o arquivo: ' + file.length().toString());

        try {
          File compressedFile = await FlutterNativeImage.compressImage(
              file.path,
              quality: 70, percentage: 70);

          compress = true;
          file = compressedFile;
          print('comprimiu o arquivo: ' + file.length().toString());
        }
        catch(error)
        {
          compress = false;
          data["errorcompress"] = error.toString();
        }
        data['compress'] = compress;

        StorageUploadTask task =
        FirebaseStorage.instance.ref()
            .child('chatfiles')
            .child(_currentUser.uid)
            .child(DateTime.now().millisecondsSinceEpoch
            .toString())
            .putFile(file);

        print('abrindo o storage');

        StorageTaskSnapshot tasksnapshot = await task.onComplete;
        String url = await tasksnapshot.ref.getDownloadURL();

        print('enviado para o storage');

        data["imgUrl"] = url;

        setState(() {
          _isLoading = false;
        });

        print('terminou');
      }
      else
        data["imgUrl"] = "";

      if (text != null && text.isNotEmpty)
        data["text"] = text;
      else
        data["text"] = "";

      Firestore.instance.collection("messages").add(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
            _currentUser != null ? 'Olá, ${_currentUser.displayName}' : 'Efetue o login...'
        ),
        elevation: 0,
        actions: [
          _currentUser != null ?
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: (){
                  FirebaseAuth.instance.signOut();
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(content: Text("Você saiu com sucesso"))
                  );
                  Navigator.pop(context);
                },
              ) :
              Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('messages').orderBy('time').snapshots(),
              builder: (context, snapshot){
                switch(snapshot.connectionState)
                {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =  snapshot.data.documents.reversed.toList();

                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index){
                        return ChatMessage(documents[index].data, documents[index].data['uid'] == (_currentUser != null ? _currentUser.uid : documents[index].data['uid']));
                      }
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      )
    );
  }
}
