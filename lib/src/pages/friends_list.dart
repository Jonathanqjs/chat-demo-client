import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mychat/src/pages/chat_list.dart';
import 'package:mychat/src/pages/login.dart';
import 'package:mychat/src/utils/request.dart';
import 'package:mychat/src/utils/state.dart';
import 'package:mychat/src/utils/websocket.dart';
import 'package:provider/provider.dart';

import '../entities/index.dart';

typedef FriendsListViewState = _FriendsListViewState;

class FriendsListView extends StatefulWidget {
  const FriendsListView({super.key});

  static const routeName = '/friendslist';

  @override
  FriendsListViewState createState() => _FriendsListViewState();
}

/// Displays a list of SampleItems.
class _FriendsListViewState extends State<FriendsListView> {
  final List<UserEntity> friendsList = [];
  final List<MessageEntity> messageList = [];
  final TextEditingController _friendName = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _fetchData();
    _connectSocketService();
  }

  @override
  void dispose() {
    SocketService().close();
    super.dispose();
  }

  void _connectSocketService() async {
    final token = await Request().getToken();

    SocketService().connect(params: {
      'token': token ?? '',
    });

    SocketService().listen('connectionSuccess', (data) {
      setState(() {
        if (data['code'] == 200) {
          messageList.addAll(
            (data['data'] as List)
                .map((json) => MessageEntity.fromJson(json))
                .toList(),
          );
        }
      });
    });

    SocketService().listen('receiveMessage', (data) {
      // print('Received message: $data');
      if (mounted) {
        setState(() {
          if (data['code'] == 200) {
            messageList.add(MessageEntity.fromJson(data['data']));
          }
        });
      }
    });

    SocketService().listen('addFriend', (data) {
      // print('Send message: $data');
      if (mounted) {
        setState(() {
          if (data['code'] == 200) {
            friendsList.add(UserEntity.fromJson(data['data']['applicant']));
          }
        });
      }
    });
  }

  Future<void> _fetchData() async {
    // 使用 userInfo 进行网络请求
    final response = await Request().fetchFriendList();
    if (!mounted) return;
    if (response.data['code'] == 200) {
      setState(() {
        friendsList.addAll(
          (response.data['data'] as List)
              .map((json) => UserEntity.fromJson(json))
              .toList(),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.data['message'])),
      );
    }
  }

  void _showAddContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '添加好友',
            style: TextStyle(fontSize: 20),
          ),
          content: TextField(
            controller: _friendName,
            decoration: const InputDecoration(
              labelText: '用户名',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('确认'),
              onPressed: () async {
                // Handle the add contacts action
                Navigator.of(context).pop();
                final result =
                    await Request().addFriend(friendName: _friendName.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'])),
                );
                if (result['code'] == 200) {
                  setState(() {
                    friendsList
                        .add(UserEntity.fromJson(result['data']['receiver']));
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('好友'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) async {
              if (value == 'add_contacts') {
                _showAddContactsDialog(context);
              } else if (value == 'logout') {
                final response = await Request().logout();
                if(response.data['code'] == 200 && mounted) {
                  Provider.of<GlobalState>(context, listen: false).updateUser(null);
                  Navigator.pushReplacementNamed(context, LoginPage.routeName);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'add_contacts',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [Icon(Icons.add), Text('添加好友')],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [Icon(Icons.logout), Text('注销')],
                  ),
                )
              ];
            },
          )
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: friendsList.length,
        itemBuilder: (BuildContext context, int index) {
          final friend = friendsList[index];
          final user = Provider.of<GlobalState>(context).user;
          final messages = messageList.where((el) {
            return el.senderId == friend.userId ||
                el.receiverId == friend.userId;
          }).toList()
            ..sort(
              (a, b) => a.createDate.compareTo(b.createDate),
            );

          return Container(
              decoration: const BoxDecoration(
                border: Border(
                  // top: BorderSide(width: 1.0, color: Colors.grey),
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              child: ListTile(
                  title: Text(friend.userName),
                  subtitle: Text(messages.isNotEmpty
                      ? messages.last.content
                      : 'No messages'),
                  trailing: const Icon(Icons.chevron_right),
                  leading: const CircleAvatar(
                    // Display the Flutter Logo image asset.
                    foregroundImage:
                        AssetImage('assets/images/flutter_logo.png'),
                  ),
                  onTap: () {
                    Navigator.restorablePushNamed(
                      context,
                      ChatListView.routeName,
                      arguments: {
                        'messages':
                            messages.map((msg) => msg.toJson()).toList(),
                        'friend': friend.toJson(),
                      },
                    );
                  }));
        },
      ),
    );
  }
}
