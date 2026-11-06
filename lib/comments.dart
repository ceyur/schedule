import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class Comments extends StatefulWidget {
  const Comments({super.key});

  @override
  State<Comments> createState() => _Comments();
}

class _Comments extends State<Comments> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  
  // Данные профиля
  String? _userName;
  String? _userAvatar;

  // Контроллеры для формы
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isRegistering = false;
  bool _isFormLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      setState(() => _isLoggedIn = true);
      await _loadProfile(session.user.id);
    }
    else {
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
          .select("name, avatar_url")
          .eq("id", userId)
          .maybeSingle(); // maybeSingle вернет null, если профиль еще не создан

      if (response != null) {
        setState(() {
          _userName = response["name"] as String?;
          _userAvatar = response["avatar_url"] as String?;
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

  Future<void> _handleAuth() async {
    // Простая валидация без FormKey, чтобы избежать ошибок копирования
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните email и пароль")),
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
      if (_isRegistering) {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {"name": _nameController.text.trim()},
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Проверьте почту для подтверждения!")),
        );
      }
      else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      
      // После успеха обновляем состояние и очищаем поля
      await _checkAuth();
      _emailController.clear();
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
    });
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

  // Вид, если пользователь ВОШЕЛ
  Widget _buildLoggedInView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _userAvatar != null ? NetworkImage(_userAvatar!) : null,
                  child: _userAvatar == null ? const Icon(Icons.person, size: 30) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Добро пожаловать,", style: TextStyle(color: Colors.grey)),
                      Text(
                        _userName ?? "Пользователь",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: _logout,
                  tooltip: "Выйти",
                ),
              ],
            ),
          ),
        ),
        // const SizedBox(height: 16), // Отступ между карточками

        // 2. Карточка выбора темы
        // Card(
        //   child: ListTile(
        //     leading: const Icon(Icons.topic, color: Colors.blue, size: 30),
        //     title: const Text("Тема", style: TextStyle(fontWeight: FontWeight.bold)),
        //     subtitle: Text(_selectedTheme ?? "Не выбрана"),
        //     trailing: const Icon(Icons.chevron_right),
        //     onTap: _showThemeSelector,
        //   ),
        // ),

      ],
    );
  }

  // Вид, если пользователь НЕ ВОШЕЛ
  Widget _buildLoggedOutView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _isRegistering ? "Регистрация" : "Авторизация",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_isRegistering) ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Ваше имя",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Пароль",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
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
                      _emailController.clear();
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
