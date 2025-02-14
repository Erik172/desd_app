import 'package:flutter/services.dart';
import 'package:desd_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:desd_app/screens/auditoria/auditoria_view_model.dart';
import 'package:provider/provider.dart';
import 'widgets/widgets.dart';

class AuditoriaPage extends StatelessWidget {
  const AuditoriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuditoriaViewModel(),
      child: Consumer<AuditoriaViewModel>(
        builder: (context, viewModel, child) {
          return BasePageLayout(
            title: 'Auditoría',
            floatingActionButton: FloatingActionButton(
              onPressed: viewModel.reset,
              child: const Icon(Icons.refresh),
            ),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // _DirectoryPicker(viewModel: viewModel),
                      DirectoryPicker(viewModel: viewModel),
                      const SizedBox(height: 20),
                      _ModelSelector(viewModel: viewModel),
                      const SizedBox(height: 20),
                      _ProcessButton(viewModel: viewModel),
                      if (viewModel.resultId != null) _ResultId(viewModel: viewModel),
                      if (viewModel.isProcessing) ProgressIndicatorWidget(viewModel: viewModel),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------
// COMPONENTES SEPARADOS
// -----------------------

class _ModelSelector extends StatelessWidget {
  final AuditoriaViewModel viewModel;
  const _ModelSelector({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Seleccionar modelos a usar:',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: viewModel.models.map((model) {
            final isSelected = viewModel.selectedModels.contains(model);
            return ChoiceChip(
              label: Text(model),
              selected: isSelected,
              onSelected: (_) => viewModel.toggleModelSelection(model),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProcessButton extends StatelessWidget {
  final AuditoriaViewModel viewModel;
  const _ProcessButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.selectedDirectory == null || viewModel.selectedModels.isEmpty) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: viewModel.isProcessing ? null : () => viewModel.processFiles(context),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 70),
      ),
      child: viewModel.isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('Procesar archivos'),
    );
  }
}

class _ResultId extends StatelessWidget {
  final AuditoriaViewModel viewModel;
  const _ResultId({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Text(
              'ID de los resultados:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: SelectableText(
                viewModel.resultId!,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: viewModel.resultId ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID copiado al portapapeles.')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

