import 'dart:developer' show log;

import 'package:catalog_app_tut/enums/popup_list_option.dart';
import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:catalog_app_tut/services/crud/notes_service.dart';
import 'package:catalog_app_tut/utilities/dialog/logout_dialog.dart';
import 'package:catalog_app_tut/views/notes/new_note_view.dart';
import 'package:catalog_app_tut/views/notes/notes_list_view.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewNoteView(),
                ),
              );
            },
          ),
          PopupMenuButton<PopupListOption>(
            initialValue: selectedMenu,
            onSelected: (item) async {
              switch (item) {
                case PopupListOption.logout:
                  try {
                    final shouldLogout = await showLogoutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logOut();
                      log('User with email $userEmail logged out!');
                    }
                    log('logout cancelled XX');
                  } catch (e) {
                    log('error: $e');
                  }
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
          ),
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
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notesList: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(
                              noteId: note.id,
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
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
}
