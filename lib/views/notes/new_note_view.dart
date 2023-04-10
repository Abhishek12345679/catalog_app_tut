import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:catalog_app_tut/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _newNoteTEController;

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final email = AuthService.firebase().currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
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
        title: const Text('Add New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data;
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
