import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart';
import 'features/address/presentation/bloc/address_state.dart';
import 'features/address/presentation/pages/address_page.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/todo/presentation/bloc/todo_state.dart';
import 'features/todo/presentation/pages/todo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<TodoProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AddressProvider>()),
      ],
      child: MaterialApp(
        title: 'Clean Flutter (Enterprise Demo)',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return authProvider.isAuthenticated
                ? const TodoPage()
                : const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/todo': (context) => const TodoPage(),
          '/address': (context) => const AddressPage(),
        },
      ),
    );
  }
}
