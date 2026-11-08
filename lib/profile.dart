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
    } else {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from("profiles")
          .select("name, avatar_url, phone, birth_date")
          .eq("id", userId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _userName = response["name"] as String?;
          _userAvatar = response["avatar_url"] as String?;
          _userPhone = response["phone"] as String?;
          _userBirthDate = response["birth_date"] as String?;
          _userEmail = Supabase.instance.client.auth.currentUser?.email;
        });
      }
    } catch (e) {
      debugPrint("Ошибка загрузки профиля: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- ЛОГИКА РЕДАКТИРОВАНИЯ ПРОФИЛЯ ---

  Future<void> _showEditProfile() async {
    _editNameController.text = _userName ?? "";
    _editPhoneController.text = _userPhone ?? "";
    _editEmailController.text = _userEmail ?? "";
    
    if (_userBirthDate != null && _userBirthDate!.isNotEmpty) {
      try {
        final date = DateTime.parse(_userBirthDate!);
        _editDobController.text = DateFormat('dd.MM.yyyy').format(date);
      } catch (e) {
        _editDobController.text = _userBirthDate!;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text("Редактировать профиль", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _editNameController,
                  decoration: const InputDecoration(labelText: "Имя", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editPhoneController,
                  decoration: const InputDecoration(labelText: "Телефон", border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editEmailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editDobController,
                  decoration: const InputDecoration(
                    labelText: "Дата рождения (ДД.ММ.ГГГГ)", 
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 20),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isFormLoading ? null : _saveProfileChanges,
                    child: _isFormLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text("Сохранить изменения", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfileChanges() async {
    setState(() => _isFormLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final currentPhone = currentUser?.phone;
      final currentEmail = currentUser?.email;

      final newPhone = _editPhoneController.text.trim();
      final newEmail = _editEmailController.text.trim();

      // 1. Обновляем данные авторизации (Email или Телефон) независимо, если они изменились
      if (newPhone.isNotEmpty && newPhone != currentPhone) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(phone: newPhone),
        );
      }

      if (newEmail.isNotEmpty && newEmail != currentEmail) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: newEmail),
        );
      }

      // 2. Парсим дату в формат YYYY-MM-DD для базы данных
      String? formattedDob;
      if (_editDobController.text.trim().isNotEmpty) {
        try {
          final date = DateFormat('dd.MM.yyyy').parseStrict(_editDobController.text.trim());
          formattedDob = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          formattedDob = _editDobController.text.trim(); 
        }
      }

      // 3. Обновляем таблицу profiles
      await Supabase.instance.client.from("profiles").update({
        "name": _editNameController.text.trim(),
        "phone": newPhone,
        "birth_date": formattedDob,
      }).eq("id", userId);

      if (!mounted) return;
      Navigator.pop(context);
      
      await _loadProfile(userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль успешно обновлен!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка сохранения: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isFormLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isFormLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));

      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from("profiles").update({
        "avatar_url": imageUrl,
      }).eq("id", userId);

      if (!mounted) return;
      await _loadProfile(userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Аватарка успешно обновлена!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка загрузки аватарки: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isFormLoading = false);
      }
    }
  }

  // --- ЛОГИКА АВТОРИЗАЦИИ ---

  Future<void> _handleAuth() async {
    final loginInput = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (loginInput.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните все поля")),
      );
      return;
    }

    if (_isRegistering && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, введите имя")),
      );
      return;
    }

    setState(() => _isFormLoading = true);
    try {
      // Простая и надежная проверка: если строка похожа на email, используем его, иначе считаем телефоном
      final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(loginInput);

      if (_isRegistering) {
        if (isEmail) {
          await Supabase.instance.client.auth.signUp(
            email: loginInput,
            password: password,
            data: {"name": _nameController.text.trim()},
          );
        } else {
          await Supabase.instance.client.auth.signUp(
            phone: loginInput,
            password: password,
            data: {"name": _nameController.text.trim()},
          );
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Проверьте почту или SMS для подтверждения!")),
        );
      } else {
        if (isEmail) {
          await Supabase.instance.client.auth.signInWithPassword(
            email: loginInput,
            password: password,
          );
        } else {
          await Supabase.instance.client.auth.signInWithPassword(
            phone: loginInput,
            password: password,
          );
        }
      }
      
      await _checkAuth();
      _loginController.clear();
      _passwordController.clear();
      _nameController.clear();
      setState(() => _isRegistering = false);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Неизвестная ошибка: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isFormLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    setState(() {
      _isLoggedIn = false;
      _userName = null;
      _userAvatar = null;
      _userPhone = null;
      _userBirthDate = null;
      _userEmail = null;
    });
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Выберите тему",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...themeModes.map((mode) {
                final isSelected = themeNotifier.value == mode;
                return ListTile(
                  leading: Icon(
                    themeIcons[mode],
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    themeNames[mode]!,
                    style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    themeNotifier.value = mode;
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showGroupSelector() async {
    await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const Select(),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Удалить аккаунт?", style: TextStyle(color: Colors.red)),
        content: const Text(
          "Это действие необратимо. Ваш профиль и все локально сохраненные избранные группы будут безвозвратно удалены.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Удалить", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isFormLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception("Пользователь не авторизован");

      await Supabase.instance.client.from("profiles").delete().eq("id", userId);
      await data.clear();
      mySchedule.clear();
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
        _userName = null;
        _userAvatar = null;
        _userPhone = null;
        _userBirthDate = null;
        _userEmail = null;
        _isFormLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Аккаунт успешно удален")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFormLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при удалении: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoggedIn ? _buildLoggedInView() : _buildLoggedOutView(),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _userAvatar != null && _userAvatar!.isNotEmpty 
                      ? NetworkImage(_userAvatar!) 
                      : null,
                  child: _userAvatar == null || _userAvatar!.isEmpty 
                      ? const Icon(Icons.person, size: 55, color: Colors.grey) 
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // --- ИЗМЕНЕНО: Имя с маленьким карандашиком рядом ---
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _userName ?? "Пользователь",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showEditProfile,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.edit, 
                    size: 22, 
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          
          // Показываем либо почту, либо телефон (в зависимости от способа регистрации)
          if (_userEmail != null || _userPhone != null) ...[
            const SizedBox(height: 4),
            Text(
              _userEmail ?? _userPhone ?? "", 
              style: const TextStyle(color: Colors.grey, fontSize: 14)
            ),
          ],
          const SizedBox(height: 24),

          // --- УДАЛЕНО: Большая кнопка "Редактировать профиль" ---

          // --- ОСТАЛЬНЫЕ КАРТОЧКИ (выровнены по ширине) ---
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, currentTheme, child) {
                    return Card(
                      child: ListTile(
                        leading: Icon(themeIcons[currentTheme]!, color: Colors.orange, size: 30),
                        title: const Text("Тема оформления", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(themeNames[currentTheme]!),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showThemeSelector,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.groups, color: Colors.green, size: 30),
                    title: const Text("Выбрать избранные группы", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showGroupSelector,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: const Text("Выйти", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.logout, color: Colors.red),
                    onTap: _logout,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    title: const Text("Удалить аккаунт", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.delete_forever, color: Colors.red),
                    onTap: _deleteAccount,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _isRegistering ? "Регистрация" : "Авторизация",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_isRegistering) ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Ваше имя",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: _loginController, // ИЗМЕНЕНО
                    decoration: const InputDecoration(
                      labelText: "Email или телефон", // ИЗМЕНЕНО
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Пароль",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  _isFormLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleAuth,
                            child: Text(_isRegistering ? "Зарегистрироваться" : "Войти"),
                          ),
                        ),
                  TextButton(
                    onPressed: () {
                      setState(() => _isRegistering = !_isRegistering);
                      _loginController.clear(); // ИЗМЕНЕНО
                      _passwordController.clear();
                      _nameController.clear();
                    },
                    child: Text(_isRegistering
                        ? "Уже есть аккаунт? Войти"
                        : "Нет аккаунта? Зарегистрироваться"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
