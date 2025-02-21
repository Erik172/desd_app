import 'package:desd_app/screens/duplicate/duplicate_view_model.dart';
import 'package:flutter/services.dart';
import 'package:desd_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auditoria/widgets/directory_picker.dart';

class DuplicatePage extends StatelessWidget {
  const DuplicatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DuplicateViewModel(),
      child: Consumer<DuplicateViewModel>(
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
                      _ProcessButton(viewModel: viewModel),
                      if (viewModel.resultId != null) _ResultId(viewModel: viewModel),
                      // if (viewModel.isProcessing) ProgressIndicatorWidget(viewModel: viewModel),
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

class _ProcessButton extends StatelessWidget {
  final DuplicateViewModel viewModel;
  const _ProcessButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
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
          : const Text('Buscar archivos duplicados'),
    );
  }
}

class _ResultId extends StatelessWidget {
  final DuplicateViewModel viewModel;
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

