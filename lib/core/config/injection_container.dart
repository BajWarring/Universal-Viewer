import 'package:get_it/get_it.dart';
import '../../filesystem/domain/repositories/file_system_provider.dart';
import '../../filesystem/data/providers/local_file_system_provider.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<FileSystemProvider>(
    () => LocalFileSystemProvider(),
    instanceName: 'local',
  );
}
