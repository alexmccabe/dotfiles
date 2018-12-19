# !/bin/bash
# adapted from https://github.com/skeeto/dotfiles/blob/master/install.sh

if [ -d ~/.scm_breeze ]; then
    echo 'SCM_BREEZE is already installed, skipping'
else
    git clone git://github.com/scmbreeze/scm_breeze.git ~/.scm_breeze && ~/.scm_breeze/install.sh
fi

if ! [ -d ~/ngrok ]; then
    echo 'Copying ngrok to "~/"'
    cp ./ngrok ~/
fi

split() {
    path="$1"
    output=""

    while IFS='/' read -ra SPLIT; do
        for i in "${SPLIT[@]}"; do
            if [ "$i" = "." ]; then
                output="$output"
            else
                if [[ "$i" == _* ]]; then
                    output="$output/.${i#_*}"
                else
                    output="$output/$i"
                fi
            fi
        done
    done <<< "$path"

    echo "$output"
}

install() {
    dotfile="$1"
    dest=$(split "$dotfile")

    dest="$HOME/.${dest#./.*}"

    if [ "$dotfile" = "${dotfile##*.enchive}" ]; then
        echo Installing "$dotfile"

        mkdir -p -m 700 "$(dirname "$dest")"

        chmod go-rwx "$dotfile"

        ln -fs $lnflags "$(pwd)/$dotfile" "$dest"
    fi
}

## Install each _-prefixed file
for source in $(find . -name '_*' | sort); do
    if [ -d "$source" ]; then
        for dotfile in $(find "$source" -type f | sort); do
            install "$dotfile"
        done
    else
        install "$source"
    fi
done
