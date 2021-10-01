import 'package:flutter/material.dart';
import 'package:fsbackup/app_injector.dart';

import 'package:fsbackup/repositories/backup_routine_repository.dart';
import 'package:fsbackup/services/backup_service.dart';
import 'package:fsbackup_shared/fsbackup_shared.dart';

class FilaProvider extends ChangeNotifier {
  final BackupRoutineRepository repository;
  List<BackupRoutineModel> routines = <BackupRoutineModel>[];
  FilaProvider(this.repository);

  void updateUi() {
    notifyListeners();
  }

  Future<void> stop() async {
    locator<BackupService>().stop();
  }

  Future<void> start() async {
    locator<BackupService>().start();
  }

  Future<List<BackupRoutineModel>> getAll() async {
    return routines;
  }
}
