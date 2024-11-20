import 'package:flutter/material.dart';
import 'package:mychat/src/pages/chat_list.dart';
import 'package:mychat/src/pages/friends_list.dart';
import 'package:mychat/src/pages/login.dart';
import 'package:mychat/src/pages/register.dart';
import 'package:mychat/src/settings/settings_controller.dart';

RouteFactory router(SettingsController settingsController) {
  return (RouteSettings routeSettings)=>MaterialPageRoute<void>(
    settings: routeSettings,
    builder: (BuildContext context) {
      switch (routeSettings.name) {
        // case SettingsView.routeName:
        //   return SettingsView(controller: settingsController);
        case ChatListView.routeName:
          return const ChatListView();
        case FriendsListView.routeName:
          return const FriendsListView();
        case RegisterPage.routeName:
          return const RegisterPage();
        case LoginPage.routeName:
        default:
          return const LoginPage();
      }
    },
  );
}
