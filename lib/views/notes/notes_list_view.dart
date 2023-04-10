import 'package:catalog_app_tut/services/crud/notes_service.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final DeleteNoteCallback onDeleteNote;
  final List<DatabaseNote> notesList;

  const NotesListView({
    super.key,
    required this.notesList,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notesList.length,
      itemBuilder: (context, index) {
        final currentNote = notesList[index];
        return ListTile(
          title: Text(
            currentNote.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              final shouldDelete = await showDeleteNoteDialog(context);
              if (shouldDelete) {
                // onDeleteNote(currentNote);
              }
            },
          ),
        );
      },
    );
  }
}

showDeleteNoteDialog(BuildContext context) {}