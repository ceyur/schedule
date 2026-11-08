import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:schedule/data.dart";
import "package:schedule/select.dart";

class Profile extends StatefulWidget {
	const Profile({super.key});

	@override
	State<Profile> createState() => _Profile();
} // Profile

class _Profile extends State<Profile> {
	bool _isLoading = true;
	bool _isLoggedIn = false;
	
	String? _userName;
	String? _userAvatar;

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
					.maybeSingle();

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
		// 1. Показываем диалог подтверждения
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

		// Если пользователь нажал "Отмена" или закрыл диалог, прерываем выполнение
		if (confirm != true) return;

		setState(() => _isFormLoading = true);

		try {
			final userId = Supabase.instance.client.auth.currentUser?.id;
			if (userId == null) throw Exception("Пользователь не авторизован");

			// 2. Удаляем запись из таблицы profiles
			await Supabase.instance.client.from("profiles").delete().eq("id", userId);

			// 3. Очищаем локальные данные (избранные группы)
			await data.clear();
			mySchedule.clear();

			// 4. Выходим из системы
			await Supabase.instance.client.auth.signOut();

			if (!mounted) return;

			// 5. Обновляем состояние UI
			setState(() {
				_isLoggedIn = false;
				_userName = null;
				_userAvatar = null;
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
				padding: const EdgeInsets.all(10),
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
						padding: const EdgeInsets.all(10),
						child: Row(
							children: [
								CircleAvatar(
									radius: 30,
									backgroundImage: _userAvatar != null ? NetworkImage(_userAvatar!) : null,
									child: _userAvatar == null ? const Icon(Icons.person, size: 30) : null,
								),
								const SizedBox(width: 10),
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
							],
						),
					),
				),
				const SizedBox(height: 10),
				// Карточка выбора темы оформления
				Card(
					child: ListTile(
						leading: Icon(
							themeIcons[themeNotifier.value]!,
							color: Colors.orange,
							size: 30,
						),
						title: const Text("Тема оформления", style: TextStyle(fontWeight: FontWeight.bold)),
						subtitle: Text(themeNames[themeNotifier.value]!),
						trailing: const Icon(Icons.chevron_right),
						onTap: _showThemeSelector,
					),
				),
				const SizedBox(height: 10),
				// 3. Карточка выбора группы
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
										controller: _emailController,
										decoration: const InputDecoration(
											labelText: "Email",
											border: OutlineInputBorder(),
										),
										keyboardType: TextInputType.emailAddress,
									),
									const SizedBox(height: 10),
									TextField(
										controller: _passwordController,
										decoration: const InputDecoration(
											labelText: "Пароль",
											border: OutlineInputBorder(),
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
