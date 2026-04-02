import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:vector_math/vector_math.dart' as vector;

// TechStackIcons Helper

class TechStackIcons {
  // Map technology slugs to their corresponding IconData
  static final Map<String, IconData> _techIcons = {
    'typescript': Icons.code, // Using material icons as placeholders
    'javascript': Icons.javascript,
    'dart': Icons.dark_mode,
    'java': Icons.coffee,
    'react': Icons.web,
    'flutter': Icons.flutter_dash,
    'android': Icons.android,
    'html5': Icons.html,
    'css3': Icons.css,
    'express': Icons.developer_board,
    'nextdotjs': Icons.next_plan,
    'prisma': Icons.storage,
    'amazonaws': Icons.cloud,
    'firebase': Icons.local_fire_department,
    'nginx': Icons.security,
    'vercel': Icons.vertical_align_center,
    'testinglibrary': Icons.science,
    'jest': Icons.extension,
    'cypress': Icons.bug_report,
    'docker': Icons.dock,
    'jira': Icons.track_changes,
    'github': Icons.code_off,
    'gitlab': Icons.engineering,
    'visualstudiocode': Icons.code,
    'androidstudio': Icons.android,
    'sonarqube': Icons.analytics,
    'figma': Icons.design_services,
  };

  // Method to get IconData for a technology slug
  static IconData getIcon(String slug) {
    return _techIcons[slug] ?? Icons.code; // Default to code icon if not found
  }

  // Method to get specific icons from a list of slugs
  static List<IconData> getIconsFromSlugs(List<String> slugs) {
    return slugs.map((slug) => getIcon(slug)).toList();
  }
}

//item model
class IconItem {
  final String name;
  final IconData icon;
  vector.Vector3 position;
  double scale;
  final Color color;

  IconItem({
    required this.name,
    required this.icon,
    required this.position,
    required this.color,
    this.scale = 1.0,
  });
}

//globe of logos widget
class GlobeOfLogos extends StatefulWidget {
  final List<IconData> icons;
  final double radius;
  final Color defaultIconColor;

  const GlobeOfLogos({
    super.key,
    required this.icons,
    this.radius = 150.0,
    this.defaultIconColor = Colors.white,
  });

  @override
  State<GlobeOfLogos> createState() => _GlobeOfLogosState();
}

