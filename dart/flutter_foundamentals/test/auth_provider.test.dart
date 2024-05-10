import "dart:async";

import "package:flutter_foundamentals/services/auth/auth_exception.dart";
import "package:flutter_foundamentals/services/auth/auth_provider.dart";
import "package:flutter_foundamentals/services/auth/auth_user.dart";
import "package:test/test.dart";

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();

    test('Should not be initialized when starting', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log-out if provider is not initialized', () async {
      provider._isInitialized = false;
      expect(
          provider.logOut(),
          // throwsA(const TypeMatcher<UserNotFoundException>()));
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test("Should be able to be initialized", () async {
      await provider.initializeApp();
      expect(provider.isInitialized, true);
    });

    test("Should be able to initialized in less than 2 seconds", () async {
      await provider.initializeApp();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
  });

  group("logIn()", () {
    final provider = MockAuthProvider();
    test("should launch error on invalid cases", () async {
      provider._isInitialized = true;
      expect(
          () async =>
              await provider.logIn(email: "foo@bar.com", password: "password"),
          throwsA(const TypeMatcher<UserNotFoundException>()));

      expect(
          () async =>
              await provider.logIn(email: "nofoo@bar.com", password: "foobar"),
          throwsA(isA<InvalidCredentialsException>()));
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _authUser;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _authUser;

  @override
  Future<void> initializeApp() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    if (email == "foo@bar.com") {
      throw UserNotFoundException();
    }
    if (password == "foobar") {
      throw InvalidCredentialsException();
    }

    _authUser = const AuthUser(
        isEmailVerified: false, email: "test@gmail.com", id: "1");
    return Future.value(_authUser);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    if (_authUser == null) {
      throw UserNotFoundException();
    }
    await Future.delayed(const Duration(seconds: 1));
    _authUser = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    if (_authUser == null) {
      throw UserNotFoundException();
    }
    const newUser =
        AuthUser(isEmailVerified: true, email: "test@gmail.com", id: "2");
    _authUser = newUser;
  }
  
  @override
  Future<void> resetPassword({required String email}) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }
}
