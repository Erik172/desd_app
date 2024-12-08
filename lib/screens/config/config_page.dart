import 'package:desd_app/widgets/base_page_layout.dart';
import 'package:flutter/material.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePageLayout(
      title: 'Config Page',
      child: Text('Config Page')
    );
  }
}