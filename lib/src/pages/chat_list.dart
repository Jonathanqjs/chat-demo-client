import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mychat/src/entities/index.dart';
import 'package:mychat/src/utils/websocket.dart';

typedef ChatListViewState = _ChatListViewState;

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  static const routeName = '/chatlist';

  @override
  ChatListViewState createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  late UserEntity _friend = UserEntity();
  final List<MessageEntity> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);

    SocketService().listen('receiveMessage', (data) {
      // print('Received message: $data');
      if (mounted) {
        setState(() {
          _controller.clear();
          if (data['code'] == 200) {
            final message = MessageEntity.fromJson(data['data']);
            if (message.senderId == _friend.userId ||
                message.receiverId == _friend.userId) {
              _messages.add(message);
            }
          }
        });
      }
    });
  }

  void _init(_) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      _messages.addAll(args['messages'].map<MessageEntity>((json) {
        return MessageEntity.fromJson(json);
      }));
      _friend = UserEntity.fromJson(args['friend']);
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      SocketService().send('sendMessage', {
        'receiverId': _friend.userId,
        'content': _controller.text,
      });
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  Widget renderMessage(MessageEntity message, int index) {
    final received = message.senderId == _friend.userId;
    return ListTile(
      title: Align(
        alignment: received ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: received ? Colors.black54 : Colors.blue,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            _messages[index].content,
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
        title: const Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return renderMessage(_messages[index], index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                      border: OutlineInputBorder(),
                    ),
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
