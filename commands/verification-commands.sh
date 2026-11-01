#!/usr/bin/env bash
# Run INSIDE each private host (ewb-app-a or ewb-app-b).
# Usage: ./verification-commands.sh <PEER_PRIVATE_IP>
#   On App-A: ./verification-commands.sh 10.20.1.10
#   On App-B: ./verification-commands.sh 10.10.2.10
hostname
hostname -I
ping -c 4 "$1"
