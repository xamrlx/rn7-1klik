#!/data/data/com.termux/files/usr/bin/bash
set -e

# ==========================================================
# RN7 1-Click Tool (Safe • No Root)
# Debloat • Clean • Game Mode • Ultra Battery • Monitor • Restore
#
# myrul.dev
# https://www.facebook.com/xamrl
#
# Requires:
# - Shizuku RUNNING
# - rish installed & working (rish -c id)
#
# Safety:
# - DISABLE only (no uninstall)
# - Restore supported
# ==========================================================

# --- Requirements ---
if ! command -v rish >/dev/null 2>&1; then
  echo "[ERROR] 'rish' tidak ditemukan."
  echo "Pastikan Shizuku RUNNING dan rish sudah terpasang di Termux."
  exit 1
fi

# Ensure rish knows the calling app id (Termux)
export RISH_APPLICATION_ID=${RISH_APPLICATION_ID:-com.termux}

run() { rish -c "$1"; }

# Quick connectivity check (non-fatal)
if ! run "id" >/dev/null 2>&1; then
  echo "[ERROR] Tidak bisa konek ke Shizuku (rish -c id gagal)."
  echo "Cek Shizuku RUNNING, izin Termux di Shizuku, dan battery/autostart."
  exit 1
fi

logo() {
  G="\033[1;32m"  # green
  N="\033[0m"     # reset

  echo -e "${G}"
  cat <<'EOF'
                   _   _         
 _____ _ _ ___ _ _| |_| |___ _ _ 
|     | | |  _| | | | . | -_| | |
|_|_|_|_  |_| |___|_|___|___|\_/ 
      |___|  Tools rn7_1klik                    
         
EOF
  echo -e "${N}${G}   myrul.dev | facebook.com/xamrl${N}"
}

# --- Auto detect device / series ---
detect_device() {
  BRAND="$(run 'getprop ro.product.brand' 2>/dev/null | tr -d '\r')"
  MANU="$(run 'getprop ro.product.manufacturer' 2>/dev/null | tr -d '\r')"
  MODEL="$(run 'getprop ro.product.model' 2>/dev/null | tr -d '\r')"
  DEVICE="$(run 'getprop ro.product.device' 2>/dev/null | tr -d '\r')"
  MIUI="$(run 'getprop ro.miui.ui.version.name' 2>/dev/null | tr -d '\r')"
  ANDR="$(run 'getprop ro.build.version.release' 2>/dev/null | tr -d '\r')"

  SERIES="Unknown"
  if echo "$BRAND $MANU $MODEL" | grep -qiE "redmi"; then
    SERIES="Redmi"
  elif echo "$BRAND $MANU $MODEL" | grep -qiE "\bpoco\b"; then
    SERIES="POCO"
  elif echo "$BRAND $MANU $MODEL" | grep -qiE "xiaomi|\bmi\b"; then
    SERIES="Xiaomi (Mi)"
  fi
}

show_device_info() {
  detect_device
  echo "Device : $MODEL ($DEVICE)"
  echo "Series : $SERIES"
  echo "Android: $ANDR"
  echo "MIUI   : ${MIUI:-unknown}"
}

# --- Safe MIUI debloat list (disable only) ---
DEBLOAT_PKGS=(
  com.miui.analytics                # telemetry
  com.miui.msa.global               # MIUI ads
  com.xiaomi.joyose                 # tracking/optimization service
  com.miui.daemon                   # MIUI daemon
  com.miui.bugreport                # bug report
  com.miui.android.fashiongallery   # wallpaper carousel ads
  com.miui.yellowpage               # yellow pages
)

# Optional packages (disable only if you DON'T use them)
OPTIONAL_PKGS=(
  com.miui.browser
  com.miui.player
  com.miui.videoplayer
  com.miui.notes
  com.miui.compass
  com.miui.fmradio
  com.miui.weather2
  com.xiaomi.mipicks                # GetApps (Global ROM)
)

# --- Helpers: status & pretty output ---
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }

pkg_exists() { run "pm list packages $1" | grep -q "$1"; }

disable_pkg() {
  local pkg="$1"
  if ! pkg_exists "$pkg"; then
    yellow "• Skip (tidak ada): $pkg"
    return 0
  fi

  # Check current state
  if run "pm list packages -d $pkg" | grep -q "$pkg"; then
    yellow "• Sudah disable: $pkg"
    return 0
  fi

  if run "pm disable-user --user 0 $pkg" >/dev/null 2>&1; then
    green "• Berhasil disable: $pkg"
  else
    red "• Gagal disable: $pkg"
  fi
}

enable_pkg() {
  local pkg="$1"
  if ! pkg_exists "$pkg"; then
    yellow "• Skip (tidak ada): $pkg"
    return 0
  fi

  if run "pm enable $pkg" >/dev/null 2>&1; then
    green "• Berhasil enable: $pkg"
  else
    red "• Gagal enable: $pkg"
  fi
}

disable_list() { for p in "$@"; do disable_pkg "$p"; done; }
enable_list() { for p in "$@"; do enable_pkg "$p"; done; }

# --- Clean ---
clean_now() {
  echo
  echo "[INFO] Execute: Clean (kill background + trim cache)"
  if run "am kill-all" >/dev/null 2>&1; then
    green "[OK] Background apps ditutup."
  else
    yellow "[WARN] am kill-all tidak didukung/ditolak, lanjut..."
  fi

  if run "pm trim-caches 999G" >/dev/null 2>&1; then
    green "[OK] Cache sistem dibersihkan (trim-caches)."
  else
    yellow "[WARN] trim-caches tidak didukung/ditolak, lanjut..."
  fi

  green "[DONE] Clean selesai."
}

