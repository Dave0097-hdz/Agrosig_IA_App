import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/provider/weekly_summary_provider.dart';

class WeeklySummaryWidget extends ConsumerWidget {
  const WeeklySummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklySummaryAsync = ref.watch(weeklySummaryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen del Mes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        weeklySummaryAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
          data: (summaryData) => _buildSummaryCards(summaryData),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        Expanded(child: _buildSkeletonCard()),
        const SizedBox(width: 8),
        Expanded(child: _buildSkeletonCard()),
        const SizedBox(width: 8),
        Expanded(child: _buildSkeletonCard()),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 16,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 12,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error al cargar el resumen',
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(WeeklySummaryData data) {
    return Row(
      children: [
        _buildMetricCard(
          icon: '💧',
          value: _formatWater(data.waterUsed),
          label: 'Agua usada',
        ),
        const SizedBox(width: 8),
        _buildMetricCard(
          icon: '🌱',
          value: '${data.activeCrops}',
          label: data.activeCrops == 1 ? 'Cultivo activo' : 'Cultivos activos',
        ),
        const SizedBox(width: 8),
        _buildMetricCard(
          icon: '💰',
          value: _formatCost(data.monthlyCost),
          label: 'Costos del mes',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatWater(double liters) {
    if (liters >= 1000) {
      return '${(liters / 1000).toStringAsFixed(1)}m³';
    }
    return '${liters.toStringAsFixed(0)}L';
  }

  String _formatCost(double cost) {
    if (cost >= 1000) {
      return '\$${(cost / 1000).toStringAsFixed(1)}K';
    }
    return '\$${cost.toStringAsFixed(0)}';
  }
}