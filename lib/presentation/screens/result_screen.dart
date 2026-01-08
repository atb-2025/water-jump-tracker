import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/jump_data.dart';

/// Resultatskärm som visar detaljerad analys av hoppet
class ResultScreen extends StatelessWidget {
  final JumpData jumpData;

  const ResultScreen({super.key, required this.jumpData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoppresultat'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Totalpoäng
          _buildScoreCard(),
          const SizedBox(height: 16),

          // Huvudmätningar
          _buildMainMetrics(),
          const SizedBox(height: 16),

          // Rotation
          _buildRotationCard(),
          const SizedBox(height: 16),

          // Miljödata
          _buildEnvironmentCard(),
          const SizedBox(height: 16),

          // Pulsdata
          _buildPulseCard(),
          const SizedBox(height: 16),

          // Graf
          _buildChart(),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      color: _getScoreColor(jumpData.totalScore),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'TOTALPOÄNG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              jumpData.totalScore.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _getScoreRating(jumpData.totalScore),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMetrics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Huvudmätningar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildMetricRow('Höjd', '${jumpData.height.toStringAsFixed(2)} m',
                Icons.height),
            _buildMetricRow('Falltid',
                '${jumpData.fallTime.toStringAsFixed(2)} s', Icons.timer),
            _buildMetricRow('Hastighet',
                '${jumpData.velocity.toStringAsFixed(2)} m/s', Icons.speed),
            _buildMetricRow(
                'Stabilitet',
                '${jumpData.stabilityScore.toStringAsFixed(1)}%',
                Icons.balance),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rotation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildMetricRow(
                'X-axel',
                '${jumpData.rotationX.toStringAsFixed(1)}°',
                Icons.rotate_right),
            _buildMetricRow(
                'Y-axel',
                '${jumpData.rotationY.toStringAsFixed(1)}°',
                Icons.rotate_right),
            _buildMetricRow(
                'Z-axel',
                '${jumpData.rotationZ.toStringAsFixed(1)}°',
                Icons.rotate_right),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentCard() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Miljödata',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildMetricRow('Tid', dateFormat.format(jumpData.timestamp),
                Icons.access_time),
            _buildMetricRow(
                'Plats',
                '${jumpData.location.latitude.toStringAsFixed(4)}, ${jumpData.location.longitude.toStringAsFixed(4)}',
                Icons.location_on),
            _buildMetricRow(
                'Höjd över havet',
                '${jumpData.location.altitude.toStringAsFixed(1)} m',
                Icons.terrain),
            _buildMetricRow(
                'Temperatur',
                '${jumpData.weather.temperature.toStringAsFixed(1)}°C',
                Icons.thermostat),
            _buildMetricRow(
                'Väder', jumpData.weather.condition, Icons.wb_sunny),
            _buildMetricRow(
                'Vind',
                '${jumpData.weather.windSpeed.toStringAsFixed(1)} m/s',
                Icons.air),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pulsdata',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildMetricRow('Startpuls',
                '${jumpData.pulse.startPulse} slag/min', Icons.favorite),
            _buildMetricRow('Maxpuls', '${jumpData.pulse.maxPulse} slag/min',
                Icons.favorite),
            _buildMetricRow('Slutpuls', '${jumpData.pulse.endPulse} slag/min',
                Icons.favorite),
            _buildMetricRow(
                'Pulsökning',
                '${jumpData.pulse.maxPulse - jumpData.pulse.startPulse} slag/min',
                Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Poängfördelning',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barGroups: [
                    _createBarGroup(0,
                        (jumpData.height / 10.0 * 100).clamp(0, 100), 'Höjd'),
                    _createBarGroup(1, jumpData.stabilityScore, 'Stabilitet'),
                    _createBarGroup(2, _calculatePulseScore(), 'Puls'),
                    _createBarGroup(3, 75.0, 'Rotation'), // Simplified
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = [
                            'Höjd',
                            'Stabilitet',
                            'Puls',
                            'Rotation'
                          ];
                          if (value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                labels[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _createBarGroup(int x, double y, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreRating(double score) {
    if (score >= 90) return 'FANTASTISKT!';
    if (score >= 80) return 'UTMÄRKT!';
    if (score >= 70) return 'BRA!';
    if (score >= 60) return 'OKEJ';
    return 'FÖRSÖK IGEN';
  }

  double _calculatePulseScore() {
    final increase = jumpData.pulse.maxPulse - jumpData.pulse.startPulse;
    if (increase >= 30 && increase <= 60) return 100.0;
    if (increase < 30) return (increase / 30.0 * 100.0).clamp(0.0, 100.0);
    return (100.0 - (increase - 60) * 0.5).clamp(50.0, 100.0);
  }
}
