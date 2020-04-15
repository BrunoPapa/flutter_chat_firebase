import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage);
  final Function({String text, File file}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  bool _isComposing = false;
  TextEditingController _controller = TextEditingController();

  void sendMessage({String text, File file}){
    widget.sendMessage(text: text, file: file);
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  _selectImage()
  {
    File _selFile;
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(5.0),
                    color: Colors.white,
                    child: Icon(Icons.photo_camera, size: 80.0),
                  ),
                  onTap: () async {
                    _selFile = await ImagePicker.pickImage(source: ImageSource.camera);

                    print("file: $_selFile");
                    if (_selFile == null) return;
                    else
                      sendMessage(file: _selFile, text: _controller.text);

                    Navigator.pop(context);
                  },
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(5.0),
                    color: Colors.white,
                    child: Icon(Icons.photo_album, size: 80.0),
                  ),
                  onTap: () async {
                    _selFile = await ImagePicker.pickImage(source: ImageSource.gallery);

                    print("file: $_selFile");
                    if (_selFile == null) return;
                    else
                      sendMessage(file: _selFile);

                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () {
              _selectImage();
            },
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: "Envie uma mensagem..."),
              controller: _controller,
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                sendMessage(text: text);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing ? (){
              sendMessage(text: _controller.text);
            } : null,
          )
        ]
      ),
    );
  }
}
