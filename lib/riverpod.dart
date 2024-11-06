import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model untuk catatan
class NoteModel extends ChangeNotifier {
  final List<String> _notes = [];
  bool _isConfirmed = false; // Status checkbox

  List<String> get notes => _notes;
  bool get isConfirmed => _isConfirmed; // Getter untuk status checkbox

  void addNote(String note) {
    if (_isConfirmed) {
      _notes.add(note);
      notifyListeners();
    }
  }

  void setConfirmed(bool value) {
    _isConfirmed = value; // Update status checkbox
    notifyListeners(); // Pemberitahuan untuk pembaruan UI
  }

  void clearNotes() {
    _notes.clear(); // Opsional: Menambahkan fungsi untuk menghapus catatan
  }
}

// Provider untuk catatan
final noteProvider = ChangeNotifierProvider<NoteModel>((ref) {
  return NoteModel();
});

void main() {
  runApp(const ProviderScope(child: NoteApp()));
}

class NoteApp extends StatelessWidget {
  const NoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan dengan Riverpod',
      home: const NoteScreen(),
    );
  }
}

class NoteScreen extends ConsumerWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController noteController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Tulis catatan Anda',
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: ref
                      .watch(noteProvider)
                      .isConfirmed, // Menggunakan nilai dari provider
                  onChanged: (value) {
                    ref.read(noteProvider.notifier).setConfirmed(
                        value ?? false); // Mengupdate status checkbox
                  },
                ),
                const Text('Konfirmasi'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                final noteText = noteController.text;
                if (noteText.isNotEmpty) {
                  if (ref.read(noteProvider).isConfirmed) {
                    // Menambahkan catatan jika terkonfirmasi
                    ref.read(noteProvider.notifier).addNote(noteText);
                    noteController
                        .clear(); // Mengosongkan input setelah catatan ditambahkan
                    ref
                        .read(noteProvider.notifier)
                        .setConfirmed(false); // Reset checkbox
                  } else {
                    // Menampilkan pesan peringatan jika checkbox tidak dicentang
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Anda harus mencentang konfirmasi sebelum menambahkan catatan.'),
                      ),
                    );
                  }
                } else {
                  // Menampilkan pesan peringatan jika catatan kosong
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catatan tidak boleh kosong.'),
                    ),
                  );
                }
              },
              child: const Text('Tambahkan Catatan'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  // Mengambil catatan
                  final notes = ref.watch(noteProvider).notes;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(notes[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
