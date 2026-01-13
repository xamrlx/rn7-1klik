#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==========================================================
# myrul.dev RN7 1-Click Tool
# Debloat • Clean • Game Mode • Ultra Battery (SAFE)
#
# Made with ❤️ by myrul.dev
# https://www.facebook.com/xamrl
#
# License: MIT
# ==========================================================

if ! command -v rish >/dev/null 2>&1; then
  echo "[ERROR] 'rish' tidak ditemukan. Pastikan Shizuku RUNNING."
  exit 1
fi

export RISH_APPLICATION_ID=${RISH_APPLICATION_ID:-com.termux}
run() { rish -c "$1"; }

logo() {
cat <<'EOF'
 __  __       _       _       _
|  \/  | ___ | |_ ___(_)_ __ (_)_ __ ___
| |\/| |/ _ \| __/ _ \ | '_ \| | '_ ` _ \
| |  | | (_) | ||  __/ | | | | | | | | | |
|_|  |_|\___/ \__\___|_|_| |_|_|_| |_| |_|
        made with myrul.dev
     facebook.com/xamrl
EOF
}

detect() {
  MODEL="$(run 'getprop ro.product.model' | tr -d '\r')"
  ANDR="$(run 'getprop ro.build.version.release' | tr -d '\r')"
}

DEBLOAT_PKGS=(
  com.miui.analytics
  com.miui.msa.global
  com.xiaomi.joyose
  com.miui.daemon
  com.miui.bugreport
)

disable_list() {
  for pkg in "$@"; do
    run "pm list packages $pkg" | grep -q "$pkg" && run "pm disable-user --user 0 $pkg" || true
  done
}

enable_list() {
  for pkg in "$@"; do
    run "pm list packages $pkg" | grep -q "$pkg" && run "pm enable $pkg" || true
  done
}

clean_now() {
  run "am kill-all" || true
  run "pm trim-caches 999G" || true
}

game_on() { run "cmd power set-fixed-performance-mode-enabled true" || true; }
game_off() { run "cmd power set-fixed-performance-mode-enabled false" || true; }

ultra_on() {
  run "settings put global master_sync_enabled 0" || true
  run "settings put global wifi_scan_always_enabled 0" || true
  run "settings put global ble_scan_always_enabled 0" || true
}

ultra_off() {
  run "settings put global master_sync_enabled 1" || true
  run "settings put global wifi_scan_always_enabled 1" || true
  run "settings put global ble_scan_always_enabled 1" || true
}

while true; do
  clear
  logo
  detect
  echo "Device: $MODEL | Android: $ANDR"
  echo "----------------------------------"
  echo "1) Debloat aman"
  echo "2) Clean system"
  echo "3) Game Mode ON"
  echo "4) Game Mode OFF"
  echo "5) Ultra Battery ON"
  echo "6) Ultra Battery OFF"
  echo "7) Restore debloat"
  echo "0) Keluar"
  read -rp "Pilih: " c
  case "$c" in
    1) disable_list "${DEBLOAT_PKGS[@]}" ;;
    2) clean_now ;;
    3) game_on ;;
    4) game_off ;;
    5) ultra_on ;;
    6) ultra_off ;;
    7) enable_list "${DEBLOAT_PKGS[@]}" ;;
    0) exit 0 ;;
  esac
  read -rp "Enter untuk lanjut..."
done
