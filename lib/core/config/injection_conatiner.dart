import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> initializeDependencies() async {
  // We will register our File System repositories, local databases (Drift), 
  // and isolated workers (Workmanager) here in upcoming phases.
  
  // Example:
  // sl.registerLazySingleton<FileRepository>(() => LocalFileRepositoryImpl());
}
