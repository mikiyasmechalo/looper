import 'package:isar/isar.dart';
import '../../library/domain/models/models.dart';
import '../../../core/db_service.dart';

class QueueRepository {
  static const int maxUserQueues = 10;
  static const String allSongsQueueName = 'All Songs';

  Future<List<SavedQueue>> loadAll() async {
    return DbService.isar.savedQueues
        .where()
        .sortByLastPlayedDesc()
        .findAll();
  }

  Future<SavedQueue?> findByName(String name) async {
    return DbService.isar.savedQueues
        .where()
        .nameEqualTo(name)
        .findFirst();
  }

  /// Upsert a queue. Evicts oldest non-permanent slot if cap (10) is reached.
  Future<void> save(SavedQueue queue) async {
    await DbService.isar.writeTxn(() async {
      final existing = await DbService.isar.savedQueues
          .where()
          .nameEqualTo(queue.name)
          .findFirst();

      if (existing != null) {
        queue.id = existing.id;
      } else if (!queue.isPermanent) {
        // Enforce max user queues limit (10)
        final userQueues = await DbService.isar.savedQueues
            .filter()
            .isPermanentEqualTo(false)
            .sortByLastPlayedDesc()
            .findAll();

        if (userQueues.length >= maxUserQueues) {
          final excessCount = userQueues.length - maxUserQueues + 1;
          for (int i = 0; i < excessCount; i++) {
            final oldestIndex = userQueues.length - 1 - i;
            if (oldestIndex >= 0) {
              await DbService.isar.savedQueues.delete(userQueues[oldestIndex].id);
            }
          }
        }
      }

      await DbService.isar.savedQueues.put(queue);
    });
  }

  Future<void> delete(String name) async {
    await DbService.isar.writeTxn(() async {
      final q = await DbService.isar.savedQueues
          .where()
          .nameEqualTo(name)
          .findFirst();
      if (q != null && !q.isPermanent) {
        await DbService.isar.savedQueues.delete(q.id);
      }
    });
  }
}
