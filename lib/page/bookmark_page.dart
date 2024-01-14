import 'package:flutter/material.dart';

class BookMarkPage extends StatefulWidget {
  const BookMarkPage({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<BookMarkPage> createState() => _BookMarkPageState();
}

class _BookMarkPageState extends State<BookMarkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
      ),
    );
  }
}
