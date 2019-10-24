#!/bin/bash
_cliphistoryAutocomplete ()   #  By convention, the function name
{                 #+ starts with an underscore.
    local cur
    # Pointer to current completion word.
    # By convention, it's named "cur" but this isn't strictly necessary.

    COMPREPLY=()   # Array variable storing the possible completions.
    cur=${COMP_WORDS[COMP_CWORD]}

    if [[ "$COMP_CWORD" -lt 2 ]]; then
        COMPREPLY=( $( compgen -W "dedup filter-long monitor merge list show get" -- $cur ) )
    fi
    return 0
}
complete -F _cliphistoryAutocomplete clip-history

