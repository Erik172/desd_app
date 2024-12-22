import 'package:desd_app/screens/admin/admin_view_model.dart';
import 'package:desd_app/screens/user/add_user_form.dart';
import 'package:desd_app/widgets/base_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdminViewModel(context),
      child: Consumer<AdminViewModel>(
        builder: (context, viewModel, child) {
          return BasePageLayout(
            title: 'Admin',
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${viewModel.currentUser['name'] ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          viewModel.currentUser['email'] ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AddUserForm(
                                    onAddUser: (name, email, passwod) {
                                      viewModel.createUser({
                                        'name': name,
                                        'email': email,
                                        'password': passwod,
                                      });
                                    },
                                  );
                                },
                              );
                            },
                            child: const Text('Add User'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.users.length,
                      itemBuilder: (context, index) {
                        final user = viewModel.users[index];
                        final DateTime createdAt = DateTime.parse(user['created_at']);
                        final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user['name'],
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(width: 5),
                                        if (user['is_admin'])
                                          const Icon(
                                            Icons.admin_panel_settings,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    Text(
                                      user['email'],
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Created at: $formattedDate',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Theme.of(context).colorScheme.error,
                                  splashRadius: 20,
                                  iconSize: 20,
                                  onPressed: () {
                                    viewModel.deleteUser(user['id']);
                                  },
                                ),
                              ],
                            ),
                            const Divider(),
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
