import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:schedule/data.dart";
// import 'auth_page.dart';


class Comments extends StatefulWidget {
  const Comments({super.key});

  @override
  State<Comments> createState() => _Comments();
}

class _Comments extends State<Comments> {
  final supabase = Supabase.instance.client;
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _message;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _message = null; });

    try {
      if (_isLogin) {
        await supabase.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      } else {
        final res = await supabase.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        // Если включено подтверждение почты — сессия будет null
        if (res.session == null) {
          setState(() => _message = 'Подтвердите почту — письмо уже летит ✉️');
          return;
        }
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    } on AuthException catch (e) {
      setState(() => _message = e.message);
    } catch (_) {
      setState(() => _message = 'Что-то пошло не так');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_isLogin ? 'Вход' : 'Регистрация',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v != null && v.contains('@') ? null : 'Введите email',
                    ),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Пароль'),
                      obscureText: true,
                      validator: (v) =>
                          v != null && v.length >= 6 ? null : 'Минимум 6 символов',
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Text(_isLogin ? 'Войти' : 'Создать аккаунт'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin
                          ? 'Нет аккаунта? Зарегистрироваться'
                    ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_message!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  
  // Данные профиля
  String? _userName;
  String? _userAvatar;

  // Контроллеры для формы входа
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
          .from('profiles')
          .select('name, picture_url')
          .eq('id', userId)
          .maybeSingle(); // maybeSingle вернет null, если профиль еще не создан

      if (response != null) {
        setState(() {
          _userName = response['name'];
          _userAvatar = response['picture_url'];
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки профиля: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAuth() async {
    setState(() => _isFormLoading = true);
    try {
      if (_isRegistering) {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {'name': _nameController.text.trim()},
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Проверьте почту для подтверждения!')),
        );
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      // После успеха обновляем состояние
      await _checkAuth();
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      setState(() => _isRegistering = false);
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _isFormLoading = false);
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Комментарии')),
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
        // Карточка профиля
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
                      const Text('Добро пожаловать,', style: TextStyle(color: Colors.grey)),
                      Text(
                        _userName ?? 'Пользователь',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: _logout,
                  tooltip: 'Выйти',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Список комментариев:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // Здесь будет ваш ListView с комментариями
        Expanded(
          child: Container(
            color: Colors.grey.shade100,
            child: const Center(child: Text('Здесь будут комментарии')),
          ),
        ),
      ],
    );
  }

  // Вид, если пользователь НЕ ВОШЕЛ
  Widget _buildLoggedOutView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Войдите или зарегистрируйтесь,\nчтобы видеть профиль и оставлять комментарии',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        
        // Форма входа/регистрации
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_isRegistering) ...[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Ваше имя', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                _isFormLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleAuth,
                          child: Text(_isRegistering ? 'Зарегистрироваться' : 'Войти'),
                        ),
                      ),
                TextButton(
                  onPressed: () => setState(() => _isRegistering = !_isRegistering),
                  child: Text(_isRegistering
                      ? 'Уже есть аккаунт? Войти'
                      : 'Нет аккаунта? Зарегистрироваться'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
