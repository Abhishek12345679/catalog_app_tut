//login
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

//registration
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class GenericAuthException implements Exception {}

class UserNotLoggedInException implements Exception {}
