import 'package:desd_app/screens/auth/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(context),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth > 600 ? 400 : double.infinity;
                  return SingleChildScrollView(
                    child: Container(
                      width: width,
                      padding: const EdgeInsets.all(40),
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            TextFormField(
                              controller: viewModel.emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                                )
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            TextFormField(
                              controller: viewModel.passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                                )
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            ElevatedButton(
                              onPressed: () {
                                viewModel.login();
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 60),
                              ),
                              child: const Text('Login'),
                            ),
                            if (viewModel.isLoading) const CircularProgressIndicator(),
                            if (viewModel.errorMessage != null) Text(viewModel.errorMessage!),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}