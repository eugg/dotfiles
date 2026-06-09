#!/usr/bin/env zsh

set -euo pipefail

dotfiles_dir="$(cd "$(dirname "$0")" && pwd -P)"
backup_dir="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
dry_run=false

usage() {
    cat <<EOF
Usage: ./install.sh [--dry-run]

安裝 zsh-first dotfiles，將設定檔 symlink 到家目錄。
既有的一般檔案會移到 ${backup_dir}。
EOF
}

link_file() {
    local source="$1"
    local target="$2"

    if [ "$dry_run" = true ]; then
        printf '[dry-run] link %s -> %s\n' "$target" "$source"
        return
    fi

    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ]; then
        ln -sfn "$source" "$target"
        return
    fi

    if [ -e "$target" ]; then
        mkdir -p "$backup_dir"
        mv "$target" "$backup_dir/"
    fi

    ln -s "$source" "$target"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)
            dry_run=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
    shift
done

echo "Installing zsh dotfiles"

link_file "$dotfiles_dir/.zshrc" "$HOME/.zshrc"
link_file "$dotfiles_dir/.aliases" "$HOME/.aliases"
link_file "$dotfiles_dir/.exports" "$HOME/.exports"
link_file "$dotfiles_dir/.functions" "$HOME/.functions"
link_file "$dotfiles_dir/.gitconfig" "$HOME/.gitconfig"
link_file "$dotfiles_dir/.osx" "$HOME/.osx"
link_file "$dotfiles_dir/.config/starship.toml" "$HOME/.config/starship.toml"

echo "Install done"
