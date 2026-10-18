import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class Comments extends StatelessWidget {
  const Comments({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Отзывы")),
    ); // Scaffold
  } // build
} // Comments
