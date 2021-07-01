extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1    ;;
            *.tar.gz)    tar xvzf $1    ;;
            *.tar.xz)    tar xvJf $1    ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xvf $1     ;;
            *.tbz2)      tar xvjf $1    ;;
            *.tgz)       tar xvzf $1    ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *.xz)        unxz $1        ;;
            *.exe)       cabextract $1  ;;
            *)           echo "\`$1': unrecognized file compression" ;;
        esac
    else
        echo "\`$1' is not a valid file"
    fi
}

# Read text from stdin, and echo a version of the same text, just better suited
# for a filename.
sanitise-filename() {
    echo -n "$1" | tr -c -s 'a-zA-Z0-9.-' '-'
}

trim-file-prefix() {
    echo -n "$1" | cut -c18-
}

trim-files-prefix() {
    local exitcode=0
    local sanitised
    for file in $*; do
        sanitised=$(trim-file-prefix "$file")

        [ "$sanitised" = "$file" ] && continue

        if [ -f "$sanitised" ]; then
            echo >&2 "$0: can't rename $file, $sanitised already exists"
            exitcode=1
        else
            mv -- "$file" "$sanitised"
        fi
    done
}

# Wrapper around sanitise-filename which takes a list of files and renames them
# for you. Example use:
#
#   sanitise-rename-files *
#   sanitise-rename-files *.doc
#
sanitise-rename-files() {
    local exitcode=0
    local sanitised

    for file in $*; do
        sanitised=$(sanitise-filename "$file")

        [ "$sanitised" = "$file" ] && continue

        if [ -f "$sanitised" ]; then
            echo >&2 "$0: can't rename $file, $sanitised already exists"
            exitcode=1
        else
            mv -- "$file" "$sanitised"
        fi
    done

    return $exitcode
}

dotfile-has() {
  type "${1-}" > /dev/null 2>&1
}

# generate random password/key
gen-pswd() {
    if dotfile-has "pwgen"; then
        # we have pwgen use it
        command pwgen -ysB $1
    else
        # use system random
        </dev/urandom tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c $1  ; echo
    fi
}

# function for adding dirs to $PATH
# silently does nothing if an argument isn't a directory
add-path() {
    local PREPEND="false"

    # basic arg parsing
    if [ "$1" = "--prepend" ]; then
        PREPEND="true"
        shift
    fi

    for ARG in $*; do
        if [ -d $ARG ]; then
            if [ "$PREPEND" = "true" ]; then
                export PATH="$ARG:$PATH"
            else
                export PATH="$PATH:$ARG"
            fi
        fi
    done
}

se_download_html() {
    command curl http://95.217.135.107/media/serp_html/${1}.html -L --output ${1}.html
}
