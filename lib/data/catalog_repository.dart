import '../domain/doctor.dart';
import '../domain/specialty.dart';

abstract class CatalogRepository {
  Future<List<Specialty>> getSpecialties();
  Future<List<Doctor>> getDoctors({String? specialtyId});
}
