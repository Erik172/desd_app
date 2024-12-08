import 'package:desd_app/screens/resultados/resultados_view_model.dart';
import 'package:desd_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultadosPage extends StatelessWidget {
  const ResultadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ResultadosViewModel(context),
      child: Consumer<ResultadosViewModel>(
        builder: (context, viewModel, child) {
          return BasePageLayout(
            title: 'Resultados',
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Total de resultados: ${viewModel.totalResults}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: viewModel.results.isEmpty && viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            controller: viewModel.scrollController,
                            itemCount: viewModel.results.length +
                                (viewModel.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= viewModel.results.length) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                          viewModel.results[index]
                                              ['collection_id'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Icon(
                                        Icons.circle,
                                        color: viewModel.getStatusColor(
                                            viewModel.results[index]['status']
                                                ['status'],
                                            context),
                                        size: 10,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        viewModel.results[index]['status']
                                            ['status'],
                                        style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.fontSize,
                                          fontFamily: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.fontFamily,
                                          fontWeight: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.fontWeight,
                                          color: viewModel.getStatusColor(
                                              viewModel.results[index]['status']
                                                  ['status'],
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Fecha de Inicio: ${viewModel.formatDate(viewModel.results[index]['created_at'])}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(' | '),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          'Ultima Actualizacion: ${viewModel.formatDate(viewModel.results[index]['status']['last_updated_at'])}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Duración: ${viewModel.calculateDuration(viewModel.results[index]['created_at'], viewModel.results[index]['status']['last_updated_at'])}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        Icons.article,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          'Total de documentos: ${viewModel.results[index]['status']['total_files']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.check_circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          'Documentos procesados: ${viewModel.results[index]['status']['total_files_processed']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (viewModel.results[index]['status']['status'] == 'RUNNING')
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center, // Centrar el texto sobre la barra
                                          children: [
                                            LinearProgressIndicator(
                                              value: viewModel.results[index]['status']['total_files_processed'] / viewModel.results[index]['status']['total_files'],
                                              backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                              color: Theme.of(context).colorScheme.primaryContainer,
                                              valueColor:AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                              minHeight: 21,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.surface.withOpacity(0.25),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                '${((viewModel.results[index]['status']['total_files_processed'] / viewModel.results[index]['status']['total_files']) * 100).toStringAsFixed(0)}% - ${viewModel.results[index]['status']['current_file']}',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSurface,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.download),
                                        label: const Text('Descargar'),
                                        onPressed: () {
                                          viewModel.downloadResult(
                                              collectionId:
                                                  viewModel.results[index]
                                                      ['collection_id']);
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      if (viewModel.results[index]['status']['status'] != 'RUNNING')
                                        TextButton.icon(
                                          icon: const Icon(Icons.delete),
                                          label: const Text('Eliminar'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                          onPressed: () {
                                            viewModel.deleteResult(
                                                collectionId:
                                                    viewModel.results[index]
                                                        ['collection_id']);
                                            context
                                                .read<ResultadosViewModel>()
                                                .results
                                                .removeAt(index);
                                          },
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Divider(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    thickness: 1,
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
