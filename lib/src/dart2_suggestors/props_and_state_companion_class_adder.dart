// Copyright 2019 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:analyzer/analyzer.dart';
import 'package:codemod/codemod.dart';

import '../constants.dart';
import '../util.dart';

/// Suggestor that inserts the companion class for every non-mixin props and
/// state class, but only if it hasn't already been added.
///
/// The companion class will include a static `meta` mixin field.
class PropsAndStateCompanionClassAdder extends RecursiveAstVisitor
    with AstVisitingSuggestorMixin
    implements Suggestor {
  final String commentPrefix;

  Iterable<String> _classNames;

  PropsAndStateCompanionClassAdder({this.commentPrefix});

  @override
  visitCompilationUnit(CompilationUnit node) {
    // This will be used to determine whether or not the companion class has
    // already been added.
    _classNames = node.declarations
        .whereType<ClassDeclaration>()
        .map((classNode) => classNode.name.name);

    super.visitCompilationUnit(node);
  }

  @override
  visitClassDeclaration(ClassDeclaration node) {
    super.visitClassDeclaration(node);

    final annotation = node.metadata.firstWhere(
        (m) => overReactPropsStateNonMixinAnnotationNames.contains(m.name.name),
        orElse: () => null);
    if (annotation == null) {
      // Only looking for classes annotated with `@Props()`, `@State()`,
      // `@AbstractProps()`, or `@AbstractState()`.
      return;
    }

    final companionClassName = stripPrivateGeneratedPrefix(node.name.name);
    if (node.name.name != companionClassName &&
        _classNames.contains(companionClassName)) {
      // Already added.
      return;
    }

    final annotations = node.metadata
        .where((m) =>
            !overReactPropsStateNonMixinAnnotationNames.contains(m.name.name))
        .map((m) => m.toSource())
        .join('\n');
    String docComment;
    if (node.documentationComment != null) {
      docComment = sourceFile.getText(
        node.documentationComment.offset,
        node.documentationComment.end,
      );
    }

    yieldPatch(
      node.root.end,
      node.root.end,
      annotation.name.name.contains('Props')
          ? buildPropsCompanionClass(node.name.name,
              annotations: annotations,
              commentPrefix: commentPrefix,
              docComment: docComment,
              typeParameters: node.typeParameters)
          : buildStateCompanionClass(node.name.name,
              annotations: annotations,
              commentPrefix: commentPrefix,
              docComment: docComment,
              typeParameters: node.typeParameters),
    );
  }
}
