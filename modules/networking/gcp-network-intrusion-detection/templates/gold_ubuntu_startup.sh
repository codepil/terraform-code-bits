#!/bin/bash

sudo suricata-update add-source PP "${source_signature_path}"
sudo suricata-update update-sources
sudo suricata-update

sudo mv /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak
sudo gsutil cp "${suricata_config_path}" /etc/suricata/suricata.yaml
systemctl restart suricata

sudo gsutil cp "${log_config_path}" /etc/google-fluentd/config.d/suricata-custom.conf
systemctl restart google-fluentd
