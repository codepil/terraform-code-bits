# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/downloading-a-collector-installer#installation

wget -O LogicmonitorSetup64.bin "${download_url}"
chmod +x LogicmonitorSetup64.bin
# silent installation
sudo ./LogicmonitorSetup64.bin -y


