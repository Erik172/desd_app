import 'package:flutter/material.dart';

class ModelosCard extends StatelessWidget {
  const ModelosCard({super.key});

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
                Icon(Icons.smart_toy, color: colorScheme.secondary, size: 22),
                const SizedBox(width: 5),
                Text('Modelos de AI', style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildModelItem(Icons.rotate_left, 'RoDe - Detección de Rotación', colorScheme, textTheme),
                _buildModelItem(Icons.document_scanner, 'TilDe - Detección de Inclinación', colorScheme, textTheme),
                _buildModelItem(Icons.crop, 'CuDe - Detección de Corte de Información', colorScheme, textTheme),
                _buildModelItem(Icons.loupe, 'Legibilty - Detección de Documentos inlegibles', colorScheme, textTheme),
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
          Text(text, style: textTheme.labelMedium),
        ],
      ),
    );
  }
}
