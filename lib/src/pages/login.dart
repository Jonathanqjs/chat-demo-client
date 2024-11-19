import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mychat/src/entities/index.dart';
import 'package:mychat/src/pages/friends_list.dart';

import 'package:mychat/src/utils/request.dart';
import 'package:mychat/src/utils/state.dart';
import 'package:provider/provider.dart';

typedef LoginPageState = _LoginPageState;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const routeName = '/login';
  @override
  LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      // Show error message if username or password is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    final response = await Request().login(username: username, password: password);
    if (!mounted) return; 
    if (response.data['code']==200) {
      // final Map<String, dynamic> responseData = jsonDecode(response.body);
      UserEntity user =UserEntity.fromJson(response.data['data']);
      Provider.of<GlobalState>(context, listen: false).updateUser(user);
      Navigator.pushReplacementNamed(context, FriendsListView.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        automaticallyImplyLeading:false
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: 200.0,
              child: ElevatedButton(
                onPressed: _login,
                child: const Text('登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
