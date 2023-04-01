import 'dart:developer' show log;

import 'package:catalog_app_tut/enums/popup_list_option.dart';
import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class MainNotesView extends StatefulWidget {
  final String? email;

  const MainNotesView({super.key, required this.email});

  @override
  State<MainNotesView> createState() => _MainNotesViewState();
}

class _MainNotesViewState extends State<MainNotesView> {
  PopupListOption? selectedMenu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          PopupMenuButton<PopupListOption>(
            initialValue: selectedMenu,
            onSelected: (item) async {
              switch (item) {
                case PopupListOption.logout:
                  await showLogoutDialog(context);
                  break;
              }
              setState(() {
                selectedMenu = item;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem<PopupListOption>(
                value: PopupListOption.logout,
                child: Text("Logout"),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Center(child: Text('Logged in as ${widget.email}')),
        ],
      ),
    );
  }

  Future<bool> showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure? You want to log out.'),
          actions: [
            IconButton(
              onPressed: () async {
                Navigator.pop(context);
                await AuthService.firebase().logOut();
                log('User with email ${widget.email} logged out!');
              },
              icon: const Text('Yes'),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Text('No'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
