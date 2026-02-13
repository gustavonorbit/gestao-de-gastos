import 'package:educa_plus/ui/screens/students/student_name_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseStudentNamesFromOcrText filters noise and keeps names', () {
    const input = '''
1) ANA
2) BRUNO SILVA
03 - Maria da Silva
Matutino
Turma
Ano
ns
8B
2025
A
• JOAO
- CARLA-DE-SOUZA
• PEDRO 10
Matemática
''';

    final names = parseStudentNamesFromOcrText(input);

    // Accept single-word names and compound names.
    expect(names, contains('Ana'));
    expect(names, contains('Bruno Silva'));
    expect(names, contains('Maria da Silva'));
    expect(names, contains('Joao'));

    // Hyphenation becomes spaces after normalization.
    expect(names, contains('Carla de Souza'));

    // Noise should be gone.
    expect(names.any((n) => n.contains('2025')), isFalse);
    expect(names.any((n) => n.contains('8B')), isFalse);
    expect(names.any((n) => n.toLowerCase() == 'a'), isFalse);
    expect(names.any((n) => n.toLowerCase().contains('matem')), isFalse);
    expect(names.any((n) => n.toLowerCase() == 'matutino'), isFalse);
    expect(names.any((n) => n.toLowerCase() == 'turma'), isFalse);
    expect(names.any((n) => n.toLowerCase() == 'ano'), isFalse);
    expect(names.any((n) => n.toLowerCase() == 'ns'), isFalse);
  });

  test('parseStudentNamesFromOcrText handles connectors', () {
    const input = 'JOSE DO CARMO\nMARIA DAS DORES\nDE\n';
    final names = parseStudentNamesFromOcrText(input);

    expect(names, contains('Jose do Carmo'));
    expect(names, contains('Maria das Dores'));

    // Connector-only lines are discarded.
    expect(names.any((n) => n.toLowerCase() == 'de'), isFalse);
  });
}
