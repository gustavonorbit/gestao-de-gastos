import 'package:educa_plus/services/conteudo_export_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildConteudoTextoFinal trims, skips blanks, and joins with ; ', () {
    final result = buildConteudoTextoFinal([
      '  PORTUGUÊS: estudo  ',
      '',
      '   ',
      'CIÊNCIAS: água',
    ]);

    expect(result, 'PORTUGUÊS: estudo; CIÊNCIAS: água');
  });

  test('buildConteudoTextoFinal returns empty string when all blank', () {
    final result = buildConteudoTextoFinal(['', '   ']);
    expect(result, '');
  });
}
