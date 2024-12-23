import 'package:desd_app/widgets/base_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desd_app/screens/config/config_view_model.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfigViewModel(),
      child: Consumer<ConfigViewModel>(
        builder: (context, viewModel, child) {
          final TextEditingController controller = TextEditingController(text: viewModel.apiBaseUrl);

          return BasePageLayout(
            title: 'Config Page',
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter API Base URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      icon: Icon(Icons.link),
                      label: Text('API Base URL'),
                    ),
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      await viewModel.setApiBaseUrl(controller.text);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('API Base URL updated successfully.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    label: const Text('Guardar Cambios'),
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