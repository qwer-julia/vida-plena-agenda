import 'package:flutter_test/flutter_test.dart';
import 'package:vida_plena_agenda/data/local_catalog_repository.dart';

void main() {
  final repo = LocalCatalogRepository();

  test('seed tem 3 especialidades e 5 profissionais', () async {
    expect(await repo.getSpecialties(), hasLength(3));
    expect(await repo.getDoctors(), hasLength(5));
  });

  test('todo profissional pertence a uma especialidade existente', () async {
    final ids = (await repo.getSpecialties()).map((s) => s.id).toSet();
    for (final d in await repo.getDoctors()) {
      expect(ids, contains(d.specialtyId));
    }
  });

  test('toda especialidade tem ao menos um profissional', () async {
    for (final s in await repo.getSpecialties()) {
      expect(await repo.getDoctors(specialtyId: s.id), isNotEmpty);
    }
  });

  test('ids dos profissionais são únicos', () async {
    final ids = (await repo.getDoctors()).map((d) => d.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('slotsOn gera horários só nos dias de atendimento', () async {
    final doctor = (await repo.getDoctors()).first; // seg a sex
    final monday = DateTime(2026, 10, 5);
    final sunday = DateTime(2026, 10, 11);
    expect(doctor.slotsOn(monday), isNotEmpty);
    expect(doctor.slotsOn(monday).first, DateTime(2026, 10, 5, 9));
    expect(doctor.slotsOn(sunday), isEmpty);
  });
}
