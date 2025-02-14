import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultadosCard extends StatelessWidget {
  final dynamic viewModel; // Idealmente, reemplázalo con el tipo correcto.

  const ResultadosCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Resultados',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            _ResultRow(
              icon: Icons.upload,
              color: Colors.purple,
              text: 'Subiendo',
              count: viewModel.numResultsUploading,
            ),
            _ResultRow(
              icon: Icons.pending_actions,
              color: Colors.orange,
              text: 'Pendientes',
              count: viewModel.numResultsPending,
            ),
            _ResultRow(
              icon: Icons.run_circle,
              color: Colors.blue,
              text: 'Corriendo',
              count: viewModel.numResultsRunning,
            ),
            _ResultRow(
              icon: Icons.check_circle,
              color: Colors.green,
              text: 'Completados',
              count: viewModel.numResultsCompleted,
            ),
            _ResultRow(
              icon: Icons.error,
              color: theme.colorScheme.error,
              text: 'Fallidos',
              count: viewModel.numResultsFailed,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => context.push('/resultados'),
              icon: Icon(
                Icons.arrow_forward,
                color: theme.colorScheme.secondary,
              ),
              label: Text(
                'Ver resultados',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------
// WIDGET AUXILIAR
// -----------------------
class _ResultRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final int count;

  const _ResultRow({
    required this.icon,
    required this.color,
    required this.text,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 5),
          Text(
            '$text: $count',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
