import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:provider/provider.dart';
import 'data/models/task.dart';
import 'data/repositories/task_repository.dart';
import 'logic/bloc/task_bloc.dart';
import 'logic/theme_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  final taskRepository = TaskRepository();
  await taskRepository.initialize();
  runApp(MyApp(taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;

  const MyApp({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DeadlineFlow',
            theme: themeProvider.getLightTheme(),
            darkTheme: themeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: BlocProvider(
              create: (_) => TaskBloc(repository: taskRepository),
              child: const HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}
