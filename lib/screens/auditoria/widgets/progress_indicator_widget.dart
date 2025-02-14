import 'package:desd_app/screens/auditoria/auditoria_view_model.dart';
import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final AuditoriaViewModel viewModel;
  const ProgressIndicatorWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: viewModel.progress,
          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          color: Theme.of(context).colorScheme.primaryContainer,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          minHeight: 21,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 10),
        Text(
          '${(viewModel.progress * 100).toStringAsFixed(0)}% - ${viewModel.currentFile}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}