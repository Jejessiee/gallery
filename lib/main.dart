import 'package:flutter/material.dart';
import 'editor/editor_page.dart';

void main() {
  runApp(const MyGalleryApp());
}

class MyGalleryApp extends StatelessWidget {
  const MyGalleryApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery Zoom & Annotate',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const EditorPage(),
    );
  }
}

