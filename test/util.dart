import 'dart:io';

import 'package:codemod/codemod.dart';
import 'package:path/path.dart' as p;
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

final _patchesPattern = RegExp(r'\(patches (\d+)\)');
final _pathPattern = RegExp(r'\(path ([\w./]+)\)');

// TODO: Give credit to https://github.com/dart-lang/dart_style/blob/master/test/utils.dart

void testSuggestorsDir(Map<String, Suggestor> suggestorMap, String testDir) {
  final testFiles =
      Directory(testDir).listSync(followLinks: false, recursive: true);
  testFiles.sort((a, b) => a.path.compareTo(b.path));

  for (var testFile in testFiles) {
    if (!testFile.path.endsWith('.suggestor_test')) {
      continue;
    }
    _testSuggestor(suggestorMap, testFile.path);
  }
}

void _testSuggestor(Map<String, Suggestor> suggestorMap, String testFilePath) {
  group(p.basenameWithoutExtension(testFilePath), () {
    final lines = File(testFilePath).readAsLinesSync();

    // First line selects the suggestor to use.
    final suggestorName = lines[0];
    final suggestor = suggestorMap[suggestorName];
    if (suggestor == null) {
      throw Exception('Unknown suggestor: $suggestorName');
    }

    var i = 1;

    // Let the test specify some opening comments.
    while (lines[i].startsWith('#')) {
      i++;
    }

    while (i < lines.length) {
      var description = lines[i++].replaceAll('>>>', '');

      // Let the test specify how many patches should be generated.
      var expectedNumPatches;
      description = description.replaceAllMapped(_patchesPattern, (match) {
        expectedNumPatches = int.parse(match.group(1));
        return '';
      });

      // Let the test specify a file path, as the suggestor may use it.
      var path;
      description = description.replaceAllMapped(_pathPattern, (match) {
        path = match.group(1);
        return '';
      });

      description = description.trim();
      description =
          description.isEmpty ? 'line ${i + 1}' : 'line ${i + 1}: $description';

      var input = '';
      while (!lines[i].startsWith('<<<')) {
        input += lines[i++] + '\n';
      }
      if (input.isEmpty) {
        input = '\n';
      }

      var expectedOutput = '';
      while (++i < lines.length && !lines[i].startsWith('>>>')) {
        expectedOutput += lines[i] + '\n';
      }
      // Trim trailing whitespace (except a single newline) as it is not
      // critical to the suggestor outputs and allows for spacing between test
      // cases for better readability.
      expectedOutput = expectedOutput.trimRight() + '\n';

      test(description, () {
        final sourceFile = SourceFile.fromString(input, url: path);
        final patches = suggestor.generatePatches(sourceFile);
        if (expectedNumPatches != null &&
            patches.length != expectedNumPatches) {
          fail('Incorrect number of patches generated '
              '(expected: $expectedNumPatches, actual: ${patches.length})\n'
              'Patches:\n$patches');
        }
        expect(applyPatches(sourceFile, patches), expectedOutput);
      });
    }
  });
}
