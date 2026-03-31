enum UserRole { employee, party }

class UserModel {
  final String id;
  final String username;
  final UserRole role;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
  });
}
