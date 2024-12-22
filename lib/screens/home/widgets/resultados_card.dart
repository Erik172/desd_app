import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultadosCard extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final viewModel;

  const ResultadosCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Resultados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                  size: 22,
                ),
                const SizedBox(width: 5),
                Text(
                  'Pendientes: ${viewModel.numResultsPending}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.run_circle,
                  color: Colors.blue,
                  size: 22,
                ),
                const SizedBox(width: 5),
                Text(
                  'Corriendo: ${viewModel.numResultsRunning}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 22,
                ),
                const SizedBox(width: 5),
                Text(
                  'Completados: ${viewModel.numResultsCompleted}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                  size: 22,
                ),
                const SizedBox(width: 5),
                Text(
                  'Fallidos: ${viewModel.numResultsFailed}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                context.push('/resultados');
              },
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.secondary,
              ),
              label: Text(
                'Ver resultados',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}