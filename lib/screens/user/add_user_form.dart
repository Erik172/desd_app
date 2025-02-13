import 'package:flutter/material.dart';

class AddUserForm extends StatefulWidget {
  final Function(String, String) onAddUser;

  const AddUserForm({super.key, required this.onAddUser});

  @override
  // ignore: library_private_types_in_public_api
  _AddUserFormState createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an username';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAddUser(_usernameController.text, _passwordController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
