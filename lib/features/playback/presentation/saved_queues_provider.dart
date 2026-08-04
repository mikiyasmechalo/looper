import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../library/domain/models/models.dart';
import '../../../core/db_service.dart';

final savedQueuesProvider = StreamProvider<List<SavedQueue>>((ref) {
  return DbService.isar.savedQueues
      .where()
      .sortByLastPlayedDesc()
      .watch(fireImmediately: true);
});
