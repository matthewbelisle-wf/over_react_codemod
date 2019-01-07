@TestOn('vm')
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/component_default_props_migrator.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/dollar_prop_keys_migrator.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/dollar_props_migrator.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/needs_over_react_library_collector.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/over_react_generated_part_directive_adder.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/props_and_state_classes_renamer.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/props_and_state_companion_class_adder.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/props_and_state_mixin_meta_adder.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/props_and_state_mixin_usage_updater.dart';
import 'package:codemod_over_react/src/d1_to_d1_and_d2/suggestors/ui_factory_initializer.dart';

import '../util.dart';

class MockCollector extends Mock implements NeedsOverReactLibraryCollector {}

void main() {
  group('Dart1 -> Dart1/Dart2 suggestors', () {
    // In the `.suggestor_test` for this suggestor, the tests are written with
    // the assumption that any library with a name of `match` or a path of
    // `match.dart` needs the part directive, and this setup is why that works.
    final mockCollector = MockCollector();
    when(mockCollector.byName).thenReturn(['match']);
    when(mockCollector.byPath).thenReturn([p.canonicalize('match.dart')]);
    final overReactGeneratedPartDirectiveAdder =
        OverReactGeneratedPartDirectiveAdder(mockCollector);

    final suggestorMap = {
      'ComponentDefaultPropsMigrator': ComponentDefaultPropsMigrator(),
      'DollarPropKeysMigrator': DollarPropKeysMigrator(),
      'DollarPropsMigrator': DollarPropsMigrator(),
      'OverReactGeneratedPartDirectiveAdder':
          overReactGeneratedPartDirectiveAdder,
      'PropsAndStateClassesRenamer': PropsAndStateClassesRenamer(),
      'PropsAndStateCompanionClassAdder': PropsAndStateCompanionClassAdder(),
      'PropsAndStateCompanionClassAdderWithCommentPrefix':
          PropsAndStateCompanionClassAdder(commentPrefix: 'PREFIX: '),
      'PropsAndStateMixinMetaAdder': PropsAndStateMixinMetaAdder(),
      'PropsAndStateMixinUsageUpdater': PropsAndStateMixinUsageUpdater(),
      'UiFactoryInitializer': UiFactoryInitializer(),
    };
    testSuggestorsDir(suggestorMap, 'test/d1_to_d1_and_d2/suggestor_tests');
  });
}
