import '../domain/doctor.dart';
import '../domain/specialty.dart';
import 'catalog_repository.dart';
import 'seed_data.dart';

/// Catálogo fixo vindo do seed (especialidades e profissionais não são editáveis no app).
class LocalCatalogRepository implements CatalogRepository {
  @override
  Future<List<Specialty>> getSpecialties() async => SeedData.specialties;

  @override
  Future<List<Doctor>> getDoctors({String? specialtyId}) async {
    if (specialtyId == null) return SeedData.doctors;
    return SeedData.doctors.where((d) => d.specialtyId == specialtyId).toList();
  }
}
