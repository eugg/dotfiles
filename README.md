# dotfiles

這個 repository 是我的 macOS 開發環境設定集合。它的用途是把常用 shell 設定、alias、function、tmux 設定、Git 設定與低風險 macOS 偏好集中管理，讓新機器或重裝環境時可以快速恢復熟悉的工作方式。

目前這份設定已改成 zsh-first：主要 shell 是 zsh，prompt 使用 Starship，不再依賴舊的 bash prompt、oh-my-zsh theme 或 powerline 設定。

## 這份 dotfiles 會做什麼

- 建立 zsh 開發環境入口：載入 PATH、alias、function、補完與 Starship prompt。
- 管理常用命令別名：例如 `ll`、`tree`、`grep`、Laravel / Composer 快捷命令。
- 提供常用 shell function：例如建立並進入目錄、啟動本機 HTTP server、格式化 JSON、查憑證名稱、計算檔案 gzip 後大小。
- 設定 tmux：使用 tmux 3.x 語法、滑鼠支援、vi copy mode、狀態列與常用 pane 快捷鍵。
- 套用低風險 macOS defaults：Finder、Dock、Safari、TextEdit、截圖位置等偏好。
- 用 `Brewfile` 記錄建議安裝的現代 CLI 工具。
- 用 `install.sh` 建立家目錄 symlink，並在覆蓋既有檔案前自動備份。

## 不會做什麼

這份 dotfiles 已移除高風險或過時行為：

- 不再部署 bash dotfiles 作為主要入口。
- 不再載入 Python 2、bower、Heroku Toolbelt、舊 RVM autoload、舊 powerline。
- 不會關閉 macOS quarantine。
- 不會寫入 `nvram`。
- 不會重建 Spotlight index。
- 不會刪除或重建 Launchpad database。
- 不會自動安裝 oh-my-zsh。

## 檔案說明

| 檔案 | 用途 |
| --- | --- |
| `.zshrc` | zsh 主要入口，載入共用設定、補完、fzf 與 Starship |
| `.exports` | PATH、locale、pager、editor、history 等環境變數 |
| `.aliases` | 常用命令 alias，優先使用 `eza`、`bat`、`rg`、`delta` 等現代工具 |
| `.functions` | 常用 shell function |
| `.config/starship.toml` | Starship prompt 設定 |
| `.tmux.conf` | tmux 主要設定 |
| `.tmux/` | tmux 共用設定與快捷鍵 |
| `.osx` | 低風險 macOS defaults |
| `.gitconfig` | Git 使用者資訊、alias、color 與 LFS 設定 |
| `Brewfile` | 建議安裝的 Homebrew 套件 |
| `install.sh` | 建立 symlink 的安裝腳本 |

## 建議工具

`Brewfile` 目前包含：

- `starship`：跨 shell prompt。
- `tmux`：terminal multiplexer。
- `fzf`：模糊搜尋。
- `ripgrep`：快速搜尋文字。
- `fd`：快速搜尋檔案。
- `bat`：現代版 `cat`。
- `eza`：現代版 `ls`。
- `jq`：JSON 處理。
- `git-delta`：更好讀的 Git diff pager。

## 安裝

先安裝 Homebrew 套件：

```sh
brew bundle
```

先預覽會建立哪些 symlink：

```sh
./install.sh --dry-run
```

確認後安裝：

```sh
./install.sh
```

安裝腳本會把既有的一般檔案備份到：

```text
~/.dotfiles-backup/YYYYMMDD-HHMMSS/
```

## 套用 macOS defaults

確認 `.osx` 內容後執行：

```sh
~/.osx
```

這份 `.osx` 只保留低風險設定。部分 macOS defaults 需要重新登入或重開機才會完整生效。

## Starship

`.zshrc` 會使用：

```sh
export STARSHIP_CONFIG="${HOME}/.config/starship.toml"
eval "$(starship init zsh)"
```

如果系統尚未安裝 Starship，會暫時退回簡單 zsh prompt，不會讓 shell 啟動失敗。

## 更新流程

修改設定後建議先做基本檢查：

```sh
zsh -n .zshrc
zsh -n .aliases
zsh -n .exports
zsh -n .functions
zsh -n install.sh
zsh -n .osx
./install.sh --dry-run
```

Starship 設定可用：

```sh
STARSHIP_CONFIG="$PWD/.config/starship.toml" starship explain
```
