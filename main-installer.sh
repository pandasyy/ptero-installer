#!/bin/bash

set -e

######################################################################################
#                                                                                    #
# Project: pandasyy                                                                  #
#                                                                                    #
# Server management installer                                                       #
#                                                                                    #
# Copyright (C) 2025, Pandasyy                                                      #
#                                                                                    #
# This program is free software: you can redistribute it and/or modify               #
# it under the terms of the GNU General Public License as published by               #
# the Free Software Foundation, either version 3 of the License, or                  #
# (at your option) any later version.                                                #
#                                                                                    #
# This program is distributed in the hope that it will be useful,                    #
# but WITHOUT ANY WARRANTY; without even the implied warranty of                     #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                      #
# GNU General Public License for more details.                                       #
#                                                                                    #
# You should have received a copy of the GNU General Public License                   #
# along with this program. If not, see <https://www.gnu.org/licenses/>.               #
#                                                                                    #
######################################################################################

# =========================
# Pandasyy Configuration
# =========================

export GITHUB_SOURCE="v1.0.0"
export SCRIPT_RELEASE="v1.0.0"

# You can change this later to YOUR repo
export GITHUB_BASE_URL="https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer"

LOG_PATH="/var/log/pandasyy-installer.log"

# =========================
# Dependency Check
# =========================

if ! command -v curl >/dev/null 2>&1; then
  echo "* pandasyy requires curl to run."
  echo "* Install using apt (Debian/Ubuntu) or yum/dnf (RHEL/CentOS)"
  exit 1
fi

# =========================
# Load Core Library
# =========================

[ -f /tmp/pandasyy-lib.sh ] && rm -rf /tmp/pandasyy-lib.sh
curl -sSL -o /tmp/pandasyy-lib.sh "$GITHUB_BASE_URL"/master/lib/lib.sh
# shellcheck source=/tmp/pandasyy-lib.sh
source /tmp/pandasyy-lib.sh

# =========================
# Core Executor
# =========================

pandasyy_execute() {
  echo -e "\n\n* pandasyy installer run — $(date)\n\n" >>"$LOG_PATH"

  [[ "$1" == *"canary"* ]] && export GITHUB_SOURCE="master" && export SCRIPT_RELEASE="canary"

  update_lib_source
  run_ui "${1//_canary/}" |& tee -a "$LOG_PATH"

  if [[ -n $2 ]]; then
    echo -n "* $1 completed. Continue with $2 installation? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
      pandasyy_execute "$2"
    else
      error "pandasyy: $2 installation cancelled."
      exit 1
    fi
  fi
}

# =========================
# UI
# =========================

welcome "pandasyy installer"

done=false
while [ "$done" = false ]; do
  options=(
    "Install Panel"
    "Install Wings"
    "Install Panel + Wings (same machine)"

    "Install Panel (canary)"
    "Install Wings (canary)"
    "Install Panel + Wings (canary)"
    "Uninstall components (canary)"
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

  output "pandasyy — select an option:"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Choice (0-${#actions[@]}): "
  read -r action

  [ -z "$action" ] && error "Input required" && continue

  if [[ "$action" =~ ^[0-9]+$ ]] && [ "$action" -lt "${#actions[@]}" ]; then
    done=true
    IFS=";" read -r a1 a2 <<<"${actions[$action]}"
    pandasyy_execute "$a1" "$a2"
  else
    error "Invalid option"
  fi
done

# =========================
# Cleanup
# =========================

rm -rf /tmp/pandasyy-lib.sh
