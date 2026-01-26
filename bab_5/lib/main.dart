import 'package:flutter/material.dart';

// --- 1. DATA MODEL ---
// Class sederhana untuk menyimpan data catatan
class Note {
  String title;
  String description;

  Note({required this.title, required this.description});
}

void main() {
  runApp(const MyApp());
}

// --- 2. MAIN APP & ROUTES ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CatatanKu Pro',
      // Tema Konsisten (Teal)
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: false, // Kita pakai style klasik agar scaffold jelas
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      // Menggunakan Named Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/entry': (context) => const EntryFormPage(),
      },
    );
  }
}

// --- 3. LOGIN PAGE ---
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.book, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                "CatatanKu Pro",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigasi: pushReplacement
                    // Mengganti halaman Login dengan Home (Login hilang dari stack)
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text("MASUK", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4. HOME PAGE (LIST) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List untuk menyimpan data dummy awal
  final List<Note> _notes = [
    Note(title: 'Belajar Flutter', description: 'Pelajari Widget Tree dan State'),
    Note(title: 'Tugas Kuliah', description: 'Selesaikan laporan PKM'),
  ];

  // Fungsi untuk navigasi ke halaman Form
  void _openEntryForm() async {
    // Navigasi: Push dan MENUNGGU hasil balik (await)
    final result = await Navigator.pushNamed(context, '/entry');

    // Jika ada data yang dikirim balik (tidak null)
    if (result != null && result is Note) {
      setState(() {
        _notes.add(result); // Tambahkan ke list
      });
      // Tampilkan feedback (Event Handling)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.title} berhasil ditambahkan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Catatan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Kembali ke Login dengan pushReplacement
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      // UI Rapi dengan ListView.builder
      body: _notes.isEmpty
          ? const Center(child: Text("Belum ada catatan"))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal[100],
                      child: Text("${index + 1}"),
                    ),
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(note.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _notes.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      // Floating Action Button (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: _openEntryForm, // Event Handling
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- 5. ENTRY FORM PAGE (TAMBAH DATA) ---
class EntryFormPage extends StatefulWidget {
  const EntryFormPage({super.key});

  @override
  State<EntryFormPage> createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  // Controller untuk mengambil teks input
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Catatan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Judul
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              // Event Handling: Pindah fokus saat enter ditekan
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            // Input Deskripsi
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("SIMPAN", style: TextStyle(fontSize: 18)),
                onPressed: () {
                  // Validasi sederhana
                  if (_titleController.text.isEmpty ||
                      _descController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Judul dan Deskripsi harus diisi!")),
                    );
                    return;
                  }

                  // Membuat object Note baru
                  final newNote = Note(
                    title: _titleController.text,
                    description: _descController.text,
                  );

                  // Navigasi: Pop dengan MENGIRIM DATA (result)
                  Navigator.pop(context, newNote);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}