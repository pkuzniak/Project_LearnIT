#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y docker.io curl ca-certificates

systemctl enable --now docker

install -d -m 0755 /opt/learnit
