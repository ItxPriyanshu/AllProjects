import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropnote/providers/providers.dart';
import 'package:dropnote/features/scheduleBuilderScreen/components/scheduleEditorDialog.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleBuilderScreen extends ConsumerWidget {
  const ScheduleBuilderScreen({super.key});

  static const int days = 7;
  static const int rows = 10;

  static const double cellWidth = 160;
  static const double cellHeight = 110;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),

        body: Center(
          child: RotatedBox(
            quarterTurns: 1, // rotate UI to landscape
            child: SizedBox(
              width: MediaQuery.of(context).size.height, // swapped
              height: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  // Day headers (also landscape now)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children:
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                              .map(
                                (d) => Expanded(
                                  child: Center(
                                    child: Text(
                                      d,
                                      style: GoogleFonts.firaSansCondensed(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),

                  // Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 7 * 10,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            mainAxisExtent: 140,
                          ),
                      itemBuilder: (context, index) {
                        final cell = schedule[index];

                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => ScheduleEditorDialog(
                                existingCell: cell,
                                onSave: (newCell) {
                                  ref
                                      .read(scheduleProvider.notifier)
                                      .addOrUpdate(index, newCell);
                                },
                                onDelete: cell == null
                                    ? null
                                    : () {
                                        ref
                                            .read(scheduleProvider.notifier)
                                            .delete(index);
                                      },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cell?.color ?? Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade600),
                            ),
                            child: cell == null
                                ? const Center(
                                    child: Icon(Icons.add, color: Colors.white),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        cell.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.firaSansCondensed(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${cell.startTime.format(context)} - ${cell.endTime.format(context)}',
                                        style: GoogleFonts.firaSansCondensed(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
