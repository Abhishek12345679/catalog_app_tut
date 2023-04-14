import 'dart:developer';

import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:catalog_app_tut/services/cloud/cloud_note.dart';
import 'package:catalog_app_tut/services/cloud/firestore_service.dart';
import 'package:catalog_app_tut/utilities/dialog/empty_note_dialog.dart';
import 'package:catalog_app_tut/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirestoreService _notesService;
  late final TextEditingController _newNoteTEController;

  @override
  void initState() {
    _notesService = FirestoreService();
    _newNoteTEController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _newNoteTEController.text;

    await _notesService.updateNote(
      documentId: note.id,
      text: text,
    );
  }

  bool isNewNote(BuildContext context) {
    final widgetNote = context.getArguments<CloudNote>();
    return widgetNote != null ? false : true;
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArguments<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _newNoteTEController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(
      ownerUserId: userId,
    );

    _note = newNote;
    return newNote;
  }

  void _setupTextControllerListener() {
    _newNoteTEController.removeListener(_textControllerListener);
    _newNoteTEController.addListener(_textControllerListener);
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_newNoteTEController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.id);
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final newText = _newNoteTEController.text;
    if (newText.isNotEmpty && note != null) {
      await _notesService.updateNote(
        documentId: note.id,
        text: newText,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _newNoteTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewNote(context) ? 'Add New Note' : 'Update Existing Note',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _newNoteTEController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              }
              await Share.share(text);
            },
            icon: const Icon(Icons.ios_share),
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter the new note here ...',
                  ),
                  keyboardType: TextInputType.multiline,
                  autofocus: true,
                  controller: _newNoteTEController,
                  maxLines: null,
                ),
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
