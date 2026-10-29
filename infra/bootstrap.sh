#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y docker.io curl ca-certificates prometheus-node-exporter

systemctl enable --now docker
systemctl enable --now prometheus-node-exporter

install -d -m 0755 /opt/learnit
