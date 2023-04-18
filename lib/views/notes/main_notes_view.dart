import 'dart:developer' show log;
import 'package:catalog_app_tut/enums/popup_list_option.dart';
import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:catalog_app_tut/services/auth/auth_user.dart';
import 'package:catalog_app_tut/services/auth/bloc/auth_bloc.dart';
import 'package:catalog_app_tut/services/auth/bloc/event/auth_event.dart';
import 'package:catalog_app_tut/services/cloud/cloud_note.dart';
import 'package:catalog_app_tut/services/cloud/firestore_service.dart';
import 'package:catalog_app_tut/utilities/dialog/logout_dialog.dart';
import 'package:catalog_app_tut/views/notes/create_update_note_view.dart';
import 'package:catalog_app_tut/views/notes/notes_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNotesView extends StatefulWidget {
  const MainNotesView({super.key});

  @override
  State<MainNotesView> createState() => _MainNotesViewState();
}

class _MainNotesViewState extends State<MainNotesView> {
  late final FirestoreService _notesService;
  PopupListOption? selectedMenu;

  AuthUser get currentUser => AuthService.firebase().currentUser!;

  // lifecycle events
  @override
  void initState() {
    _notesService = FirestoreService();
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
                  builder: (context) => const CreateUpdateNoteView(),
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
                      if (context.mounted) {
                        context.read<AuthBloc>().add(const AuthEventLogout());
                      }
                    }
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
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: currentUser.id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.id);
                  },
                  onTapNote: (note) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateUpdateNoteView(),
                        settings: RouteSettings(
                          arguments: note,
                        ),
                      ),
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
      ),
    );
  }
}
