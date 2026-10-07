import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vida_plena_agenda/data/local_patient_repository.dart';
import 'package:vida_plena_agenda/domain/patient.dart';

void main() {
  final ana = Patient.withPassword(id: 'p1', name: 'Ana', email: 'ana@email.com', password: '123456');

  Future<LocalPatientRepository> newRepo() async =>
      LocalPatientRepository(await SharedPreferences.getInstance());

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('findByEmail retorna null quando não há pacientes', () async {
    expect(await (await newRepo()).findByEmail('ana@email.com'), isNull);
  });

  test('salva e encontra paciente ignorando maiúsculas e espaços', () async {
    final repo = await newRepo();
    await repo.save(ana);
    final found = await repo.findByEmail('  ANA@email.com ');
    expect(found?.id, 'p1');
    expect(found?.name, 'Ana');
  });

  test('save com mesmo id substitui o paciente', () async {
    final repo = await newRepo();
    await repo.save(ana);
    await repo.save(Patient.withPassword(id: 'p1', name: 'Ana Maria', email: 'ana@email.com', password: '123456'));
    expect((await repo.findByEmail('ana@email.com'))?.name, 'Ana Maria');
  });

  test('dados persistem em nova instância (simula reabrir o app)', () async {
    await (await newRepo()).save(ana);
    expect(await (await newRepo()).findByEmail('ana@email.com'), isNotNull);
  });

  test('sessão: define, lê e limpa o paciente logado', () async {
    final repo = await newRepo();
    await repo.save(ana);
    expect(await repo.getLoggedPatient(), isNull);
    await repo.setLoggedPatient('p1');
    expect((await (await newRepo()).getLoggedPatient())?.id, 'p1');
    await repo.setLoggedPatient(null);
    expect(await repo.getLoggedPatient(), isNull);
  });

  test('sessão com id inexistente retorna null', () async {
    final repo = await newRepo();
    await repo.setLoggedPatient('fantasma');
    expect(await repo.getLoggedPatient(), isNull);
  });
}
