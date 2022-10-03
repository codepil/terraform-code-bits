#!/bin/bash
# Configure using fluentd syslog plugin
# Pre-requisite: VM image should contain standalone stack-driver logging agent, which is the case for LZ gold images

# install google-fluentd if not found on the VM instance
if [ ! -f /etc/google-fluentd/config.d/syslog_endpoint.conf ]; then
  curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
  sudo bash add-logging-agent-repo.sh --also-install
fi

sudo sed -i 's/bind .*/bind 0.0.0.0 \n  source_hostname_key source_hostname \n  source_address_key source_address/g' /etc/google-fluentd/config.d/syslog_endpoint.conf
sudo service google-fluentd restart



