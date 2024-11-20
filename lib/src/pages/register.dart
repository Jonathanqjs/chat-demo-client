import 'package:flutter/material.dart';
import 'package:mychat/src/utils/request.dart';

typedef RegisterPageState = _RegisterPageState;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const routeName = '/register';
  @override
  RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('注册'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '用户名'),
                onSaved: (value) {
                  _username = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '密码'),
                obscureText: true,
                onSaved: (value) {
                  _password = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return '请输入密码';
                  }
                  if(value.length < 6) {
                    return '密码长度不能小于6位';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final response = await Request()
                        .register(username: _username, password: _password);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.data['message'])),
                      );
                      if (response.data['code'] == 200) {
                        Navigator.pop(context);
                      }
                    }
                  }
                },
                child: Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
