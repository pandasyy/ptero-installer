#!/bin/bash

set -e

############################################
# Pandasyy Installer
# Author: Pandasyy
# Version: 1.0.0
# License: GPLv3
############################################

APP_NAME="pandasyy-installer"
VERSION="1.0.0"
LOG_FILE="/var/log/pandasyy-installer.log"

# ---------- Colors ----------
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

# ---------- Banner ----------
clear
echo -e "${BLUE}"
cat << "EOF"
 ██████╗  █████╗ ███╗   ██╗██████╗  █████╗ ███████╗██╗   ██╗██╗   ██╗
 ██╔══██╗██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔════╝╚██╗ ██╔╝╚██╗ ██╔╝
 ██████╔╝███████║██╔██╗ ██║██║  ██║███████║███████╗ ╚████╔╝  ╚████╔╝
 ██╔═══╝ ██╔══██║██║╚██╗██║██║  ██║██╔══██║╚════██║  ╚██╔╝    ╚██╔╝
 ██║     ██║  ██║██║ ╚████║██████╔╝██║  ██║███████║   ██║       ██║
 ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═╝
EOF
echo -e "${NC}"
echo -e "${GREEN}${APP_NAME} v${VERSION}${NC}"
echo ""

# ---------- Helpers ----------
log() {
  echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

pause() {
  read -rp "Press ENTER to continue..."
}

require_root() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}✖ Please run as root${NC}"
    exit 1
  fi
}

check_deps() {
  for pkg in curl sudo; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
      echo -e "${RED}✖ Missing dependency: $pkg${NC}"
      exit 1
    fi
  done
}

# ---------- Fake Installers (placeholders) ----------
install_panel() {
  log "Starting Panel installation"
  echo -e "${YELLOW}Installing Panel...${NC}"
  sleep 2
  echo -e "${GREEN}✔ Panel installed (placeholder)${NC}"
  log "Panel installation finished"
}

install_wings() {
  log "Starting Wings installation"
  echo -e "${YELLOW}Installing Wings...${NC}"
  sleep 2
  echo -e "${GREEN}✔ Wings installed (placeholder)${NC}"
  log "Wings installation finished"
}

uninstall_all() {
  log "Starting uninstall"
  echo -e "${RED}Uninstalling components...${NC}"
  sleep 2
  echo -e "${GREEN}✔ Uninstall complete (placeholder)${NC}"
  log "Uninstall finished"
}

# ---------- Menu ----------
require_root
check_deps

while true; do
  echo ""
  echo "Select an option:"
  echo "  [1] Install Panel"
  echo "  [2] Install Wings"
  echo "  [3] Install Panel + Wings"
  echo "  [4] Uninstall"
  echo "  [0] Exit"
  echo ""

  read -rp "> " choice

  case "$choice" in
    1)
      install_panel
      pause
      ;;
    2)
      install_wings
      pause
      ;;
    3)
      install_panel
      install_wings
      pause
      ;;
    4)
      uninstall_all
      pause
      ;;
    0)
      echo -e "${GREEN}Goodbye!${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option${NC}"
      ;;
  esac
done
