import 'package:flutter/services.dart';
import 'package:desd_app/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desd_app/screens/auditoria/auditoria_view_model.dart';
import 'package:provider/provider.dart';

class AuditoriaPage extends StatelessWidget {
  const AuditoriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuditoriaViewModel(),
      child: Consumer<AuditoriaViewModel>(
        builder: (context, viewModel, child) {
          return BasePageLayout(
            title: 'Auditoria',
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                viewModel.reset();
              },
              child: const Icon(Icons.refresh),
            ),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${viewModel.numFiles} archivos seleccionados',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: viewModel.pickDirectory,
                                icon: const Icon(Icons.folder_open),
                                label: const Text(kIsWeb ? 'Seleccionar archivos' : 'Seleccionar directorio'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(400, 70),
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (viewModel.selectedDirectory != null)
                                Text(
                                  'Path: ${viewModel.selectedDirectory}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Seleccionar modelos a usar: ',
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
                                    onSelected: (value) {
                                      viewModel.toggleModelSelection(model);
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (viewModel.selectedDirectory != null && viewModel.selectedModels.isNotEmpty)
                      ElevatedButton(
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
                      ),
                    if (viewModel.resultId != null)
                      Column(
                        children: <Widget>[
                          const SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Text(
                                'ID de los resultados: ',
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
                                    const SnackBar(
                                      content: Text('ID copiado al portapapeles.'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          
                        ],
                      ),

                    if (viewModel.isProcessing)
                      Column(
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
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}