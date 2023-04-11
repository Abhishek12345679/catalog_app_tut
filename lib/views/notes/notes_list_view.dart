import 'package:catalog_app_tut/services/crud/notes_service.dart';
import 'package:catalog_app_tut/utilities/dialog/delete_note_dialog.dart';
import 'package:flutter/material.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final NoteCallback onDeleteNote;
  final NoteCallback onTapNote;
  final List<DatabaseNote> notesList;

  const NotesListView({
    super.key,
    required this.notesList,
    required this.onDeleteNote,
    required this.onTapNote,
  });

  @override
  Widget build(BuildContext context) {
    if (notesList.isEmpty) {
      return const Center(child: Text("Nothing to see here :>"));
    }
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
          onTap: () {
            onTapNote(currentNote);
          },
          trailing: IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              final shouldDelete = await showDeleteNoteDialog(context);
              if (shouldDelete) {
                onDeleteNote(currentNote);
              }
            },
          ),
        );
      },
    );
  }
}
