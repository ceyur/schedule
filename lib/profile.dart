import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:schedule/data.dart";
import "package:schedule/select.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isFormLoading = false;

  String? _userName;
  String? _userAvatar;
  String? _userPhone;
  String? _userBirthDate;
  String? _userEmail;

  // ИЗМЕНЕНО: _emailController переименован в _loginController для поддержки телефона
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isRegistering = false;

  // Контроллеры для формы редактирования
  final _editNameController = TextEditingController();
  final _editPhoneController = TextEditingController();
  final _editEmailController = TextEditingController();
  final _editDobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _loginController.dispose(); // ИЗМЕНЕНО
    _passwordController.dispose();
    _nameController.dispose();
    _editNameController.dispose();
    _editPhoneController.dispose();
    _editEmailController.dispose();
    _editDobController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      setState(() => _isLoggedIn = true);
      await _loadProfile(session.user.id);
