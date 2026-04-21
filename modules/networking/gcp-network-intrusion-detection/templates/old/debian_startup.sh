#!/bin/bash
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
bash add-logging-agent-repo.sh

echo "deb http://http.debian.net/debian buster-backports main" > \
    /etc/apt/sources.list.d/backports.list

# Install packages
apt update -y && apt -y install suricata -t buster-backports 
apt -y install suricata-update apache2 google-fluentd

suricata-update add-source PP "${source_signature}"
suricata-update update-sources
suricata-update

# Suricata Configuration
mv /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak
cat <<"EOF" > /etc/suricata/suricata.yaml
${suricata_config}
EOF
systemctl restart suricata

# Cloud Logging - enabled by setting cloud_logging_fast and/or cloud_logging_eve to True
mkdir -p /etc/google-fluentd/config.d
cat <<"EOF" > /etc/google-fluentd/config.d/suricata.conf
${log_fast}
${log_eve}
${log_custom}
EOF
systemctl restart google-fluentd

# Web server for healthchecking
echo "Suricata IDS - Packet Mirror" > /var/www/html/index.html
systemctl restart apache2


