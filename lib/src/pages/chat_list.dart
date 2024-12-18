import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mychat/src/entities/index.dart';
import 'package:mychat/src/utils/request.dart';
import 'package:mychat/src/utils/websocket.dart';
import 'package:path_provider/path_provider.dart';

typedef ChatListViewState = _ChatListViewState;

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  static const routeName = '/chatlist';

  @override
  ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  late UserEntity _friend = UserEntity();
  late Directory _temporaryDirectory;
  final List<MessageEntity> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(_init);
    SocketService().listen('receiveMessage', receiveMessage);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void receiveMessage(result) {
    if (mounted && result['code'] == 200) {
      setState(() {
        final message = MessageEntity.fromJson(result['data']);
        if (message.senderId == _friend.userId ||
            message.receiverId == _friend.userId) {
          _messages.add(message);
        }
      });
      _scrollToBottom()
      ;
    }
  }

  void _init(_) async {
    _temporaryDirectory = await getTemporaryDirectory();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      _messages.addAll(args['messages'].map<MessageEntity>((json) {
        return MessageEntity.fromJson(json);
      }));
      _friend = UserEntity.fromJson(args['friend']);
    });
    
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      SocketService().send('sendMessage', {
        'receiverId': _friend.userId,
        'content': _controller.text,
      });
      _controller.clear();
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await Request().sendImage(receiverId: _friend.userId, image: pickedFile);
    }
  }

  Future<File?> getImageToFile(String fileName) async {
    final path = '${_temporaryDirectory.path}/$fileName';
    final file = File(path);
    if (!file.existsSync()) {
      final res = await Request().getImage(fileName: fileName);
      if (res.statusCode == 200) {
        await file.writeAsBytes(res.data!);
      }
    }
    return file;
  }

  Widget renderMessage(MessageEntity message, int index) {
    final received = message.senderId == _friend.userId;
    final isMedia = message.mediaUrl.isNotEmpty;
    return ListTile(
      title: Align(
        alignment: received ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isMedia
                ? Colors.transparent
                : received
                    ? Colors.black54
                    : Colors.blue,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: isMedia
              ? FutureBuilder<File?>(
                  future: getImageToFile(message.mediaUrl),
                  builder: (context, snapshot) {
                    double width = 200;
                    double height = 200;
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return Image.file(
                          snapshot.data!,
                          width: width,
                          height: height,
                        );
                      } else if (snapshot.hasError) {
                        return Image.network(
                          'https://q4.itc.cn/images01/20240705/e1b935ff26614781bb135e467f266f42.jpeg',
                          width: width,
                          height: height,
                        );
                      }
                    }
                    return Container(
                      width: width,
                      height: height,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  },
                )
              : Text(
                  message.content,
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_friend.userName),
        centerTitle: true
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse:true,
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return renderMessage(_messages[_messages.length - 1 - index], index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                        // hintText: 'Enter message',
                        border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                    onPressed: _selectImage, icon: const Icon(Icons.photo)),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
