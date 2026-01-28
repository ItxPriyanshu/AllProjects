// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dropnote/models/schedule_cell.dart';
import 'package:flutter/material.dart';

class ScheduleEditorDialog extends StatefulWidget {
   final ScheduleCell? existingCell;
  final void Function(ScheduleCell cell) onSave;
  final VoidCallback? onDelete;
  const ScheduleEditorDialog({
    Key? key,
    this.existingCell,
    required this.onSave,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ScheduleEditorDialog> createState() => _ScheduleEditorDialogState();
}

class _ScheduleEditorDialogState extends State<ScheduleEditorDialog> {

late TextEditingController titleCtrl;
TimeOfDay? startTime;
  TimeOfDay? endTime;
  Color selectedColor = Colors.blue;

@override
  void initState() {
    titleCtrl = TextEditingController(
        text: widget.existingCell?.title ?? "");
    startTime = widget.existingCell?.startTime;
    endTime = widget.existingCell?.endTime;
    selectedColor = widget.existingCell?.color ?? Colors.blue;
    super.initState();
  }


Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingCell == null ? "Add Task" : "Edit Task"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: () => pickTime(true),
                  child: Text(startTime == null
                      ? "Start Time"
                      : startTime!.format(context)),
                ),
                TextButton(
                  onPressed: () => pickTime(false),
                  child: Text(endTime == null
                      ? "End Time"
                      : endTime!.format(context)),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
              ].map((c) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = c),
                  child: CircleAvatar(
                    backgroundColor: c,
                    child: selectedColor == c
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.onDelete != null)
          TextButton(
            onPressed: () {
              widget.onDelete!();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel",style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleCtrl.text.isEmpty ||
                startTime == null ||
                endTime == null) return;

            widget.onSave(
              ScheduleCell(
                title: titleCtrl.text,
                startTime: startTime!,
                endTime: endTime!,
                color: selectedColor,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  
  }
}