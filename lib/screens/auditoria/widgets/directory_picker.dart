import 'package:desd_app/screens/auditoria/auditoria_view_model.dart';
import 'package:flutter/material.dart';

class DirectoryPicker extends StatelessWidget {
  final AuditoriaViewModel viewModel;
  const DirectoryPicker({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${viewModel.numFiles} archivos seleccionados',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: viewModel.pickDirectory,
          icon: const Icon(Icons.folder_open),
          label: const Text('Seleccionar directorio'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(400, 70),
          ),
        ),
        if (viewModel.selectedDirectory != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'Path: ${viewModel.selectedDirectory}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}