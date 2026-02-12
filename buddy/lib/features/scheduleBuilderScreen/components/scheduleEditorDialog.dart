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
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: const Color.fromARGB(255, 46, 46, 46),
            hourMinuteColor: Colors.grey.shade800,
            hourMinuteTextColor: Colors.white,
            dialBackgroundColor: Colors.grey.shade900,
            dialHandColor: Colors.blue,
            dialTextColor: Colors.white,
            entryModeIconColor: Colors.white,
            dayPeriodColor: const Color.fromARGB(255, 102, 189, 255),
            dayPeriodTextColor: Colors.white,
            dayPeriodBorderSide: const BorderSide(color: Colors.blue),
            helpTextStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Colors.white, // OK / selected color
          ),
        ), child: child!);
      },
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
      backgroundColor: const Color.fromARGB(255, 46, 46, 46),
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
                      : startTime!.format(context),style: TextStyle(color: Colors.greenAccent),),
                ),
                TextButton(
                  onPressed: () => pickTime(false),
                  child: Text(endTime == null
                      ? "End Time"
                      : endTime!.format(context),style: TextStyle(color: Colors.greenAccent),),
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
                Colors.yellow,
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
          child: const Text("Cancel",style: TextStyle(color: Colors.redAccent)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(65, 184, 184, 184)
          ),
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
          child: const Text("Save",style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  
  }
}