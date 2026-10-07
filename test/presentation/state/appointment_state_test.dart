import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vida_plena_agenda/data/appointment_repository.dart';
import 'package:vida_plena_agenda/data/catalog_repository.dart';
import 'package:vida_plena_agenda/data/reminder_scheduler.dart';
import 'package:vida_plena_agenda/domain/appointment.dart';
import 'package:vida_plena_agenda/domain/doctor.dart';
import 'package:vida_plena_agenda/domain/specialty.dart';
import 'package:vida_plena_agenda/presentation/state/appointment_state.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

class MockCatalogRepository extends Mock implements CatalogRepository {}

class MockReminderScheduler extends Mock implements ReminderScheduler {}

void main() {
  final now = DateTime(2026, 10, 6, 12); // terça-feira
  final friday = DateTime(2026, 10, 9, 9);
  final saturday = DateTime(2026, 10, 10, 9);
  const doctor = Doctor(id: 'd1', name: 'Dra. Ana', specialtyId: 's1');
  const other = Doctor(id: 'd2', name: 'Dr. Beto', specialtyId: 's2');

  Appointment make(String id, {String patientId = 'p1', DateTime? at, AppointmentStatus status = AppointmentStatus.agendada}) =>
      Appointment(id: id, patientId: patientId, doctorId: 'd1', dateTime: at ?? friday, status: status);

  late MockAppointmentRepository appointments;
  late MockCatalogRepository catalog;
  late AppointmentState state;

  setUpAll(() => registerFallbackValue(make('x')));

  Future<void> loadWith(List<Appointment> stored) async {
    when(() => appointments.getAll()).thenAnswer((_) async => stored);
    await state.load('p1');
  }

  setUp(() {
    appointments = MockAppointmentRepository();
    catalog = MockCatalogRepository();
    when(() => catalog.getSpecialties()).thenAnswer((_) async => [const Specialty(id: 's1', name: 'Clínica Geral')]);
    when(() => catalog.getDoctors()).thenAnswer((_) async => [doctor, other]);
    when(() => appointments.save(any())).thenAnswer((_) async {});
    state = AppointmentState(appointments, catalog, clock: () => now, idGenerator: () => 'novo');
  });

  group('carregar', () {
    test('expõe catálogo e só as consultas do paciente', () async {
      await loadWith([make('a1'), make('a2', patientId: 'p2')]);
      expect(state.specialties, hasLength(1));
      expect(state.doctors, hasLength(2));
      expect(state.appointments.map((a) => a.id), ['a1']);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('erro do repositório vira mensagem e encerra loading', () async {
      when(() => appointments.getAll()).thenThrow(Exception('disco'));
      await state.load('p1');
      expect(state.error, isNotNull);
      expect(state.isLoading, isFalse);
    });

    test('doctorsFor filtra por especialidade', () async {
      await loadWith([]);
      expect(state.doctorsFor('s2'), [other]);
    });
  });

  group('listas', () {
    test('separa futuras e histórico', () async {
      await loadWith([
        make('futura'),
        make('passada', at: DateTime(2026, 10, 1, 9)),
        make('cancelada', status: AppointmentStatus.cancelada),
        make('realizada', at: DateTime(2026, 9, 1, 9), status: AppointmentStatus.realizada),
      ]);
      expect(state.upcoming.map((a) => a.id), ['futura']);
      // mais recente primeiro
      expect(state.history.map((a) => a.id), ['cancelada', 'passada', 'realizada']);
    });
  });

  group('horários livres', () {
    test('exclui ocupados e passados', () async {
      await loadWith([make('a1')]); // d1 sexta 9h ocupado
      final slots = state.availableSlots(doctor, friday);
      expect(slots, isNot(contains(friday)));
      expect(slots, contains(DateTime(2026, 10, 9, 10)));
      expect(state.availableSlots(doctor, DateTime(2026, 10, 6)).any((s) => s.hour < 12), isFalse);
    });

    test('cancelada libera o horário', () async {
      await loadWith([make('a1', status: AppointmentStatus.cancelada)]);
      expect(state.availableSlots(doctor, friday), contains(friday));
    });

    test('vazio em dia sem atendimento', () async {
      await loadWith([]);
      expect(state.availableSlots(doctor, saturday), isEmpty);
    });
  });

  group('ações', () {
    test('book salva e adiciona à lista', () async {
      await loadWith([]);
      expect(await state.book(doctor, friday), isTrue);
      expect(state.upcoming.single.id, 'novo');
      verify(() => appointments.save(any())).called(1);
    });

    test('book em horário ocupado falha com erro e sem salvar', () async {
      await loadWith([make('a1')]);
      expect(await state.book(doctor, friday), isFalse);
      expect(state.error, isNotNull);
      verifyNever(() => appointments.save(any()));
    });

    test('book sem paciente carregado pede login', () async {
      expect(await state.book(doctor, friday), isFalse);
      expect(state.error, contains('login'));
    });

    test('confirm muda status', () async {
      await loadWith([make('a1')]);
      expect(await state.confirm('a1'), isTrue);
      expect(state.appointments.single.status, AppointmentStatus.confirmada);
    });

    test('cancel move a consulta para o histórico', () async {
      await loadWith([make('a1')]);
      expect(await state.cancel('a1'), isTrue);
      expect(state.upcoming, isEmpty);
      expect(state.history.single.status, AppointmentStatus.cancelada);
    });

    test('cancel de consulta passada falha', () async {
      await loadWith([make('a1', at: DateTime(2026, 10, 1, 9))]);
      expect(await state.cancel('a1'), isFalse);
      expect(state.error, isNotNull);
      verifyNever(() => appointments.save(any()));
    });

    test('reschedule troca o horário', () async {
      await loadWith([make('a1')]);
      final novo = DateTime(2026, 10, 9, 10);
      expect(await state.reschedule('a1', novo), isTrue);
      expect(state.appointments.single.dateTime, novo);
    });

    test('id inexistente gera erro', () async {
      await loadWith([]);
      expect(await state.cancel('nada'), isFalse);
      expect(state.error, 'Consulta não encontrada.');
    });

    test('reset limpa dados do paciente', () async {
      await loadWith([make('a1')]);
      state.reset();
      expect(state.appointments, isEmpty);
    });
  });
  group('lembretes (RF07)', () {
    late MockReminderScheduler reminders;

    setUp(() {
      reminders = MockReminderScheduler();
      when(() => reminders.schedule(any(), at: any(named: 'at'), doctorName: any(named: 'doctorName')))
          .thenAnswer((_) async {});
      when(() => reminders.cancel(any())).thenAnswer((_) async {});
      state = AppointmentState(appointments, catalog,
          clock: () => now, idGenerator: () => 'novo', reminders: reminders);
    });

    test('agendar programa lembrete 24 h antes', () async {
      await loadWith([]);
      expect(await state.book(doctor, friday), isTrue);
      verify(() => reminders.schedule(any(),
          at: DateTime(2026, 10, 8, 9), doctorName: 'Dra. Ana')).called(1);
    });

    test('cancelar remove o lembrete', () async {
      await loadWith([make('a1')]);
      await state.cancel('a1');
      verify(() => reminders.cancel('a1')).called(1);
    });

    test('remarcar reprograma para o novo horário', () async {
      await loadWith([make('a1')]);
      await state.reschedule('a1', DateTime(2026, 10, 9, 10));
      verify(() => reminders.schedule(any(),
          at: DateTime(2026, 10, 8, 10), doctorName: 'Dra. Ana')).called(1);
    });

    test('falha no lembrete não derruba o agendamento', () async {
      when(() => reminders.schedule(any(), at: any(named: 'at'), doctorName: any(named: 'doctorName')))
          .thenThrow(Exception('sem permissão'));
      await loadWith([]);
      expect(await state.book(doctor, friday), isTrue);
      expect(state.error, isNull);
      expect(state.upcoming, hasLength(1));
    });
  });
}