# --- Game Mode (robust) ---
# Some Android versions (incl Android 10) don't have:
# cmd power set-fixed-performance-mode-enabled
supports_fixed_perf() {
  run "cmd power help" 2>/dev/null | grep -q "set-fixed-performance-mode-enabled"
}

game_on() {
  echo
  echo "[INFO] Execute: Game Mode ON"
  # Always do lightweight actions that are safe
  run "am kill-all" >/dev/null 2>&1 || true
  green "[OK] Background apps ditutup."

  if supports_fixed_perf; then
    if run "cmd power set-fixed-performance-mode-enabled true" >/dev/null 2>&1; then
      green "[OK] Fixed performance mode: ON"
      green "[DONE] Game Mode aktif."
    else
      yellow "[WARN] Perintah performance mode gagal dijalankan. Tetap lanjut (clean sudah dilakukan)."
      yellow "[DONE] Game Mode: Clean-only (fallback)."
    fi
  else
    yellow "[INFO] Android kamu tidak mendukung 'set-fixed-performance-mode-enabled'."
    yellow "[DONE] Game Mode: Clean-only (fallback)."
  fi
}

game_off() {
  echo
  echo "[INFO] Execute: Game Mode OFF"
  if supports_fixed_perf; then
    if run "cmd power set-fixed-performance-mode-enabled false" >/dev/null 2>&1; then
      green "[OK] Fixed performance mode: OFF"
      green "[DONE] Game Mode nonaktif."
    else
      yellow "[WARN] Perintah performance mode gagal. Tidak ada yang diubah."
    fi
  else
    yellow "[INFO] Android kamu tidak mendukung 'set-fixed-performance-mode-enabled'."
    yellow "[DONE] Tidak ada yang perlu dimatikan (sebelumnya fallback)."
  fi
}

# --- Ultra Battery Mode ---
ultra_on() {
  echo
  echo "[INFO] Execute: Ultra Battery ON"
  ok=0

  run "settings put global master_sync_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global background_check_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global wifi_scan_always_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global ble_scan_always_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true

  if [ "$ok" -gt 0 ]; then
    green "[OK] Ultra Battery Mode aktif (applied: $ok setting)."
  else
    yellow "[WARN] Tidak ada setting yang berhasil diubah (mungkin dibatasi ROM)."
  fi
  yellow "Catatan: Master sync dimatikan (email/photos bisa tidak auto-sync)."
}

ultra_off() {
  echo
  echo "[INFO] Execute: Ultra Battery OFF (restore)"
  ok=0

  run "settings put global master_sync_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global background_check_enabled 0" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global wifi_scan_always_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true
  run "settings put global ble_scan_always_enabled 1" >/dev/null 2>&1 && ok=$((ok+1)) || true

  if [ "$ok" -gt 0 ]; then
    green "[OK] Ultra Battery Mode dimatikan (restore) (applied: $ok setting)."
  else
    yellow "[WARN] Tidak ada setting yang berhasil diubah (mungkin dibatasi ROM)."
  fi
}

# --- Monitor ---
show_top() {
  echo
  echo "[INFO] Execute: Monitor RAM/CPU (top)"
  yellow "Tekan Ctrl+C untuk keluar"
  sleep 1
  run "top -o RES,CPU,ARGS -s 10"
}

pause() { echo; read -r -p "Tekan Enter untuk lanjut..."; }

# --- Main Menu ---
while true; do
  clear
  logo
  echo "----------------------------------------------"
  show_device_info
  echo "=============================================="
  echo "1) Debloat AMAN (iklan & telemetry MIUI)"
  echo "2) Debloat + Optional (tambahan app MIUI)"
  echo "3) Clean (kill background + trim cache)"
  echo "4) Game Mode ON"
  echo "5) Game Mode OFF"
  echo "6) Ultra Battery ON (hemat maksimal)"
  echo "7) Ultra Battery OFF (restore)"
  echo "8) Monitor RAM / CPU (top)"
  echo "9) Restore Debloat (enable semua yang di-disable)"
  echo "0) Keluar"
  echo "----------------------------------------------"
  read -r -p "Pilih (0-9): " c

  case "$c" in
    1)
      echo
      echo "[INFO] Execute: Debloat AMAN"
      disable_list "${DEBLOAT_PKGS[@]}"
      green "[DONE] Debloat aman selesai."
      pause
      ;;
    2)
      echo
      echo "[INFO] Execute: Debloat AMAN + Optional"
      echo "== Safe =="
      disable_list "${DEBLOAT_PKGS[@]}"
      echo
      echo "== Optional (disable jika tidak dipakai) =="
      disable_list "${OPTIONAL_PKGS[@]}"
      green "[DONE] Debloat + optional selesai."
      pause
      ;;
    3) clean_now; pause ;;
    4) game_on; pause ;;
    5) game_off; pause ;;
    6) ultra_on; pause ;;
    7) ultra_off; pause ;;
    8) show_top; pause ;;
    9)
      echo
      echo "[INFO] Execute: Restore Debloat"
      enable_list "${DEBLOAT_PKGS[@]}"
      enable_list "${OPTIONAL_PKGS[@]}"
      green "[DONE] Restore selesai."
      pause
      ;;
    0) exit 0 ;;
    *) red "Pilihan tidak valid"; pause ;;
  esac
done
