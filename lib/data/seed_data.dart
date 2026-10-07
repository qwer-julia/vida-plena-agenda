import '../domain/doctor.dart';
import '../domain/specialty.dart';

/// Carga inicial do catálogo da clínica.
class SeedData {
  static const specialties = [
    Specialty(id: 'clinica-geral', name: 'Clínica Geral'),
    Specialty(id: 'cardiologia', name: 'Cardiologia'),
    Specialty(id: 'dermatologia', name: 'Dermatologia'),
  ];

  static const doctors = [
    Doctor(
      id: 'dr-helena-martins',
      name: 'Dra. Helena Martins',
      specialtyId: 'clinica-geral',
    ),
    Doctor(
      id: 'dr-paulo-ribeiro',
      name: 'Dr. Paulo Ribeiro',
      specialtyId: 'clinica-geral',
      workingWeekdays: [DateTime.tuesday, DateTime.thursday, DateTime.saturday],
      slotHours: [8, 9, 10, 11],
    ),
    Doctor(
      id: 'dra-camila-torres',
      name: 'Dra. Camila Torres',
      specialtyId: 'cardiologia',
      workingWeekdays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      slotHours: [9, 10, 11, 14, 15],
    ),
    Doctor(
      id: 'dr-andre-lima',
      name: 'Dr. André Lima',
      specialtyId: 'cardiologia',
      workingWeekdays: [DateTime.tuesday, DateTime.thursday],
      slotHours: [13, 14, 15, 16, 17],
    ),
    Doctor(
      id: 'dra-beatriz-souza',
      name: 'Dra. Beatriz Souza',
      specialtyId: 'dermatologia',
      slotHours: [10, 11, 14, 15, 16],
    ),
  ];
}
