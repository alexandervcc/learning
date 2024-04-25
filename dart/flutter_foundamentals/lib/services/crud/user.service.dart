import "package:flutter/foundation.dart";
import "package:flutter_foundamentals/services/auth/auth_exception.dart";
import "package:flutter_foundamentals/services/crud/db.service.dart";
import "package:flutter_foundamentals/services/crud/exceptions.dart";

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[columnId] as int,
        email = map[columnEmail] as String;

  @override
  String toString() => "Person, ID = $id, email = $email";

  @override
  bool operator ==(covariant DatabaseUser other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class UserService extends DatabaseConnectionService {
  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    DatabaseUser user;
    try {
      user = await getUser(email: email);
    } on UserNotFoundException catch (_) {
      user = await createUser(email: email);
    } catch (e) {
      rethrow;
    }
    return user;
  }

  Future<void> deleteUser({required String email}) async {
    final db = getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: "email = ? ",
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw UserCannotBeDeletedException();
    }
  }

  Future<DatabaseUser> createUser({
    required String email,
  }) async {
    final db = getDatabaseOrThrow();
    final foundUser = await db.query(userTable,
        limit: 1, where: "email = ?", whereArgs: [email.toString()]);
    if (foundUser.isNotEmpty) {
      throw EmailInUseException();
    }
    final userId = await db.insert(userTable, {columnEmail: email});

    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({
    required String email,
  }) async {
    final db = getDatabaseOrThrow();
    final foundUser = await db.query(userTable,
        limit: 1, where: "email = ?", whereArgs: [email.toString()]);
    if (foundUser.isEmpty) {
      throw UserNotFoundException();
    }
    return DatabaseUser.fromRow(foundUser.first);
  }
}

const columnId = "id";
const columnEmail = "email";
