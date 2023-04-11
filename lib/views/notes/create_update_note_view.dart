import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:catalog_app_tut/services/crud/notes_service.dart';
import 'package:catalog_app_tut/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _newNoteTEController;

  bool isNewNote(BuildContext context) {
    final widgetNote = context.getArguments<DatabaseNote>();
    return widgetNote != null ? false : true;
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArguments<DatabaseNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _newNoteTEController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;

    if (existingNote != null) {
      return existingNote;
    }
    final email = AuthService.firebase().currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _setupTextControllerListener() {
    _newNoteTEController.removeListener(_textControllerListener);
    _newNoteTEController.addListener(_textControllerListener);
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _newNoteTEController.text;

    await _notesService.updateNote(
      databaseNote: note,
      newText: text,
    );
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_newNoteTEController.text.isEmpty && note != null) {
      _notesService.deleteNote(noteId: note.id);
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final newText = _newNoteTEController.text;
    if (newText.isNotEmpty && note != null) {
      await _notesService.updateNote(
        databaseNote: note,
        newText: newText,
      );
    }
  }

  @override
  void initState() {
    _notesService = NotesService();
    _newNoteTEController = TextEditingController();
    super.initState();
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
        title:
            Text(isNewNote(context) ? 'Add New Note' : 'Update Existing Note'),
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
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
