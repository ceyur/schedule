import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
    ); // Scaffold
  } // build
} // Profile
