#!/bin/bash
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh

# Preparing for installation of latest Suricata from PPA repository
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:oisf/suricata-stable
sudo apt-get -y update

# Install packages
sudo apt-get -y install suricata
sudo suricata-update add-source PP "${source_signature}"
sudo suricata-update update-sources
sudo suricata-update

# Suricata Configuration
sudo mv /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak
cat <<"EOF" >/etc/suricata/suricata.yaml
${suricata_config}
EOF
systemctl restart suricata

# installation by apt-get is idempotent, as golden image might have logging agent aka fluentd installed
sudo apt-get -y install google-fluentd
# Cloud Logging - enabled by setting cloud_logging_fast and/or cloud_logging_eve to True
mkdir -p /etc/google-fluentd/config.d
cat <<"EOF" >/etc/google-fluentd/config.d/suricata.conf
${log_fast}
${log_eve}
${log_custom}
EOF
systemctl restart google-fluentd

# Web server for health checking
sudo apt-get -y install apache2
echo "Suricata IDS - Packet Mirror" | sudo tee /var/www/html/index.html
sudo systemctl restart apache2
