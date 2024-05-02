// db
class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumensDirectoryException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

// user
class UserCannotBeDeletedException implements Exception {}

// notes
class CouldNotUpdateNoteException implements Exception {}

class CouldNotDeleteNoteException implements Exception {}

class CouldNotFindNoteException implements Exception {}

class UserShouldBeSetBeforeReadingNotesException implements Exception {}
