import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../entities/care_entities.dart';
import '../repositories/care_repository.dart';

class GetTreatmentUseCase {
  final CareRepository repository;
  GetTreatmentUseCase(this.repository);

  Future<Either<ApiException, TreatmentEntity>> call() {
    return repository.getTreatment();
  }
}

class SetupTreatmentUseCase {
  final CareRepository repository;
  SetupTreatmentUseCase(this.repository);

  Future<Either<ApiException, TreatmentEntity>> call(String timezone, String startDate) {
    return repository.createTreatment({
      'start_date': startDate,
      'timezone': timezone,
      'reminder_enabled': true,
    });
  }
}

class UpdateTreatmentReminderUseCase {
  final CareRepository repository;
  UpdateTreatmentReminderUseCase(this.repository);

  Future<Either<ApiException, TreatmentEntity>> call(String startDate, String timezone, bool reminderEnabled) {
    return repository.updateTreatment({
      'start_date': startDate,
      'timezone': timezone,
      'reminder_enabled': reminderEnabled,
    });
  }
}

class DeleteTreatmentUseCase {
  final CareRepository repository;
  DeleteTreatmentUseCase(this.repository);

  Future<Either<ApiException, void>> call() {
    return repository.deleteTreatment();
  }
}

class GetSchedulesUseCase {
  final CareRepository repository;
  GetSchedulesUseCase(this.repository);

  Future<Either<ApiException, List<ScheduleEntity>>> call() {
    return repository.getSchedules();
  }
}

class AddScheduleUseCase {
  final CareRepository repository;
  AddScheduleUseCase(this.repository);

  Future<Either<ApiException, ScheduleEntity>> call(String reminderTime) {
    return repository.addSchedule(reminderTime);
  }
}

class UpdateScheduleUseCase {
  final CareRepository repository;
  UpdateScheduleUseCase(this.repository);

  Future<Either<ApiException, ScheduleEntity>> call(String scheduleId, String reminderTime, bool isActive) {
    return repository.updateSchedule(scheduleId, {
      'reminder_time': reminderTime,
      'is_active': isActive,
    });
  }
}

class DeleteScheduleUseCase {
  final CareRepository repository;
  DeleteScheduleUseCase(this.repository);

  Future<Either<ApiException, void>> call(String scheduleId) {
    return repository.deleteSchedule(scheduleId);
  }
}

class ConfirmMedicationUseCase {
  final CareRepository repository;
  ConfirmMedicationUseCase(this.repository);

  Future<Either<ApiException, LogEntity>> call(String scheduleId, String date) {
    return repository.confirmMedication(scheduleId, date);
  }
}

class GetHistoryUseCase {
  final CareRepository repository;
  GetHistoryUseCase(this.repository);

  Future<Either<ApiException, List<LogEntity>>> call(String startDate, String endDate) {
    return repository.getHistory(startDate, endDate);
  }
}

class GetStatisticsUseCase {
  final CareRepository repository;
  GetStatisticsUseCase(this.repository);

  Future<Either<ApiException, CareStatisticsEntity>> call() {
    return repository.getStatistics();
  }
}
