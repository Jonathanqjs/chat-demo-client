import 'package:flutter/foundation.dart';
import 'package:mychat/src/entities/index.dart';

class GlobalState with ChangeNotifier {
  UserEntity? _user = UserEntity();
  UserEntity? get user => _user;

  

  void updateUser(UserEntity? user) {
    _user = user;
    notifyListeners();
  }
}