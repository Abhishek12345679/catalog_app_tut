// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:catalog_app_tut/services/cloud/cloud_firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class CloudNote {
  final int ownerUserId;
  final String id;
  final String text;

  const CloudNote({
    required this.ownerUserId,
    required this.id,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName];

  @override
  String toString() => 'Note,id: $id, userId:$ownerUserId, note:$text';

  @override
  bool operator ==(covariant CloudNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
