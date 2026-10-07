import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vida_plena_agenda/data/patient_repository.dart';
import 'package:vida_plena_agenda/domain/patient.dart';
import 'package:vida_plena_agenda/presentation/state/auth_state.dart';

class MockPatientRepository extends Mock implements PatientRepository {}

void main() {
  final ana = Patient.withPassword(id: 'p1', name: 'Ana', email: 'ana@email.com', password: '123456');
  late MockPatientRepository repo;
  late AuthState state;

  setUpAll(() => registerFallbackValue(ana));

  setUp(() {
    repo = MockPatientRepository();
    state = AuthState(repo, idGenerator: () => 'p1');
    when(() => repo.findByEmail(any())).thenAnswer((_) async => null);
    when(() => repo.save(any())).thenAnswer((_) async {});
    when(() => repo.setLoggedPatient(any())).thenAnswer((_) async {});
  });

  group('cadastro', () {
    test('cria paciente, salva e abre sessão', () async {
      expect(await state.register(name: ' Ana ', email: 'ana@email.com', password: '123456'), isTrue);
      expect(state.currentPatient?.name, 'Ana');
      expect(state.isLoggedIn, isTrue);
      expect(state.error, isNull);
      verify(() => repo.save(any())).called(1);
      verify(() => repo.setLoggedPatient('p1')).called(1);
    });

    test('rejeita e-mail inválido sem salvar', () async {
      expect(await state.register(name: 'Ana', email: 'ana', password: '123456'), isFalse);
      expect(state.error, isNotNull);
      expect(state.isLoggedIn, isFalse);
      verifyNever(() => repo.save(any()));
    });

    test('rejeita senha curta', () async {
      expect(await state.register(name: 'Ana', email: 'ana@email.com', password: '123'), isFalse);
      expect(state.error, contains('6'));
    });

    test('rejeita nome vazio', () async {
      expect(await state.register(name: '  ', email: 'ana@email.com', password: '123456'), isFalse);
      expect(state.error, isNotNull);
    });

    test('rejeita e-mail já cadastrado', () async {
      when(() => repo.findByEmail(any())).thenAnswer((_) async => ana);
      expect(await state.register(name: 'Ana', email: 'ana@email.com', password: '123456'), isFalse);
      expect(state.error, contains('Já existe'));
      verifyNever(() => repo.save(any()));
    });
  });

  group('login', () {
    test('entra com credenciais corretas', () async {
      when(() => repo.findByEmail('ana@email.com')).thenAnswer((_) async => ana);
      expect(await state.login(email: 'ana@email.com', password: '123456'), isTrue);
      expect(state.currentPatient, ana);
    });

    test('rejeita senha errada', () async {
      when(() => repo.findByEmail('ana@email.com')).thenAnswer((_) async => ana);
      expect(await state.login(email: 'ana@email.com', password: '654321'), isFalse);
      expect(state.error, 'E-mail ou senha incorretos.');
      expect(state.isLoggedIn, isFalse);
    });

    test('rejeita e-mail não cadastrado', () async {
      expect(await state.login(email: 'x@email.com', password: '123456'), isFalse);
      expect(state.error, 'E-mail ou senha incorretos.');
    });

    test('campos vazios geram erro de validação', () async {
      expect(await state.login(email: '', password: ''), isFalse);
      expect(state.error, isNotNull);
      verifyNever(() => repo.findByEmail(any()));
    });

    test('falha inesperada do repositório vira mensagem genérica', () async {
      when(() => repo.findByEmail(any())).thenThrow(Exception('disco'));
      expect(await state.login(email: 'ana@email.com', password: '123456'), isFalse);
      expect(state.error, 'Algo deu errado. Tente novamente.');
      expect(state.isLoading, isFalse);
    });
  });

  test('loading fica true durante a operação e false ao fim', () async {
    final seen = <bool>[];
    state.addListener(() => seen.add(state.isLoading));
    await state.login(email: 'ana@email.com', password: '123456');
    expect(seen.first, isTrue);
    expect(seen.last, isFalse);
  });

  test('restoreSession carrega paciente salvo', () async {
    when(() => repo.getLoggedPatient()).thenAnswer((_) async => ana);
    await state.restoreSession();
    expect(state.currentPatient, ana);
  });

  test('logout limpa sessão', () async {
    when(() => repo.getLoggedPatient()).thenAnswer((_) async => ana);
    await state.restoreSession();
    await state.logout();
    expect(state.isLoggedIn, isFalse);
    verify(() => repo.setLoggedPatient(null)).called(1);
  });

  test('clearError remove a mensagem', () async {
    await state.login(email: '', password: '');
    state.clearError();
    expect(state.error, isNull);
  });
}
