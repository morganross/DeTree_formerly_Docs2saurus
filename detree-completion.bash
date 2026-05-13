# Bash completion script for detree
# Install: sudo cp detree-completion.bash /etc/bash_completion.d/detree
# Or: source detree-completion.bash

_detree_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Main options
    opts="--remove-digits --allow-empty-folders --help --version"

    # If current word starts with -, show options
    if [[ ${cur} == -* ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
    
    # Complete filenames for first argument (input file)
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -f -- ${cur}) )
        return 0
    fi
    
    # Complete directories for second argument (output dir)
    if [[ ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=( $(compgen -d -- ${cur}) )
        return 0
    fi
}

complete -F _detree_completion detree

# Also support the Python script name
complete -F _detree_completion d2c2_cli.py
