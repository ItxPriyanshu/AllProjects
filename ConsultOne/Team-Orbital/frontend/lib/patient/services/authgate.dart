import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/patient/providers/auth_provider.dart';

/// AuthGate checks if a user is authenticated and routes accordingly.
class AuthGate extends ConsumerStatefulWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGate({super.key, required this.child, this.fallback});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate>
    with WidgetsBindingObserver {
  bool _checkDispatched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_checkDispatched) {
        setState(() => _checkDispatched = true);
        ref.read(authProvider.notifier).checkAuthStatus();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      ref.read(authProvider.notifier).checkAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show loading until we've at least dispatched the auth check (prevents flash of fallback)
    if (!_checkDispatched || authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.isAuthenticated) {
      return widget.child;
    }

    return widget.fallback ?? const Scaffold(body: Center(child: Text('Not authenticated')));
  }
}
