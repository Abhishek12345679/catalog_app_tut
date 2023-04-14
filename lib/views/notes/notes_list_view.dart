import 'package:catalog_app_tut/services/cloud/cloud_note.dart';
import 'package:catalog_app_tut/utilities/dialog/delete_note_dialog.dart';
import 'package:flutter/material.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final NoteCallback onDeleteNote;
  final NoteCallback onTapNote;
  final Iterable<CloudNote> notes;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTapNote,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(child: Text("Nothing to see here :>"));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final currentNote = notes.elementAt(index);
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
