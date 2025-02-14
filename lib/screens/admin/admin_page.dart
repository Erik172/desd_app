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
              child: Column(
                children: [
                  _buildWelcomeSection(viewModel, context),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: _buildUserSection(viewModel, context),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          flex: 1,
                          child: _buildIpSection(viewModel, context),
                        ),
                      ],
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

  Widget _buildWelcomeSection(AdminViewModel viewModel, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${viewModel.currentUser['username'] ?? ''}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildUserSection(AdminViewModel viewModel, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Users',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  onPressed: () => _showAddUserDialog(context, viewModel),
                  child: const Text('Add User'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildUserList(viewModel, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIpSection(AdminViewModel viewModel, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allowed IPs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  onPressed: () => _showAddIpDialog(context, viewModel),
                  child: const Text('Add IP'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildIpList(viewModel, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(AdminViewModel viewModel, BuildContext context) {
    return ListView.separated(
      itemCount: viewModel.users.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final user = viewModel.users[index];
        final DateTime createdAt = DateTime.parse(user['created_at']);
        final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

        return _buildUserListItem(user, formattedDate, viewModel, context);
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user, String formattedDate, AdminViewModel viewModel, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  user['username'],
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
              'Created at: $formattedDate',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.admin_panel_settings,
                color: user['is_admin'] ? Colors.red : Colors.grey,
              ),
              splashRadius: 20,
              iconSize: 20,
              onPressed: () => viewModel.switchAdminRole(user['id'].toString()),
            ),
            const SizedBox(width: 2),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
              splashRadius: 20,
              iconSize: 20,
              onPressed: () => viewModel.deleteUser(user['id']),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIpList(AdminViewModel viewModel, BuildContext context) {
    return ListView.separated(
      itemCount: viewModel.allowedIps['allowed_ips']?.length ?? 0,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final ip = viewModel.allowedIps['allowed_ips'][index];
        final DateTime createdAt = DateTime.parse(ip['created_at']);
        return _buildIpListItem(ip['ip'], ip['is_active'], createdAt, viewModel, context);
      },
    );
  }

  Widget _buildIpListItem(String ip, bool active, DateTime createdAt, AdminViewModel viewModel, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  ip,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 15),
                _buildIpStatus(active),
              ],
            ),
            Text(
              'Created at: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}',
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
            final idIp = viewModel.allowedIps['allowed_ips'].firstWhere((element) => element['ip'] == ip)['id'];
            viewModel.deleteAllowedIp(idIp);
          },
        ),
      ],
    );
  }

  Widget _buildIpStatus(bool active) {
    return active
        ? const Row(
            children: [
              Text(
                'Active ',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 12,
              ),
            ],
          )
        : const Row(
            children: [
              Text(
                'Inactive ',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 12,
              ),
            ],
          );
  }

  void _showAddUserDialog(BuildContext context, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AddUserForm(
          onAddUser: (username, password) {
            viewModel.createUser({
              'username': username,
              'password': password,
            });
          },
        );
      },
    );
  }

  void _showAddIpDialog(BuildContext context, AdminViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        String ipAddress = '';
        return AlertDialog(
          title: const Text('Add IP Address'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'IP Address'),
            onChanged: (value) => ipAddress = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                viewModel.addAllowedIp(ipAddress);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}