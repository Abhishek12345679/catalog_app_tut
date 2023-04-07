import 'dart:developer' show log;

import 'package:catalog_app_tut/enums/popup_list_option.dart';
import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:catalog_app_tut/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class MainNotesView extends StatefulWidget {
  const MainNotesView({super.key});

  @override
  State<MainNotesView> createState() => _MainNotesViewState();
}

class _MainNotesViewState extends State<MainNotesView> {
  late final NotesService _notesService;
  PopupListOption? selectedMenu;

  String get userEmail => AuthService.firebase().currentUser!.email!;

  // lifecycle events
  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text("waiting for notes ");
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
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
                log('User with email $userEmail logged out!');
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
