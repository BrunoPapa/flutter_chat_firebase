import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data, this.mine);

  final bool mine;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !mine ?
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['senderPhotoUrl']),
            )
          ) : Container(),
          Expanded(
           child: Column(
            crossAxisAlignment: !mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              (data['imgUrl'] != null && data['imgUrl'] != "") ?
              Image.network(data['imgUrl'], width: 250,) : Container(),
              (data['text'] != null && data['text'] != "") ?
              Text(
                  data['text'],
                  textAlign: !mine ? TextAlign.start : TextAlign.end,
                  style: TextStyle(fontSize: 15),
              ) : Container(),
              Text(
                data["senderName"],
                textAlign: !mine ? TextAlign.start : TextAlign.end,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
           ),
          ),
          mine ?
          Padding(
              padding: EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data['senderPhotoUrl']),
              )
          ) : Container()
        ],
      ),
    );
  }
}
