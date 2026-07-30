#!/usr/bin/env zsh

set -euo pipefail

dotfiles_dir="$(cd "$(dirname "$0")" && pwd -P)"
backup_dir="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
dry_run=false
skip_brew=false
skip_gitconfig=false

usage() {
    cat <<EOF
Usage: ./install.sh [--dry-run] [--skip-brew] [--skip-gitconfig]

安裝 zsh-first dotfiles，將設定檔 symlink 到家目錄。
預設會先執行 brew bundle 安裝 Brewfile 裡的 CLI 工具。
Git 設定會互動詢問 name/email 後產生。
既有檔案或不同來源的 symlink 會移到 ${backup_dir}。
EOF
}

link_file() {
    local source="$1"
    local target="$2"
    local existing_source

    if [ "$dry_run" = true ]; then
        printf '[dry-run] link %s -> %s\n' "$target" "$source"
        return
    fi

    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ]; then
        existing_source="$(readlink "$target")"
        if [ "$existing_source" = "$source" ]; then
            return
        fi
    fi

    if [ -L "$target" ] || [ -e "$target" ]; then
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

install_brew_bundle() {
    if [ "$skip_brew" = true ]; then
        printf 'Skipping brew bundle\n'
        return
    fi

    if [ "$dry_run" = true ]; then
        printf '[dry-run] brew bundle --file %s\n' "$dotfiles_dir/Brewfile"
        return
    fi

    if ! command -v brew >/dev/null 2>&1; then
        printf 'Homebrew is not installed; skipping brew bundle\n' >&2
        return
    fi

    brew bundle --file "$dotfiles_dir/Brewfile"
}

render_gitconfig() {
    if [ "$skip_gitconfig" = true ]; then
        printf 'Skipping gitconfig render\n'
        return
    fi

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
        --skip-brew)
            skip_brew=true
            ;;
        --skip-gitconfig)
            skip_gitconfig=true
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

install_brew_bundle
link_file "$dotfiles_dir/.zshrc" "$HOME/.zshrc"
link_file "$dotfiles_dir/.aliases" "$HOME/.aliases"
link_file "$dotfiles_dir/.exports" "$HOME/.exports"
link_file "$dotfiles_dir/.functions" "$HOME/.functions"
render_gitconfig
link_file "$dotfiles_dir/.osx" "$HOME/.osx"
link_file "$dotfiles_dir/.config/starship.toml" "$HOME/.config/starship.toml"

echo "Install done"
echo "Open a new shell or run: exec zsh"
