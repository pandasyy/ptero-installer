#!/bin/bash

set -e

######################################################################################
#                                                                                    #
#  pandasyy-installer                                                                #
#                                                                                    #
#  Modern installer for Pterodactyl Panel & Wings                                    #
#                                                                                    #
#  Maintained by Pandasyy                                                            #
#                                                                                    #
#  License: GNU GPL v3 or later                                                       #
#                                                                                    #
######################################################################################

# =========================
# Branding
# =========================

APP_NAME="pandasyy-installer"
APP_VERSION="v1.0.0"
LOG_PATH="/var/log/pandasyy-installer.log"

# =========================
# GitHub Source
# =========================

export GITHUB_SOURCE="main"
export SCRIPT_RELEASE="$APP_VERSION"
export GITHUB_BASE_URL="https://raw.githubusercontent.com/pandasyy/ptero-installer"

# =========================
# Colors
# =========================

GREEN="\033[1;32m"
BLUE="\033[1;34m"
RED="\033[1;31m"
NC="\033[0m"

# =========================
# Banner
# =========================

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
echo -e "${GREEN}${APP_NAME} ${APP_VERSION}${NC}"
echo ""

# =========================
# Dependency Check
# =========================

if ! command -v curl >/dev/null 2>&1; then
  echo -e "${RED}✖ curl is required but not installed.${NC}"
  exit 1
fi

# =========================
# Load Core Library
# =========================

LIB_PATH="/tmp/pandasyy-lib.sh"
[ -f "$LIB_PATH" ] && rm -f "$LIB_PATH"

curl -sSL -o "$LIB_PATH" "$GITHUB_BASE_URL/main/lib/lib.sh"
source "$LIB_PATH"

# =========================
# Executor
# =========================

pandasyy_run() {
  echo -e "\n[$(date)] Running: $1" >>"$LOG_PATH"

  [[ "$1" == *"canary"* ]] && export GITHUB_SOURCE="main"

  update_lib_source
  run_ui "${1//_canary/}" |& tee -a "$LOG_PATH"

  if [[ -n "$2" ]]; then
    read -rp "→ Continue with $2? (y/N): " CONFIRM
    [[ "$CONFIRM" =~ ^[Yy]$ ]] && pandasyy_run "$2"
  fi
}

# =========================
# Menu
# =========================

welcome "pandasyy installer"

done=false
while [ "$done" = false ]; do
  options=(
    "Install Panel"
    "Install Wings"
    "Install Panel + Wings"
    "Install Panel (Canary)"
    "Install Wings (Canary)"
    "Install Panel + Wings (Canary)"
    "Uninstall (Canary)"
  )

  actions=(
    "panel"
    "wings"
    "panel;wings"
    "panel_canary"
    "wings_canary"
    "panel_canary;wings_canary"
    "uninstall_canary"
  )

  output "Select an option:"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  read -rp "> " action

  if [[ "$action" =~ ^[0-9]+$ ]] && [ "$action" -lt "${#actions[@]}" ]; then
    done=true
    IFS=";" read -r a1 a2 <<<"${actions[$action]}"
    pandasyy_run "$a1" "$a2"
  else
    error "Invalid option"
  fi
done

rm -f "$LIB_PATH"
