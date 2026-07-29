import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      if (_navigated) {
        return;
      }
      next.whenOrNull(
        data: (state) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              return;
            }
            context.go(state.isAuthenticated ? '/dashboard' : '/login');
          });
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final authStateVal = authState.value;

    if (authStateVal != null && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(authStateVal.isAuthenticated ? '/dashboard' : '/login');
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark slate
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Animated or decorated circular loading area
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.precision_manufacturing_outlined,
                  size: 64,
                  color: Color(0xFF14B8A6),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Button Factory MES',
                style: TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                authState.isLoading ? 'Checking secure session...' : 'Preparing your workspace...',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              if (authState.hasError) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'Initialization Error:\n${authState.error}',
                    style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        ref.invalidate(authControllerProvider);
                      },
                      child: const Text('Retry'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ] else
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

