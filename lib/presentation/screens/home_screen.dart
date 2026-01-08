import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/jump_providers.dart';
import 'result_screen.dart';

/// Startskärm där användaren startar ett hopp
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jumpState = ref.watch(jumpTrackingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Jump Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status-indikator
              _buildStatusIndicator(jumpState),
              const SizedBox(height: 48),

              // Huvudknapp
              _buildActionButton(context, ref, jumpState),
              const SizedBox(height: 24),

              // Instruktioner
              _buildInstructions(jumpState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(JumpTrackingState state) {
    return switch (state) {
      JumpTrackingIdle() => const Icon(
          Icons.water_drop_outlined,
          size: 120,
          color: Colors.blue,
        ),
      JumpTrackingPreparing() => const CircularProgressIndicator(),
      JumpTrackingReady() => const Icon(
          Icons.play_circle_outline,
          size: 120,
          color: Colors.green,
        ),
      JumpTrackingJumping() => const Column(
          children: [
            Icon(Icons.flight_takeoff, size: 120, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'HOPP DETEKTERAT!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      JumpTrackingAnalyzing() => const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Analyserar...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      JumpTrackingError() => const Icon(
          Icons.error_outline,
          size: 120,
          color: Colors.red,
        ),
      JumpTrackingCompleted() => const SizedBox.shrink(),
    };
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    JumpTrackingState state,
  ) {
    return switch (state) {
      JumpTrackingIdle() => ElevatedButton.icon(
          onPressed: () {
            ref.read(jumpTrackingProvider.notifier).startJump();
          },
          icon: const Icon(Icons.play_arrow, size: 32),
          label: const Text(
            'STARTA HOPP',
            style: TextStyle(fontSize: 24),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 80),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      JumpTrackingReady() => ElevatedButton.icon(
          onPressed: null, // Väntar på hopp
          icon: const Icon(Icons.check_circle, size: 32),
          label: const Text(
            'REDO - GÖR DITT HOPP!',
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 80),
          ),
        ),
      JumpTrackingError(:final message) => Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                ref.read(jumpTrackingProvider.notifier).reset();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('FÖRSÖK IGEN'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      JumpTrackingCompleted(:final jumpData) => ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(jumpData: jumpData),
              ),
            ).then((_) {
              ref.read(jumpTrackingProvider.notifier).reset();
            });
          },
          icon: const Icon(Icons.assessment, size: 32),
          label: const Text(
            'SE RESULTAT',
            style: TextStyle(fontSize: 24),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 80),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildInstructions(JumpTrackingState state) {
    final instructions = switch (state) {
      JumpTrackingIdle() => 'Tryck på knappen och gör sedan ditt hopp. '
          'Appen kommer automatiskt att detektera när du hoppar!',
      JumpTrackingReady() => 'Appen övervakar nu sensorer. '
          'Gör ditt hopp när du är redo!',
      JumpTrackingJumping() => 'Analyserar ditt hopp i realtid...',
      JumpTrackingAnalyzing() => 'Beräknar höjd, hastighet och poäng...',
      _ => '',
    };

    if (instructions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                instructions,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
