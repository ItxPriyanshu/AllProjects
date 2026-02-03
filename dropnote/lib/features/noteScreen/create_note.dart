import 'package:dropnote/models/note_model.dart';
import 'package:dropnote/providers/notes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class CreateNote extends ConsumerStatefulWidget {
  const CreateNote({super.key});

  @override
  ConsumerState<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends ConsumerState<CreateNote> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool isPublic = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'description'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Private'),
                Switch(
                  value: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value;
                    });
                  },
                ),
                const Text('Public'),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                final note = Note(
                  id: const Uuid().v4(),
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  isPublic: isPublic,
                  createdAt: DateTime.now(),
                );
                print(Uuid().v4());
                ref.read(noteProvider.notifier).addNote(note);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
