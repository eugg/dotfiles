#!/usr/bin/env zsh

set -euo pipefail

dotfiles_dir="$(cd "$(dirname "$0")" && pwd -P)"
backup_dir="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
dry_run=false

usage() {
    cat <<EOF
Usage: ./install.sh [--dry-run]

安裝 zsh-first dotfiles，將設定檔 symlink 到家目錄。
Git 設定會互動詢問 name/email 後產生。
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

backup_file() {
    local target="$1"

    if [ -L "$target" ] || [ -e "$target" ]; then
        mkdir -p "$backup_dir"
        mv "$target" "$backup_dir/"
    fi
}

escape_sed_replacement() {
    printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

render_gitconfig() {
    local target="${HOME}/.gitconfig"
    local default_name
    local default_email
    local git_name
    local git_email
    local escaped_git_name
    local escaped_git_email

    default_name="$(git config --global --get user.name 2>/dev/null || true)"
    default_email="$(git config --global --get user.email 2>/dev/null || true)"

    if [ "$dry_run" = true ]; then
        printf '[dry-run] render %s from %s\n' "$target" "$dotfiles_dir/.gitconfig.template"
        return
    fi

    printf 'Git user.name [%s]: ' "$default_name"
    read -r git_name
    git_name="${git_name:-$default_name}"

    while [ -z "$git_name" ]; do
        printf 'Git user.name is required: '
        read -r git_name
    done

    printf 'Git user.email [%s]: ' "$default_email"
    read -r git_email
    git_email="${git_email:-$default_email}"

    while [ -z "$git_email" ]; do
        printf 'Git user.email is required: '
        read -r git_email
    done

    backup_file "$target"
    escaped_git_name="$(escape_sed_replacement "$git_name")"
    escaped_git_email="$(escape_sed_replacement "$git_email")"
    sed \
        -e "s/{{GIT_NAME}}/$escaped_git_name/g" \
        -e "s/{{GIT_EMAIL}}/$escaped_git_email/g" \
        "$dotfiles_dir/.gitconfig.template" > "$target"
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
render_gitconfig
link_file "$dotfiles_dir/.osx" "$HOME/.osx"
link_file "$dotfiles_dir/.config/starship.toml" "$HOME/.config/starship.toml"

echo "Install done"
