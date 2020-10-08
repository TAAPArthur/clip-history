#!/bin/bash
_cliphistoryAutocomplete ()   #  By convention, the function name
{                 #+ starts with an underscore.
    local cur
    # Pointer to current completion word.
    # By convention, it's named "cur" but this isn't strictly necessary.

    COMPREPLY=()   # Array variable storing the possible completions.
    cur=${COMP_WORDS[COMP_CWORD]}
    selection_options="--primary --secondary --clipboard"
    normal_options="dedup filter-long monitor merge list show get"

    if [[ "$COMP_CWORD" -eq 1 ]]; then
        COMPREPLY=( $( compgen -W "$selection_options $normal_options" -- $cur ) )
    elif [[ "$COMP_CWORD" -lt 2 ]]; then
        COMPREPLY=( $( compgen -W "$normal_options" -- $cur ) )
    fi
    return 0
}
complete -F _cliphistoryAutocomplete clip-history

