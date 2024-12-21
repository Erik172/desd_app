import 'package:desd_app/screens/home/home_view_model.dart';
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
      create: (context) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return BasePageLayout(
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bienvenido, ${viewModel.user['name']}',
                    style: Theme.of(context).textTheme.titleLarge,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
