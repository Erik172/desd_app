import 'package:flutter/material.dart';

class AlgoritmosCard extends StatelessWidget {
  const AlgoritmosCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(Icons.code, color: colorScheme.secondary, size: 20),
                const SizedBox(width: 5),
                Text('Algoritmos', style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildModelItem(Icons.copy, 'DuDe - Detección de Duplicidad', colorScheme, textTheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelItem(IconData icon, String text, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.secondary, size: 20),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text, style: textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}
