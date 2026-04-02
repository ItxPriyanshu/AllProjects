import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = {
      'en': 'English',
      'hi': 'हिन्दी',
      'od': 'Odia',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'settings'.tr(), // Changed key for a more general title
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- NEW: Dark Mode Option ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.dark_mode_outlined, color: Color(0xFF333333)),
                title: Text(
                 "Dark Mode ",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Switch(
                  value: false, // Hardcoded value for a non-working toggle
                  onChanged: (bool value) {
                    // In the future, logic to change the theme would go here.
                  },
                  activeThumbColor: const Color(0xFFF7C616),
                ),
              ),
            ),
          ),

          // --- Language Selection Section ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'change_language'.tr().toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.8,
              ),
            ),
          ),

          // Use Expanded to allow the ListView to fill the remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: locales.length,
                itemBuilder: (context, index) {
                  final entry = locales.entries.elementAt(index);
                  final locale = Locale(entry.key);
                  final isSelected = context.locale.languageCode == entry.key;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => context.setLocale(locale),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.5,
                            color: isSelected
                                ? const Color.fromARGB(255, 22, 165, 247)
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          color: isSelected
                              ? const Color.fromARGB(255, 143, 198, 250).withOpacity(0.3)
                              : Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        child: Row(
                          children: [
                            
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Color.fromARGB(255, 22, 135, 247)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}