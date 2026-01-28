import 'package:hive_ce/hive_ce.dart';
import 'package:deadlineflow/data/models/task.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(TaskAdapter());
  }
}

extension IsolatedHiveRegistrar on IsolatedHiveInterface {
  void registerAdapters() {
    registerAdapter(TaskAdapter());
  }
}
