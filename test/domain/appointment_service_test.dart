import 'package:flutter_test/flutter_test.dart';
import 'package:vida_plena_agenda/domain/appointment.dart';
import 'package:vida_plena_agenda/domain/appointment_service.dart';
import 'package:vida_plena_agenda/domain/domain_exception.dart';

void main() {
  final now = DateTime(2026, 10, 6, 12);
  final future = DateTime(2026, 10, 10, 9);
  final other = DateTime(2026, 10, 11, 9);
  final past = DateTime(2026, 10, 1, 9);
  late AppointmentService service;

  Appointment make({
    String id = 'a1',
    String doctorId = 'd1',
    DateTime? dateTime,
    AppointmentStatus status = AppointmentStatus.agendada,
  }) =>
      Appointment(
        id: id,
        patientId: 'p1',
        doctorId: doctorId,
        dateTime: dateTime ?? future,
        status: status,
      );

  setUp(() => service = AppointmentService(clock: () => now));

  group('criar', () {
    test('cria consulta agendada em horário livre', () {
      final a = service.create(
        existing: [],
        id: 'a1',
        patientId: 'p1',
        doctorId: 'd1',
        dateTime: future,
      );
      expect(a.status, AppointmentStatus.agendada);
      expect(a.dateTime, future);
    });

    test('bloqueia mesmo profissional e mesmo horário', () {
      expect(
        () => service.create(
          existing: [make()],
          id: 'a2',
          patientId: 'p2',
          doctorId: 'd1',
          dateTime: future,
        ),
        throwsA(isA<DomainException>()),
      );
    });

    test('permite outro profissional no mesmo horário', () {
      expect(
        () => service.create(
          existing: [make()],
          id: 'a2',
          patientId: 'p2',
          doctorId: 'd2',
          dateTime: future,
        ),
        returnsNormally,
      );
    });

    test('permite horário de consulta cancelada', () {
      expect(
        () => service.create(
          existing: [make(status: AppointmentStatus.cancelada)],
          id: 'a2',
          patientId: 'p2',
          doctorId: 'd1',
          dateTime: future,
        ),
        returnsNormally,
      );
    });

    test('rejeita horário no passado', () {
      expect(
        () => service.create(
          existing: [],
          id: 'a1',
          patientId: 'p1',
          doctorId: 'd1',
          dateTime: past,
        ),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('confirmar', () {
    test('muda status para confirmada', () {
      expect(service.confirm(make()).status, AppointmentStatus.confirmada);
    });

    test('rejeita se já confirmada', () {
      expect(
        () => service.confirm(make(status: AppointmentStatus.confirmada)),
        throwsA(isA<DomainException>()),
      );
    });
  });

  group('cancelar', () {
    test('cancela consulta futura', () {
      expect(service.cancel(make()).status, AppointmentStatus.cancelada);
    });

    test('cancela consulta confirmada futura', () {
      final a = make(status: AppointmentStatus.confirmada);
      expect(service.cancel(a).status, AppointmentStatus.cancelada);
    });

    test('rejeita consulta passada', () {
      expect(
        () => service.cancel(make(dateTime: past)),
        throwsA(isA<DomainException>()),
      );
    });

    test('rejeita consulta já cancelada ou realizada', () {
      for (final s in [AppointmentStatus.cancelada, AppointmentStatus.realizada]) {
        expect(
          () => service.cancel(make(status: s)),
          throwsA(isA<DomainException>()),
        );
      }
    });
  });

  group('remarcar', () {
    test('remarca consulta futura e volta para agendada', () {
      final a = make(status: AppointmentStatus.confirmada);
      final r = service.reschedule(
        existing: [a],
        appointment: a,
        newDateTime: other,
      );
      expect(r.dateTime, other);
      expect(r.status, AppointmentStatus.agendada);
    });

    test('rejeita consulta passada', () {
      final a = make(dateTime: past);
      expect(
        () => service.reschedule(existing: [a], appointment: a, newDateTime: other),
        throwsA(isA<DomainException>()),
      );
    });

    test('rejeita novo horário no passado', () {
      final a = make();
      expect(
        () => service.reschedule(existing: [a], appointment: a, newDateTime: past),
        throwsA(isA<DomainException>()),
      );
    });

    test('rejeita conflito com outra consulta do profissional', () {
      final a = make();
      final b = make(id: 'a2', dateTime: other);
      expect(
        () => service.reschedule(existing: [a, b], appointment: a, newDateTime: other),
        throwsA(isA<DomainException>()),
      );
    });

    test('não conflita com o próprio horário', () {
      final a = make();
      expect(
        () => service.reschedule(existing: [a], appointment: a, newDateTime: future),
        returnsNormally,
      );
    });

    test('rejeita consulta cancelada', () {
      final a = make(status: AppointmentStatus.cancelada);
      expect(
        () => service.reschedule(existing: [a], appointment: a, newDateTime: other),
        throwsA(isA<DomainException>()),
      );
    });
  });
}
