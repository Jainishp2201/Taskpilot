import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    bool success = false;
    if (role == UserRole.employee && username == "emp1" && password == "1234") {
      _user = UserModel(id: "1", username: username, role: role);
      success = true;
    } else if (role == UserRole.party && username == "party1" && password == "1234") {
      _user = UserModel(id: "2", username: username, role: role);
      success = true;
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
