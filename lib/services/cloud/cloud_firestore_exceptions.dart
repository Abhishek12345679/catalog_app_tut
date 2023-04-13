//NOTE: @immutable is used with data classes

// super exception
class CloudStorageException implements Exception {
  const CloudStorageException();
}

// sub exceptions
class CouldNotCreateNoteException implements CloudStorageException {}

class CouldNotGetAllNotesException implements CloudStorageException {}

class CouldNotUpdateNoteException implements CloudStorageException {}

class CouldNotDeleteNoteException implements CloudStorageException {}
