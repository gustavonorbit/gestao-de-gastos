import 'package:educa_plus/domain/entities/aula.dart' as domain;
import 'package:educa_plus/services/export_service.dart' show ExportAula;

/// Academic helpers used across UI and export logic.
///
/// dias letivos are counted using `presencaAbas` of each aula. If an aula has
/// presencaAbas <= 0 we treat it as 1 (legacy behaviour).
int countDiasLetivosFromDomainAulas(List<domain.Aula> aulas) {
  var total = 0;
  for (final a in aulas) {
    final count = (a.presencaAbas <= 0) ? 1 : a.presencaAbas;
    total += count;
  }
  return total;
}

int countDiasLetivosFromExportAulas(List<ExportAula> aulas) {
  var total = 0;
  for (final a in aulas) {
    final count = (a.presencaAbas <= 0) ? 1 : a.presencaAbas;
    total += count;
  }
  return total;
}
