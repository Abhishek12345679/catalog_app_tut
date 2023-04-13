import 'package:catalog_app_tut/services/cloud/cloud_firestore_constants.dart';
import 'package:catalog_app_tut/services/cloud/cloud_firestore_exceptions.dart';
import 'package:catalog_app_tut/services/cloud/cloud_note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<Iterable<CloudNote>> getNotes({required int ownerUserId}) async {
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
                return CloudNote.fromSnapshot(doc);
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  void createNewNote({
    required int ownerUserId,
    // required String text,
  }) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });
  }

  // start: pattern for using a singleton in dart
  static final FirestoreService _shared = FirestoreService._sharedInstance();
  FirestoreService._sharedInstance();
  factory FirestoreService() => _shared;
  // end: pattern for using a singleton in dart
}
