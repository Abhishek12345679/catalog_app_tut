import 'package:catalog_app_tut/services/cloud/cloud_firestore_constants.dart';
import 'package:catalog_app_tut/services/cloud/cloud_firestore_exceptions.dart';
import 'package:catalog_app_tut/services/cloud/cloud_note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    // notes.snapshots() is a stream of QuerySnapshot
    return notes.snapshots().map((event) => event.docs.map((doc) {
          final note = CloudNote.fromSnapshot(doc);
          return note;
        }).where((note) => note.ownerUserId == ownerUserId));
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({
        textFieldName: text,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) {
                return CloudNote.fromSnapshot(
                  doc,
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote({
    required String ownerUserId,
    // required String text,
  }) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });
    final fetchedNote = await document.get();
    return CloudNote(
      ownerUserId: ownerUserId,
      id: fetchedNote.id,
      text: "",
    );
  }

  // start: pattern for using a singleton in dart
  static final FirestoreService _shared = FirestoreService._sharedInstance();
  FirestoreService._sharedInstance();
  factory FirestoreService() => _shared;
  // end: pattern for using a singleton in dart
}
