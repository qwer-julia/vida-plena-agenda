import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vida_plena_agenda/data/local_appointment_repository.dart';
import 'package:vida_plena_agenda/domain/appointment.dart';

void main() {
  Appointment make(String id, {String patientId = 'p1', AppointmentStatus status = AppointmentStatus.agendada}) =>
      Appointment(
        id: id,
        patientId: patientId,
        doctorId: 'd1',
        dateTime: DateTime(2026, 10, 10, 9),
        status: status,
      );

  Future<LocalAppointmentRepository> newRepo() async =>
      LocalAppointmentRepository(await SharedPreferences.getInstance());

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('começa vazio', () async {
    expect(await (await newRepo()).getAll(), isEmpty);
  });

  test('salva e recupera preservando todos os campos', () async {
    final repo = await newRepo();
    await repo.save(make('a1', status: AppointmentStatus.confirmada));
    final a = (await repo.getAll()).single;
    expect(a.id, 'a1');
    expect(a.patientId, 'p1');
    expect(a.doctorId, 'd1');
    expect(a.dateTime, DateTime(2026, 10, 10, 9));
    expect(a.status, AppointmentStatus.confirmada);
  });

  test('save com mesmo id atualiza em vez de duplicar', () async {
    final repo = await newRepo();
    await repo.save(make('a1'));
    await repo.save(make('a1', status: AppointmentStatus.cancelada));
    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.single.status, AppointmentStatus.cancelada);
  });

  test('getByPatient filtra pelo paciente', () async {
    final repo = await newRepo();
    await repo.save(make('a1'));
    await repo.save(make('a2', patientId: 'p2'));
    final mine = await repo.getByPatient('p1');
    expect(mine.map((a) => a.id), ['a1']);
  });

  test('dados persistem em nova instância (simula reabrir o app)', () async {
    await (await newRepo()).save(make('a1'));
    expect(await (await newRepo()).getAll(), hasLength(1));
  });
}
