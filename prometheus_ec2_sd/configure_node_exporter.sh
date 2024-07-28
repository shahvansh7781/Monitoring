#!/bin/bash
export NODE_EXPORTER_VERSION=1.8.2
sudo useradd --no-create-home --shell /bin/false nodeuser

sudo mkdir /etc/node_exporter
sudo chown -R nodeuser:nodeuser /etc/node_exporter


sudo ufw allow 9100/tcp
sudo ufw reload

wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
tar zxvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
cd node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/

sudo cp node_exporter /usr/local/bin/
sudo chown -R nodeuser:nodeuser /usr/local/bin/node_exporter

cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter Service
After=network.target

[Service]
User=nodeuser
Group=nodeuser
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
