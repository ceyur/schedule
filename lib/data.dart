import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

enum Type { group, teacher, room }
late SharedPreferences data;
List<List<dynamic>> mySchedule = [
	["23-03 ИСиП", Type.group],
	["Шаидова Насиба Абдрашитовна", Type.teacher],
	["ОЗИВТ(ППК-2)-25-1-у", Type.group],
];


final List<ThemeMode> themeModes = [
	ThemeMode.light,
	ThemeMode.dark,
	ThemeMode.system,
];

final Map<ThemeMode, String> themeNames = {
	ThemeMode.light: "Светлая",
	ThemeMode.dark: "Тёмная",
	ThemeMode.system: "Системная",
};

final Map<ThemeMode, IconData> themeIcons = {
	ThemeMode.light: Icons.light_mode,
	ThemeMode.dark: Icons.dark_mode,
	ThemeMode.system: Icons.brightness_auto,
};


final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
ValueNotifier<int> tabIndexNotifier = ValueNotifier<int>(0);
