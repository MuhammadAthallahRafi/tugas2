import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// Main Function
void main() {
  runApp(NoteApp());
}

// Note Application
class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoteModel()),
      ],
      child: MaterialApp(
        title: 'Catatan dengan Provider , Get X dan Statefull',
        home: NoteHomeScreen(),
      ),
    );
  }
}

// Model for Provider
class NoteModel with ChangeNotifier {
  List<String> _notes = [];

  List<String> get notes => _notes;

  void addNote(String note) {
    _notes.add(note);
    notifyListeners();
  }
}

// Home Screen with TabBar
class NoteHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs including StatefulWidget
      child: Scaffold(
        appBar: AppBar(
          title: Text('Catatan dengan Provider dan GetX'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Provider'),
              Tab(text: 'GetX'),
              Tab(text: 'StatefulWidget'), // New tab for StatefulWidget
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProviderNoteScreen(), // Stateless Widget
            GetXNoteScreen(), // Stateless Widget
            StatefulNoteScreen(), // New Stateful Widget
          ],
        ),
      ),
    );
  }
}

// Note Screen using Provider
class ProviderNoteScreen extends StatelessWidget {
  final TextEditingController _noteController = TextEditingController();
  final ValueNotifier<bool> _isConfirmed = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final noteModel = Provider.of<NoteModel>(context);

    void _addNote() {
      if (_isConfirmed.value && _noteController.text.isNotEmpty) {
        noteModel.addNote(_noteController.text);
        _noteController.clear();
        _isConfirmed.value = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Pastikan catatan diisi dan konfirmasi dicentang')),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Tulis catatan Anda',
              border: OutlineInputBorder(),
            ),
          ),
          Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _isConfirmed,
                builder: (context, value, child) {
                  return Checkbox(
                    value: value,
                    onChanged: (newValue) {
                      _isConfirmed.value = newValue ?? false;
                    },
                  );
                },
              ),
              Text('Konfirmasi untuk menambahkan catatan'),
            ],
          ),
          ElevatedButton(
            onPressed: _addNote,
            child: Text('Tambahkan Catatan'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: noteModel.notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(noteModel.notes[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Note Controller for GetX
class NoteController extends GetxController {
  var notes = <String>[].obs;
  var isConfirmed = false.obs;

  void addNote(String note) {
    if (isConfirmed.value && note.isNotEmpty) {
      notes.add(note);
      isConfirmed.value = false; // Reset confirmation after adding
    } else {
      Get.snackbar(
          'Peringatan', 'Pastikan catatan diisi dan konfirmasi dicentang');
    }
  }

  void toggleConfirmation(bool? value) {
    isConfirmed.value = value ?? false; // Handle null case
  }
}

// Note Screen using GetX
class GetXNoteScreen extends StatelessWidget {
  final NoteController noteController = Get.put(NoteController());
  final TextEditingController noteControllerInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: noteControllerInput,
            decoration: InputDecoration(
              labelText: 'Tulis catatan Anda',
              border: OutlineInputBorder(),
            ),
          ),
          Row(
            children: [
              Obx(() => Checkbox(
                    value: noteController.isConfirmed.value,
                    onChanged: noteController.toggleConfirmation,
                  )),
              Text('Konfirmasi untuk menambahkan catatan'),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              noteController.addNote(noteControllerInput.text);
              noteControllerInput.clear();
            },
            child: Text('Tambahkan Catatan'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: noteController.notes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(noteController.notes[index]),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}

// Note Screen using StatefulWidget
class StatefulNoteScreen extends StatefulWidget {
  @override
  _StatefulNoteScreenState createState() => _StatefulNoteScreenState();
}

class _StatefulNoteScreenState extends State<StatefulNoteScreen> {
  final TextEditingController _noteController = TextEditingController();
  final List<String> _notes = [];
  bool _isConfirmed = false;

  void _addNote() {
    if (_isConfirmed && _noteController.text.isNotEmpty) {
      setState(() {
        _notes.add(_noteController.text);
        _noteController.clear();
        _isConfirmed = false; // Reset confirmation after adding
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Pastikan catatan diisi dan konfirmasi dicentang')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Tulis catatan Anda',
              border: OutlineInputBorder(),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: _isConfirmed,
                onChanged: (value) {
                  setState(() {
                    _isConfirmed = value ?? false;
                  });
                },
              ),
              Text('Konfirmasi untuk menambahkan catatan'),
            ],
          ),
          ElevatedButton(
            onPressed: _addNote,
            child: Text('Tambahkan Catatan'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_notes[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