class _GlobeOfLogosState extends State<GlobeOfLogos>
    with SingleTickerProviderStateMixin {
  List<IconItem> iconItems = [];
  late AnimationController _controller;
  double _lastControllerValue = 0.0;

  // Physics-based animation
  final SpringDescription _springDescription = const SpringDescription(
    mass: 1,
    stiffness: 50,
    damping: 10,
  );

  // Interaction state
  Offset _lastPanPosition = Offset.zero;
  vector.Vector2 _rotationVelocity = vector.Vector2.zero();
  bool _isInteracting = false;
  DateTime? _lastInteractionTime;

  @override
  void initState() {
    super.initState();
    _initializeIcons();
    _setupAnimation();
  }

  void _initializeIcons() {
    if (widget.icons.isEmpty) return;

    iconItems = List.generate(widget.icons.length, (index) {
      final phi = math.acos(-1.0 + (2.0 * index) / widget.icons.length);
      final theta = math.sqrt(widget.icons.length * math.pi) * phi;

      final x = widget.radius * math.cos(theta) * math.sin(phi);
      final y = widget.radius * math.sin(theta) * math.sin(phi);
      final z = widget.radius * math.cos(phi);

      return IconItem(
        name: 'Icon $index',
        icon: widget.icons[index],
        position: vector.Vector3(x, y, z),
        color: widget.defaultIconColor,
        scale: 1.0,
      );
    });
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(_performAutoRotation);

    _controller.repeat();
  }

  void _performAutoRotation() {
    if (!mounted || iconItems.isEmpty || _isInteracting) return;

    // Skip auto-rotate if recently interacted
    if (_lastInteractionTime != null) {
      final timeSinceInteraction = DateTime.now().difference(
        _lastInteractionTime!,
      );
      if (timeSinceInteraction.inMilliseconds < 500) return;
    }

    setState(() {
      final currentValue = _controller.value;
      final deltaValue = currentValue - _lastControllerValue;

      final adjustedDelta = deltaValue.abs() > 0.5
          ? deltaValue.sign * (1 - deltaValue.abs())
          : deltaValue;

      if (adjustedDelta.abs() > 0.0001) {
        final deltaRotation = adjustedDelta * 2 * math.pi * 0.1;
        final deltaRotationMatrix = vector.Matrix4.rotationY(deltaRotation);

        for (var item in iconItems) {
          final transformed = deltaRotationMatrix.transform3(item.position);
          item.position
            ..x = transformed.x
            ..y = transformed.y
            ..z = transformed.z;
        }
      }

      _lastControllerValue = currentValue;
    });
  }

  void _handlePanStart(DragStartDetails details) {
    _isInteracting = true;
    _lastPanPosition = details.localPosition;
    _controller.stop();
    _lastControllerValue = _controller.value;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!mounted || iconItems.isEmpty) return;

    setState(() {
      final delta = details.localPosition - _lastPanPosition;

      final deltaX = -delta.dy * 0.005;
      final deltaY = delta.dx * 0.005;

      final deltaMatrixX = vector.Matrix4.rotationX(deltaX);
      final deltaMatrixY = vector.Matrix4.rotationY(deltaY);
      final combinedMatrix = deltaMatrixY..multiply(deltaMatrixX);

      for (var item in iconItems) {
        final transformed = combinedMatrix.transform3(item.position);
        item.position
          ..x = transformed.x
          ..y = transformed.y
          ..z = transformed.z;
      }

      _rotationVelocity = vector.Vector2(deltaY, deltaX);
    });

    _lastPanPosition = details.localPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    _isInteracting = false;
    _lastInteractionTime = DateTime.now();
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    if (iconItems.isEmpty) {
      return SizedBox(width: widget.radius * 2, height: widget.radius * 2);
    }

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: CustomPaint(
          painter: IconCloudPainter(
            iconItems: iconItems,
            radius: widget.radius,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

//painter for 3D model
class IconCloudPainter extends CustomPainter {
  final List<IconItem> iconItems;
  final double radius;

  IconCloudPainter({required this.iconItems, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final sortedIcons = List<IconItem>.from(iconItems)
      ..sort((a, b) => b.position.z.compareTo(a.position.z));

    for (var item in sortedIcons) {
      final center = Offset(
        size.width / 2 + item.position.x,
        size.height / 2 + item.position.y,
      );

      final opacity = math.max(
        0.4,
        math.min(1.0, (item.position.z + radius) / (radius * 2)),
      );

      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(item.icon.codePoint),
          style: TextStyle(
            fontSize: 24 * item.scale,
            fontFamily: item.icon.fontFamily,
            package: item.icon.fontPackage,
            color: item.color.withOpacity(opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      iconPainter.paint(
        canvas,
        center.translate(-iconPainter.width / 2, -iconPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(IconCloudPainter oldDelegate) => true;
}

// TechStackCloud Wrapper

class TechStackCloud extends StatelessWidget {
  final List<String> slugs = [
    "typescript",
    "javascript",
    "dart",
    "java",
    "react",
    "flutter",
    "android",
    "html5",
    "css3",
    "express",
    "nextdotjs",
    "prisma",
    "amazonaws",
    "firebase",
    "nginx",
    "vercel",
    "testinglibrary",
    "jest",
    "cypress",
    "docker",
    "git",
    "jira",
    "github",
    "gitlab",
    "visualstudiocode",
    "androidstudio",
    "sonarqube",
    "figma",
  ];

  TechStackCloud({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = TechStackIcons.getIconsFromSlugs(slugs);

    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: GlobeOfLogos(
          icons: icons,
          radius: 120,
          defaultIconColor: Colors.white70,
        ),
      ),
    );
  }
}

// Example Demo Page

class TechStackDemo extends StatelessWidget {
  const TechStackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: TechStackCloud());
  }
}
