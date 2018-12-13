from sys import exit

import codemod

from over_react_codemod.suggestors.component_default_props import component_default_props_suggestor
from over_react_codemod.suggestors.dollar_props import dollar_props_suggestor
from over_react_codemod.suggestors.factories import factories_suggestor
from over_react_codemod.suggestors.generated_parts import collect_libraries_suggestor
from over_react_codemod.suggestors.generated_parts import generated_parts_suggestor
from over_react_codemod.suggestors.props_and_state_classes import props_and_state_classes_accompanying_public_class_suggestor
from over_react_codemod.suggestors.props_and_state_classes import props_and_state_classes_rename_suggestor
from over_react_codemod.suggestors.props_and_state_mixins import props_and_state_mixins_meta_suggestor
from over_react_codemod.suggestors.with_props_or_state_mixins import with_props_and_state_mixins_suggestor
from over_react_codemod.util import is_dart_file

suggestors = [
    factories_suggestor,
    dollar_props_suggestor,
    component_default_props_suggestor,
    props_and_state_classes_accompanying_public_class_suggestor,
    props_and_state_classes_rename_suggestor,
    props_and_state_mixins_meta_suggestor,
    with_props_and_state_mixins_suggestor,
    collect_libraries_suggestor,
    generated_parts_suggestor,
]


def main(check=False):
    num_changes_needed = 0

    global suggestors
    for suggestor in suggestors:
        query = codemod.Query(suggestor, path_filter=is_dart_file)

        if check:
            num_changes_needed += len(query.generate_patches())
        else:
            codemod.run_interactive(query)

    if check and num_changes_needed > 0:
        print('Failed: %d changes needed.' % num_changes_needed)
        exit(1)

if __name__ == '__main__':
    main()