import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Event untuk BLoC
abstract class NoteEvent {}

class AddNote extends NoteEvent {
  final String note;

  AddNote(this.note);
}

class SetConfirmation extends NoteEvent {
  final bool isConfirmed;

  SetConfirmation(this.isConfirmed);
}

// State untuk BLoC
class NoteState {
  final List<String> notes;
  final bool isConfirmed; // Menyimpan status checkbox

  NoteState({required this.notes, this.isConfirmed = false});
}

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc() : super(NoteState(notes: [])) {
    // Menangani event saat BLoC dibuat
    on<AddNote>((event, emit) {
      // Log untuk debugging
      print('Adding note: ${event.note}');
      final updatedNotes = List<String>.from(state.notes)..add(event.note);
      emit(NoteState(
          notes: updatedNotes,
          isConfirmed: state.isConfirmed)); // Ganti yield dengan emit
    });

    on<SetConfirmation>((event, emit) {
      emit(NoteState(
          notes: state.notes,
          isConfirmed: event.isConfirmed)); // Update status konfirmasi
    });
  }
}

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan dengan BLoC',
      home: BlocProvider(
        create: (context) => NoteBloc(),
        child: const NoteScreen(),
      ),
    );
  }
}

class NoteScreen extends StatelessWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                BlocBuilder<NoteBloc, NoteState>(
                  builder: (context, state) {
                    return Checkbox(
                      value: state.isConfirmed,
                      onChanged: (value) {
                        // Mengubah status konfirmasi
                        context
                            .read<NoteBloc>()
                            .add(SetConfirmation(value ?? false));
                      },
                    );
                  },
                ),
                const Text('Konfirmasi'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                final noteText = noteController.text;
                if (noteText.isNotEmpty) {
                  if (context.read<NoteBloc>().state.isConfirmed) {
                    context.read<NoteBloc>().add(AddNote(noteText));
                    noteController
                        .clear(); // Mengosongkan input setelah catatan ditambahkan
                    context
                        .read<NoteBloc>()
                        .add(SetConfirmation(false)); // Reset checkbox
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
              child: BlocBuilder<NoteBloc, NoteState>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: state.notes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.notes[index]),
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
