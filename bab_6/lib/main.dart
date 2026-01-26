import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart';

void main() { 
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MaterialApp(home: MyNoteApp()));
  }

class MyNoteApp extends StatefulWidget {
  const MyNoteApp({super.key});
  @override
  State<MyNoteApp> createState() => _MyNoteAppState();
}

class _MyNoteAppState extends State<MyNoteApp> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() async {
    final data = await dbHelper.queryAllNotes();
    setState(() => _notes = data);
  }

  void _showForm(int? id) async {
    String title = "";
    String content = "";
    if (id != null) {
      final existingNote = _notes.firstWhere((element) => element['id'] == id);
      title = existingNote['title'];
      content = existingNote['content'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: MediaQuery.of(context).viewInsets.bottom + 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Judul'),
              onChanged: (v) => title = v,
              controller: TextEditingController(text: title),
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Isi Catatan'),
              onChanged: (v) => content = v,
              controller: TextEditingController(text: content),
            ),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await dbHelper.insertNote({'title': title, 'content': content, 'created_at': DateTime.now().toString()});
                } else {
                  await dbHelper.updateNote({'id': id, 'title': title, 'content': content});
                }
                Navigator.pop(context);
                _refreshNotes();
              },
              child: Text(id == null ? 'Tambah' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Note App')),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text(_notes[index]['title']),
            subtitle: Text(_notes[index]['content']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(_notes[index]['id'])),
                IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                  await dbHelper.deleteNote(_notes[index]['id']);
                  _refreshNotes();
                }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}