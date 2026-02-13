import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/ui/screens/classes/turma_filter_controller.dart';

void main() {
  test('setAtiva(true/false/null updates state via provider', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(turmaFilterProvider.notifier);

    controller.setAtiva(true);
    expect(container.read(turmaFilterProvider).ativa, isTrue);

    controller.setAtiva(false);
    expect(container.read(turmaFilterProvider).ativa, isFalse);

    // Set to null should clear
    controller.setAtiva(null);
    expect(container.read(turmaFilterProvider).ativa, isNull);
  });
}
