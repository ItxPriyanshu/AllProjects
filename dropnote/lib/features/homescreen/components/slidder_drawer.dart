import 'package:dropnote/features/homescreen/components/slider_drawer_container.dart';
import 'package:flutter/material.dart';

class MySlidderDrawer extends StatefulWidget {
  const MySlidderDrawer({super.key});

  @override
  State<MySlidderDrawer> createState() => _MySlidderDrawerState();
}

class _MySlidderDrawerState extends State<MySlidderDrawer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                   SliderDrawerContainer(title: 'settings', icon: Icons.settings),
                    SliderDrawerContainer(title: 'Read me', icon: Icons.open_in_browser),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    SliderDrawerContainer(title: 'posts', icon: Icons.post_add),
                    SliderDrawerContainer(title: 'logout', icon: Icons.logout),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
