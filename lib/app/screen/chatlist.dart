import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  String _name = '익명의 채팅방';
  ChatList(String name) {
    _name = name;
  }
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방 목록'),
      ),
    );
  }
}
