import 'package:uuid/uuid.dart';

/// Generates stable, collision-safe IDs for every entity.
///
/// UUIDs (rather than auto-increment integers) are used so records keep the
/// same identity when a future cloud-sync phase uploads them to Supabase —
/// no ID remapping needed between the local database and the server.
class IdGenerator {
  static const _uuid = Uuid();

  static String generate() => _uuid.v4();
}
