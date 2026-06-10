#!/bin/bash
# ============================================================
#  run.sh — Flutter Dev Runner for PiliHotel
#  Usage:
#    ./run.sh              → auto-detect IP, run on connected device
#    ./run.sh emulator     → force Android Emulator (10.0.2.2)
#    ./run.sh <IP>         → use custom IP (e.g. ./run.sh 192.168.1.5)
# ============================================================

BACKEND_PORT=8000

# ── Determine base URL ───────────────────────────────────────
if [ "$1" = "emulator" ]; then
  BASE_URL="http://10.0.2.2:${BACKEND_PORT}/api"
  echo "📱  Mode: Android Emulator"
elif [ -n "$1" ]; then
  BASE_URL="http://$1:${BACKEND_PORT}/api"
  echo "📱  Mode: Custom IP ($1)"
else
  # Auto-detect Mac's local IP (try en0 first, then en1)
  MAC_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
  if [ -z "$MAC_IP" ]; then
    echo "❌  Could not detect Mac IP. Are you connected to WiFi?"
    echo "    Try: ./run.sh emulator   OR   ./run.sh <YOUR_IP>"
    exit 1
  fi
  BASE_URL="http://${MAC_IP}:${BACKEND_PORT}/api"
  echo "📱  Mode: Physical Device (Mac IP: $MAC_IP)"
fi

echo "🔗  API Base URL: $BASE_URL"
echo ""

# ── Check backend is running ─────────────────────────────────
if ! curl -s --max-time 2 "http://${BASE_URL%/api}" > /dev/null 2>&1; then
  echo "⚠️   Warning: Backend may not be reachable at ${BASE_URL%/api}"
  echo "    Make sure Laravel is running: php artisan serve --host=0.0.0.0 --port=${BACKEND_PORT}"
  echo ""
fi

# ── Run Flutter ──────────────────────────────────────────────
flutter run --dart-define=API_BASE_URL="$BASE_URL" "$@"
