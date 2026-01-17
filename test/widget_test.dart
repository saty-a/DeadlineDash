import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deadlinedash/main.dart';
import 'package:deadlinedash/data/repositories/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    final taskRepository = TaskRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(taskRepository: taskRepository));

    // Verify that the title is present
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
