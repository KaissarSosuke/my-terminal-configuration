#!/usr/bin/env bash
# Green City Kitty installer.
# Copies the bundle into $HOME and backs up existing Kitty, Fastfetch, and
# Zsh files before replacing them.

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME:?HOME is not set}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$TARGET_HOME/.config-backup/green-city-$STAMP"

INSTALL_BORDER=0
INSTALL_WALLPAPER=0
INSTALL_ZSHRC=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --with-zshrc   Back up and replace ~/.zshrc with the included Zsh config.
                 Without this flag, the config is installed as
                 ~/.zshrc-green-city and ~/.zshrc is left untouched.
  --border       Install the optional green outer frame and split borders.
  --wallpaper    Copy the bundled wallpaper to ~/Pictures.
  -h, --help     Show this help.

Examples:
  ./install.sh --with-zshrc
  ./install.sh --with-zshrc --border --wallpaper
EOF
}

while (($#)); do
  case "$1" in
    --with-zshrc) INSTALL_ZSHRC=1 ;;
    --border) INSTALL_BORDER=1 ;;
    --wallpaper) INSTALL_WALLPAPER=1 ;;
    -h|--help) usage; exit 0 ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

info() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

for cmd in kitty zsh; do
  command -v "$cmd" >/dev/null 2>&1 || \
    warn "$cmd is not installed; install it before starting Kitty/Zsh."
done

case "$(uname -m)" in
  x86_64|amd64) ;;
  *)
    warn "The bundled fastfetch binary is x86_64; install a build for $(uname -m) from https://github.com/fastfetch-cli/fastfetch/releases"
    ;;
esac

info "Installing into $TARGET_HOME"

backup() {
  local source="$1" name="$2"
  if [ -e "$source" ] || [ -L "$source" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$name")"
    cp -a -- "$source" "$BACKUP_DIR/$name"
    info "Backed up $source -> $BACKUP_DIR/$name"
  fi
}

backup "$TARGET_HOME/.config/kitty" "config/kitty"
backup "$TARGET_HOME/.config/fastfetch" "config/fastfetch"
if [ "$INSTALL_ZSHRC" -eq 1 ]; then
  backup "$TARGET_HOME/.zshrc" ".zshrc"
fi
if [ "$INSTALL_WALLPAPER" -eq 1 ]; then
  backup "$TARGET_HOME/Pictures/1-glowing-city.jpg" "Pictures/1-glowing-city.jpg"
fi

mkdir -p \
  "$TARGET_HOME/.config/kitty" \
  "$TARGET_HOME/.config/fastfetch" \
  "$TARGET_HOME/.local/bin" \
  "$TARGET_HOME/.local/share/fonts/JetBrainsMonoNerdFont" \
  "$TARGET_HOME/Pictures"

info "Copying Kitty, Fastfetch, and font files"
cp -a -- "$REPO_DIR/home/.config/kitty/." "$TARGET_HOME/.config/kitty/"
cp -a -- "$REPO_DIR/home/.config/fastfetch/." "$TARGET_HOME/.config/fastfetch/"
cp -a -- "$REPO_DIR/home/.local/bin/fastfetch" "$TARGET_HOME/.local/bin/fastfetch"
chmod +x "$TARGET_HOME/.local/bin/fastfetch"
cp -a -- "$REPO_DIR/home/.local/share/fonts/JetBrainsMonoNerdFont/." \
  "$TARGET_HOME/.local/share/fonts/JetBrainsMonoNerdFont/"

if command -v fc-cache >/dev/null 2>&1; then
  info "Refreshing the font cache"
  fc-cache -f "$TARGET_HOME/.local/share/fonts" >/dev/null
else
  warn "fc-cache not found; install fontconfig and run: fc-cache -f ~/.local/share/fonts"
fi

if [ "$INSTALL_ZSHRC" -eq 1 ]; then
  cp -a -- "$REPO_DIR/home/.zshrc-green-city" "$TARGET_HOME/.zshrc"
  info "Installed the Green City Zsh config as ~/.zshrc"
else
  cp -a -- "$REPO_DIR/home/.zshrc-green-city" "$TARGET_HOME/.zshrc-green-city"
  info "Installed the Zsh config as ~/.zshrc-green-city (existing ~/.zshrc untouched)"
  info "To use it, add this line to ~/.zshrc: source ~/.zshrc-green-city"
fi

if [ "$INSTALL_BORDER" -eq 1 ]; then
  info "Installing the optional green border"
  cp -a -- "$REPO_DIR/optional/border/green-frame.png" \
    "$TARGET_HOME/.config/kitty/green-frame.png"
  cp -a -- "$REPO_DIR/optional/border/kitty-border.conf" \
    "$TARGET_HOME/.config/kitty/green-city-border.conf"
  if ! grep -qxF 'include green-city-border.conf' "$TARGET_HOME/.config/kitty/kitty.conf"; then
    printf '\n# Optional green outer frame and native split borders.\ninclude green-city-border.conf\n' \
      >> "$TARGET_HOME/.config/kitty/kitty.conf"
  fi
fi

if [ "$INSTALL_WALLPAPER" -eq 1 ]; then
  info "Copying the wallpaper"
  cp -a -- "$REPO_DIR/home/Pictures/1-glowing-city.jpg" \
    "$TARGET_HOME/Pictures/1-glowing-city.jpg"
  info "Wallpaper copied to ~/Pictures/1-glowing-city.jpg. Set it from your desktop settings."
fi

info "Done."
printf '\nStart the terminal with:\n  kitty\n\n'
printf 'Installed:\n'
printf '  ~/.config/kitty/\n'
printf '  ~/.config/fastfetch/\n'
printf '  ~/.local/bin/fastfetch\n'
printf '  ~/.local/share/fonts/JetBrainsMonoNerdFont/\n'
if [ "$INSTALL_ZSHRC" -eq 1 ]; then
  printf '  ~/.zshrc\n'
else
  printf '  ~/.zshrc-green-city\n'
fi

if [ -d "$BACKUP_DIR" ]; then
  printf '\nBackups:\n  %s\n' "$BACKUP_DIR"
else
  printf '\nNo existing configs needed backing up.\n'
fi

if [ "$INSTALL_BORDER" -eq 1 ]; then
  printf '\nBorder:    enabled\n'
else
  printf '\nBorder:    not installed (use --border)\n'
fi

if [ "$INSTALL_WALLPAPER" -eq 1 ]; then
  printf 'Wallpaper: copied\n'
else
  printf 'Wallpaper: not copied (use --wallpaper)\n'
fi
