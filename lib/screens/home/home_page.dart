import 'package:desd_app/screens/home/home_view_model.dart';
import 'package:desd_app/screens/home/widgets/modelos_card.dart';
import 'package:desd_app/screens/home/widgets/resultados_card.dart';
import 'package:desd_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(context),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return BasePageLayout(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bienvenido, ${viewModel.userInfo['username'] ?? ''}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      viewModel.userInfo['email'] ?? '',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          // Pantalla pequeña: mostrar las tarjetas en una columna
                          return Column(
                            children: [
                              ResultadosCard(viewModel: viewModel,),
                              const SizedBox(height: 20),
                              const ModelosCard(),
                            ],
                          );
                        } else {
                          // Pantalla grande: mostrar las tarjetas en una fila
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: ResultadosCard(viewModel: viewModel,)),
                              const SizedBox(width: 20),
                              const Expanded(child: ModelosCard()),
                            ],
                          );
                        }
                      },
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
